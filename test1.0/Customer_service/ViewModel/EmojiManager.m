//
//  EmojiManager.m
//  test1.0
//
//  Created by heiqi on 2025/4/10.
//

#import "EmojiManager.h"

// 定义emoji资源的基础URL
static NSString * const kEmojiBaseURL = @"https://cdn.example.com/emoji/";
// 定义emoji缓存目录
static NSString * const kEmojiCacheDirectory = @"EmojiCache";

#pragma mark - EmojiGroup 实现

@implementation EmojiGroup

- (instancetype)init {
    self = [super init];
    if (self) {
        _emojis = [NSMutableArray array];
    }
    return self;
}

@end

#pragma mark - EmojiItem 实现

@implementation EmojiItem

@end

#pragma mark - EmojiManager 实现

@interface EmojiManager ()

@property (nonatomic, strong) NSMutableArray<EmojiGroup *> *emojiGroups;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) dispatch_queue_t downloadQueue;
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, assign) NSInteger totalDownloads;
@property (nonatomic, assign) NSInteger completedDownloads;
@property (nonatomic, assign) NSInteger failedDownloads;

@end

@implementation EmojiManager

#pragma mark - 单例实现

+ (instancetype)sharedInstance {
    static EmojiManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _emojiGroups = [NSMutableArray array];
        _isLoading = NO;
        _downloadQueue = dispatch_queue_create("com.app.emoji.download", DISPATCH_QUEUE_CONCURRENT);
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config];
        
        // 创建缓存目录
        [self createCacheDirectoryIfNeeded];
    }
    return self;
}

#pragma mark - 公共方法

- (void)parseEmojiGroupsFromJSON:(NSDictionary *)jsonData {
    if (!jsonData || ![jsonData isKindOfClass:[NSDictionary class]]) {
        NSLog(@"无效的JSON数据");
        return;
    }
    
    // 检查是否是聊天资源配置消息
    NSString *method = jsonData[@"method"];
    if (![method isEqualToString:@"setChatResources"]) {
        NSLog(@"非聊天资源配置消息: %@", method);
        return;
    }
    
    // 提取参数
    NSDictionary *params = jsonData[@"params"];
    if (!params || ![params isKindOfClass:[NSDictionary class]]) {
        NSLog(@"无效的参数数据");
        return;
    }
    
    // 提取emoji组信息
    NSArray *emojiGroupsData = params[@"emoji_groups"];
    if (!emojiGroupsData || ![emojiGroupsData isKindOfClass:[NSArray class]]) {
        NSLog(@"无效的emoji组数据");
        return;
    }
    
    // 清空现有数据
    [self.emojiGroups removeAllObjects];
    
    // 解析每个emoji组
    for (NSDictionary *groupData in emojiGroupsData) {
        if (![groupData isKindOfClass:[NSDictionary class]]) continue;
        
        EmojiGroup *group = [[EmojiGroup alloc] init];
        group.groupId = [groupData[@"id"] integerValue];
        group.icon = groupData[@"icon"];
        
        // 解析组内的emoji
        NSArray *emojisData = groupData[@"emojis"];
        if ([emojisData isKindOfClass:[NSArray class]]) {
            for (NSDictionary *emojiData in emojisData) {
                if (![emojiData isKindOfClass:[NSDictionary class]]) continue;
                
                EmojiItem *emoji = [[EmojiItem alloc] init];
                emoji.emojiId = [emojiData[@"id"] integerValue];
                emoji.imgName = emojiData[@"img"];
                emoji.isDownloaded = NO;
                
                [group.emojis addObject:emoji];
            }
        }
        
        [self.emojiGroups addObject:group];
    }
    
    NSLog(@"成功解析 %lu 个emoji组，包含 %lu 个emoji", 
          (unsigned long)self.emojiGroups.count, 
          (unsigned long)[self getTotalEmojiCount]);
}

- (void)downloadAllEmojiResources {
    if (self.isLoading) {
        NSLog(@"正在下载中，请稍后再试");
        return;
    }
    
    self.isLoading = YES;
    self.totalDownloads = 0;
    self.completedDownloads = 0;
    self.failedDownloads = 0;
    
    // 计算需要下载的总数量
    NSInteger totalEmojiCount = [self getTotalEmojiCount];
    // 添加组图标数量
    self.totalDownloads = totalEmojiCount + self.emojiGroups.count;
    
    // 没有需要下载的内容
    if (self.totalDownloads == 0) {
        self.isLoading = NO;
        if (self.onEmojiLoadingComplete) {
            self.onEmojiLoadingComplete(YES);
        }
        return;
    }
    
    // 下载所有组图标
    for (EmojiGroup *group in self.emojiGroups) {
        [self downloadGroupIcon:group];
        
        // 下载组内所有emoji
        for (EmojiItem *emoji in group.emojis) {
            [self downloadEmoji:emoji inGroup:group.groupId];
        }
    }
}

