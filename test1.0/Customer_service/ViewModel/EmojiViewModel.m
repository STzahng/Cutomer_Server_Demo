//
//  EmojiViewModel.m
//  test1.0
//
//  Created by heiqi on 2025/4/15.
//

#import "EmojiViewModel.h"

@interface EmojiViewModel ()

@property (nonatomic, strong) NSMutableArray *emojiGroupsArray;
@property (nonatomic, assign) BOOL emojiDataLoaded;
@property (nonatomic, copy) NSString *resourceBaseURL;
@property (nonatomic, copy) NSString *avatarResourceBaseURL;
@property (nonatomic, strong) NSMutableDictionary *downloadedImages;
@property (nonatomic, strong) NSMutableSet *downloadedImages_ID;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, assign) NSInteger totalDownloads;
@property (nonatomic, assign) NSInteger completedDownloads;
@property (nonatomic, strong) NSMutableArray *imageUpdateCallbacks;

@end

@implementation EmojiViewModel

#pragma mark - 单例实现

+ (instancetype)sharedInstance {
    static EmojiViewModel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EmojiViewModel alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _emojiGroupsArray = [NSMutableArray array];
        _emojiDataLoaded = NO;
        _resourceBaseURL = @"";
        _avatarResourceBaseURL = @"";
        _downloadedImages = [NSMutableDictionary dictionary];
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 4; // 限制并发下载数
        _imageUpdateCallbacks = [NSMutableArray array];
        
        // 添加通知监听，接收WebSocket消息
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleWebSocketMessage:)
                                                     name:@"WebSocketMessageReceived"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - WebSocket消息处理

- (void)handleWebSocketMessage:(NSNotification *)notification {
    id message = notification.userInfo[@"message"];
    
    if ([message isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)message;
        NSString *method = dict[@"method"];
        
        // 处理setChatResources消息
        if ([method isEqualToString:@"setChatResources"]) {
            [self parseEmojiDataFromMessage:dict];
        }
    }
}

#pragma mark - Emoji数据处理

