#import "EmojiManager.h"
#import <UIKit/UIKit.h>

@implementation EmojiItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _emojiId = 0;
        _imageName = @"";
        _image = nil;
        _imageUrl = @"";
        _groupId = 0;
    }
    return self;
}

@end

@implementation EmojiGroup

- (instancetype)init {
    self = [super init];
    if (self) {
        _groupId = 0;
        _iconName = @"";
        _icon = nil;
        _iconUrl = @"";
        _emojis = [NSMutableArray array];
    }
    return self;
}

@end

@interface EmojiManager ()

@property (nonatomic, strong) NSMutableArray<EmojiGroup *> *emojiGroupsArray;
@property (nonatomic, strong) dispatch_queue_t downloadQueue;
@property (nonatomic, strong) NSString *resourceBaseUrl;

@end

@implementation EmojiManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _emojiGroupsArray = [NSMutableArray array];
        _downloadQueue = dispatch_queue_create("com.customer_service.emoji.download", DISPATCH_QUEUE_CONCURRENT);
        _resourceBaseUrl = @"https://api.example.com/resources/";  // 假设的基础URL，实际使用时应该替换
    }
    return self;
}

- (NSArray<EmojiGroup *> *)emojiGroups {
    return [_emojiGroupsArray copy];
}

- (void)parseAndDownloadEmojiResources:(NSDictionary *)resourcesData completion:(EmojiCompletionBlock)completion {
    if (!resourcesData || ![resourcesData isKindOfClass:[NSDictionary class]]) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    // 清空现有数据
    [self.emojiGroupsArray removeAllObjects];
    
    NSDictionary *params = resourcesData[@"params"];
    if (!params || ![params isKindOfClass:[NSDictionary class]]) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    NSArray *emojiGroups = params[@"emoji_groups"];
    if (!emojiGroups || ![emojiGroups isKindOfClass:[NSArray class]]) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    // 解析表情分组
    for (NSDictionary *groupDict in emojiGroups) {
        EmojiGroup *group = [[EmojiGroup alloc] init];
        group.groupId = [groupDict[@"id"] integerValue];
        group.iconName = groupDict[@"icon"];
        group.iconUrl = [self.resourceBaseUrl stringByAppendingString:group.iconName];
        
        NSArray *emojis = groupDict[@"emojis"];
        if (emojis && [emojis isKindOfClass:[NSArray class]]) {
            for (NSDictionary *emojiDict in emojis) {
                EmojiItem *emoji = [[EmojiItem alloc] init];
                emoji.emojiId = [emojiDict[@"id"] integerValue];
                emoji.imageName = emojiDict[@"img"];
                emoji.imageUrl = [self.resourceBaseUrl stringByAppendingString:emoji.imageName];
                emoji.groupId = group.groupId;
                [group.emojis addObject:emoji];
            }
        }
        
        [self.emojiGroupsArray addObject:group];
    }
    
    // 下载所有资源
    [self downloadAllResources:completion];
}

- (void)downloadAllResources:(EmojiCompletionBlock)completion {
    __block NSInteger totalCount = 0;
    __block NSInteger completedCount = 0;
    
    // 计算需要下载的总资源数量
    for (EmojiGroup *group in self.emojiGroupsArray) {
        totalCount++; // 分组图标
        totalCount += group.emojis.count; // 该分组的所有表情
    }
    
    if (totalCount == 0) {
        if (completion) {
            completion(YES);
        }
        return;
    }
    
    __block BOOL hasError = NO;
    dispatch_group_t downloadGroup = dispatch_group_create();
    
    // 下载分组图标
    for (EmojiGroup *group in self.emojiGroupsArray) {
        dispatch_group_enter(downloadGroup);
        [self downloadImageWithURL:[NSURL URLWithString:group.iconUrl] completion:^(UIImage *image, NSError *error) {
            if (image && !error) {
                group.icon = image;
            } else {
                hasError = YES;
                NSLog(@"下载分组图标失败：%@, 错误：%@", group.iconUrl, error);
            }
            
            completedCount++;
            dispatch_group_leave(downloadGroup);
        }];
        
        // 下载该分组的所有表情
        for (EmojiItem *emoji in group.emojis) {
            dispatch_group_enter(downloadGroup);
            [self downloadImageWithURL:[NSURL URLWithString:emoji.imageUrl] completion:^(UIImage *image, NSError *error) {
                if (image && !error) {
                    emoji.image = image;
                } else {
                    hasError = YES;
                    NSLog(@"下载表情图片失败：%@, 错误：%@", emoji.imageUrl, error);
                }
                
                completedCount++;
                dispatch_group_leave(downloadGroup);
            }];
        }
    }
    
    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{
        if (completion) {
            completion(!hasError);
        }
    });
}

- (void)downloadImageWithURL:(NSURL *)url completion:(void(^)(UIImage *image, NSError *error))completion {
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UIImage *image = nil;
        if (data && !error) {
            image = [UIImage imageWithData:data];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(image, error);
            }
        });
    }];
    
    [task resume];
}

- (NSArray<EmojiItem *> *)emojisInGroup:(NSInteger)groupId {
    for (EmojiGroup *group in self.emojiGroupsArray) {
        if (group.groupId == groupId) {
            return [group.emojis copy];
        }
    }
    return @[];
}

- (nullable EmojiItem *)findEmojiWithId:(NSInteger)emojiId inGroup:(NSInteger)groupId {
    for (EmojiGroup *group in self.emojiGroupsArray) {
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

@end 