- (NSArray<EmojiItem *> *)emojisInGroup:(NSInteger)groupId {
    for (EmojiGroup *group in self.emojiGroups) {
        if (group.groupId == groupId) {
            return [group.emojis copy];
        }
    }
    return @[];
}

- (nullable EmojiItem *)emojiWithId:(NSInteger)emojiId inGroup:(NSInteger)groupId {
    for (EmojiGroup *group in self.emojiGroups) {
        if (group.groupId == groupId) {
            for (EmojiItem *emoji in group.emojis) {
                if (emoji.emojiId == emojiId) {
                    return emoji;
                }
            }
            break;
        }
    }
    return nil;
}

- (void)clearAllData {
    [self.emojiGroups removeAllObjects];
    self.isLoading = NO;
    
    // 可选：清除缓存文件
    [self clearCacheDirectory];
}

#pragma mark - 私有方法

- (NSInteger)getTotalEmojiCount {
    NSInteger count = 0;
    for (EmojiGroup *group in self.emojiGroups) {
        count += group.emojis.count;
    }
    return count;
}

- (void)downloadGroupIcon:(EmojiGroup *)group {
    if (!group.icon || group.icon.length == 0) {
        [self handleDownloadCompletion:NO];
        return;
    }
    
    // 检查缓存
    UIImage *cachedImage = [self cachedImageForFileName:group.icon];
    if (cachedImage) {
        group.iconImage = cachedImage;
        [self handleDownloadCompletion:YES];
        return;
    }
    
    // 构建URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kEmojiBaseURL, group.icon]];
    
    // 创建下载任务
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        BOOL success = NO;
        
        if (data && !error) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    group.iconImage = image;
                });
                // 保存到缓存
                [self saveImageData:data withFileName:group.icon];
                success = YES;
            }
        }
        
        [self handleDownloadCompletion:success];
    }];
    
    [task resume];
}

- (void)downloadEmoji:(EmojiItem *)emoji inGroup:(NSInteger)groupId {
    if (!emoji.imgName || emoji.imgName.length == 0) {
        [self handleDownloadCompletion:NO];
        return;
    }
    
    // 检查缓存
    UIImage *cachedImage = [self cachedImageForFileName:emoji.imgName];
    if (cachedImage) {
        emoji.image = cachedImage;
        emoji.isDownloaded = YES;
        [self handleDownloadCompletion:YES];
        return;
    }
    
    // 构建URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kEmojiBaseURL, emoji.imgName]];
    
    // 创建下载任务
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        BOOL success = NO;
        
        if (data && !error) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    emoji.image = image;
                    emoji.isDownloaded = YES;
                });
                // 保存到缓存
                [self saveImageData:data withFileName:emoji.imgName];
                success = YES;
            }
        }
        
        [self handleDownloadCompletion:success];
    }];
    
    [task resume];
}

- (void)handleDownloadCompletion:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            self.completedDownloads++;
        } else {
            self.failedDownloads++;
        }
        
        // 检查是否所有下载都已完成
        if (self.completedDownloads + self.failedDownloads >= self.totalDownloads) {
            self.isLoading = NO;
            
            // 回调通知下载完成
            if (self.onEmojiLoadingComplete) {
                BOOL allSuccess = (self.failedDownloads == 0);
                self.onEmojiLoadingComplete(allSuccess);
            }
            
            NSLog(@"Emoji下载完成: 成功(%ld)，失败(%ld)", 
                 (long)self.completedDownloads, 
                 (long)self.failedDownloads);
        }
    });
}

#pragma mark - 缓存管理

- (void)createCacheDirectoryIfNeeded {
    NSString *cachePath = [self cacheDirectoryPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:cachePath]) {
        NSError *error;
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"创建缓存目录失败: %@", error.localizedDescription);
        }
    }
}

- (NSString *)cacheDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    return [cachesDirectory stringByAppendingPathComponent:kEmojiCacheDirectory];
}

- (NSString *)cachePathForFileName:(NSString *)fileName {
    return [[self cacheDirectoryPath] stringByAppendingPathComponent:fileName];
}

- (void)saveImageData:(NSData *)imageData withFileName:(NSString *)fileName {
    NSString *filePath = [self cachePathForFileName:fileName];
    [imageData writeToFile:filePath atomically:YES];
}

- (UIImage *)cachedImageForFileName:(NSString *)fileName {
    NSString *filePath = [self cachePathForFileName:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        return [UIImage imageWithData:imageData];
    }
    
    return nil;
}

- (void)clearCacheDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [self cacheDirectoryPath];
    
    if ([fileManager fileExistsAtPath:cachePath]) {
        NSError *error;
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:cachePath error:&error];
        
        if (!error) {
            for (NSString *fileName in contents) {
                NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:filePath error:&error];
                if (error) {
                    NSLog(@"删除缓存文件失败: %@", error.localizedDescription);
                }
            }
        }
    }
}

@end 