- (void)parseEmojiDataFromMessage:(NSDictionary *)message {
    // 提取params部分
    NSDictionary *params = message[@"params"];
    if (!params || ![params isKindOfClass:[NSDictionary class]]) {
        NSLog(@"解析emoji数据失败：params为空或类型错误");
        return;
    }
    
    // 提取资源URL
    NSString *resURL = params[@"res_url"];
    if (resURL && [resURL isKindOfClass:[NSString class]]) {
        self.resourceBaseURL = resURL;
        NSLog(@"资源基础URL: %@", self.resourceBaseURL);
    } else {
        NSLog(@"警告: res_url为空或不是字符串");
    }
    
    // 提取头像资源URL
    NSString *avatarResURL = params[@"avatar_res_url"];
    if (avatarResURL && [avatarResURL isKindOfClass:[NSString class]]) {
        self.avatarResourceBaseURL = avatarResURL;
        NSLog(@"头像资源基础URL: %@", self.avatarResourceBaseURL);
    } else {
        NSLog(@"警告: avatar_res_url为空或不是字符串");
    }
    
    // 提取emoji组数据
    NSArray *emojiGroups = params[@"emoji_groups"];
    if (!emojiGroups || ![emojiGroups isKindOfClass:[NSArray class]]) {
        NSLog(@"解析emoji数据失败：emoji_groups为空或类型错误");
        return;
    }
    
    // 清空现有数据
    [self.emojiGroupsArray removeAllObjects];
    
    // 解析每个emoji组
    for (NSDictionary *groupDict in emojiGroups) {
        if (![groupDict isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        NSMutableDictionary *group = [NSMutableDictionary dictionary];
        group[@"id"] = groupDict[@"id"];
        group[@"icon"] = groupDict[@"icon"];
        
        NSArray *emojis = groupDict[@"emojis"];
        if ([emojis isKindOfClass:[NSArray class]]) {
            NSMutableArray *emojiArray = [NSMutableArray array];
            
            for (NSDictionary *emojiDict in emojis) {
                if (![emojiDict isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                
                NSMutableDictionary *emoji = [NSMutableDictionary dictionary];
                emoji[@"id"] = emojiDict[@"id"];
                emoji[@"img"] = emojiDict[@"img"];
                //_downloadedImages_ID[@"id"] = emojiDict[@"img"];
                // 构建完整的图片URL
                if (self.resourceBaseURL.length > 0 && [emoji[@"img"] isKindOfClass:[NSString class]]) {
                    NSString *fullURL = [self fullURLForEmojiImage:emoji[@"img"]];
                    emoji[@"full_url"] = fullURL;
                }
                
                [emojiArray addObject:emoji];
            }
            
            group[@"emojis"] = emojiArray;
        }
        
        [self.emojiGroupsArray addObject:group];
    }
    
    // 标记数据已加载
    self.emojiDataLoaded = YES;
    
    // 通知数据状态改变
    if (self.onEmojiDataStatusChanged) {
        self.onEmojiDataStatusChanged(YES);
    }
    
    NSLog(@"成功解析 %lu 个emoji组", (unsigned long)self.emojiGroupsArray.count);
    
    // 自动下载所有资源
    [self downloadAllResources];
}

#pragma mark - 资源下载

- (NSString *)fullURLForEmojiImage:(NSString *)imageName {
    if (!imageName || ![imageName isKindOfClass:[NSString class]] || imageName.length == 0) {
        return nil;
    }
    
    // 确保baseURL以"/"结尾
    NSString *baseURL = self.resourceBaseURL;
    if (![baseURL hasSuffix:@"/"]) {
        baseURL = [baseURL stringByAppendingString:@"/"];
    }
    
    // 确保imageName不以"/"开头
    NSString *cleanImageName = imageName;
    if ([cleanImageName hasPrefix:@"/"]) {
        cleanImageName = [cleanImageName substringFromIndex:1];
    }
    
    return [baseURL stringByAppendingString:cleanImageName];
}

- (void)downloadResourcesForGroupId:(NSInteger)groupId {
    // 查找指定组
    NSDictionary *targetGroup = nil;
    for (NSDictionary *group in self.emojiGroupsArray) {
        if ([group[@"id"] integerValue] == groupId) {
            targetGroup = group;
            break;
        }
    }
    
    if (!targetGroup) {
        NSLog(@"找不到ID为%ld的emoji组", (long)groupId);
        return;
    }
    
    // 下载组图标
    NSString *iconName = targetGroup[@"icon"];
    if (iconName && [iconName isKindOfClass:[NSString class]] && iconName.length > 0) {
        NSString *iconURL = [self fullURLForEmojiImage:iconName];
        [self downloadImageFromURL:iconURL withCompletionHandler:^(UIImage *image) {
            if (image) {
                NSLog(@"成功下载组图标: %@", iconName);
                NSMutableDictionary *mutableGroup = [targetGroup mutableCopy];
                mutableGroup[@"icon_image"] = image;
                
                // 更新组数据
                NSInteger index = [self.emojiGroupsArray indexOfObject:targetGroup];
                if (index != NSNotFound) {
                    [self.emojiGroupsArray replaceObjectAtIndex:index withObject:mutableGroup];
                }
            }
        }];
    }
    
    // 下载组内所有emoji图片
    NSArray *emojis = targetGroup[@"emojis"];
    if (emojis && [emojis isKindOfClass:[NSArray class]]) {
        for (NSDictionary *emoji in emojis) {
            if (![emoji isKindOfClass:[NSDictionary class]]) continue;
            
            NSString *imgName = emoji[@"img"];
            if (!imgName || ![imgName isKindOfClass:[NSString class]] || imgName.length == 0) continue;
            
            NSString *fullURL = emoji[@"full_url"];
            if (!fullURL) {
                fullURL = [self fullURLForEmojiImage:imgName];
            }
            
            [self downloadImageFromURL:fullURL withCompletionHandler:^(UIImage *image) {
                if (image) {
                    NSLog(@"成功下载表情图片: %@", imgName);
                    
                    // 保存图片到缓存
                    @synchronized (self.downloadedImages) {
                        self.downloadedImages[imgName] = image;
                    }
                }
            }];
        }
    }
}

- (void)downloadAllResources {
    if (self.emojiGroupsArray.count == 0) {
        NSLog(@"没有emoji组数据可供下载");
        return;
    }
    
    // 计算需要下载的总数量
    self.totalDownloads = 0;
    self.completedDownloads = 0;
    
    for (NSDictionary *group in self.emojiGroupsArray) {
        // 组图标
        if (group[@"icon"] && [group[@"icon"] isKindOfClass:[NSString class]]) {
            self.totalDownloads++;
        }
        
        // 组内表情
        NSArray *emojis = group[@"emojis"];
        if (emojis && [emojis isKindOfClass:[NSArray class]]) {
            self.totalDownloads += emojis.count;
        }
    }
    
    NSLog(@"开始下载 %ld 个资源", (long)self.totalDownloads);
    
    // 下载每个组的资源
    for (NSDictionary *group in self.emojiGroupsArray) {
        NSInteger groupId = [group[@"id"] integerValue];
        [self downloadResourcesForGroupId:groupId];
    }
}

- (void)downloadImageFromURL:(NSString *)urlString withCompletionHandler:(void(^)(UIImage *image))completionHandler {
    if (!urlString || ![urlString isKindOfClass:[NSString class]] || urlString.length == 0) {
        NSLog(@"无效的URL");
        if (completionHandler) {
            completionHandler(nil);
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        NSLog(@"无法创建URL: %@", urlString);
        if (completionHandler) {
            completionHandler(nil);
        }
        return;
    }
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UIImage *image = nil;
        
        if (data && !error) {
            image = [UIImage imageWithData:data];
            
            // 如果成功下载图片，保存到缓存并通知回调
            if (image) {
                // 从URL中提取文件名
                NSString *imageName = [urlString lastPathComponent];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 保存到缓存
                    @synchronized (self.downloadedImages) {
                        self.downloadedImages[imageName] = image;
                    }
                    
                    // 通知所有注册的回调
                    [self notifyImageUpdateCallbacksForImage:image withName:imageName];
                });
            }
        }
        
        // 更新计数
        self.completedDownloads++;
        
        // 检查是否所有下载都完成了
        if (self.completedDownloads >= self.totalDownloads) {
            NSLog(@"所有资源下载完成");
        }
        
        if (completionHandler) {
            completionHandler(image);
        }
    }];
    
    [task resume];
}

#pragma mark - 新增方法

- (UIImage *)imageForEmojiWithName:(NSString *)imageName {
    if (!imageName || ![imageName isKindOfClass:[NSString class]] || imageName.length == 0) {
        return nil;
    }
    
    @synchronized (self.downloadedImages) {
        return self.downloadedImages[imageName];
    }
}

- (void)registerForImageUpdateWithBlock:(void(^)(NSString *imageName, UIImage *image))updateBlock {
    if (!updateBlock) return;
    
    @synchronized (self.imageUpdateCallbacks) {
        [self.imageUpdateCallbacks addObject:[updateBlock copy]];
    }
}

- (void)notifyImageUpdateCallbacksForImage:(UIImage *)image withName:(NSString *)imageName {
    if (!image || !imageName) return;
    
    NSArray *callbacks;
    @synchronized (self.imageUpdateCallbacks) {
        callbacks = [self.imageUpdateCallbacks copy];
    }
    
    for (void(^callback)(NSString *, UIImage *) in callbacks) {
        callback(imageName, image);
    }
}

#pragma mark - 公共方法

- (NSArray *)emojiGroups {
    return [self.emojiGroupsArray copy];
}

- (NSArray *)emojisInGroup:(NSInteger)groupId {
    for (NSDictionary *group in self.emojiGroupsArray) {
        if ([group[@"id"] integerValue] == groupId) {
            return group[@"emojis"];
        }
    }
    return @[];
}

- (NSArray *)allEmojiGroups {
    return [self.emojiGroupsArray copy];
}



@end 
