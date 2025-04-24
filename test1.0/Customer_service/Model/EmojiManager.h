#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmojiItem : NSObject

@property (nonatomic, assign) NSInteger emojiId;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, assign) NSInteger groupId;

@end

@interface EmojiGroup : NSObject

@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, strong) NSMutableArray<EmojiItem *> *emojis;

@end

typedef void(^EmojiCompletionBlock)(BOOL success);

@interface EmojiManager : NSObject

@property (nonatomic, readonly) NSArray<EmojiGroup *> *emojiGroups;

/**
 * 解析并下载表情资源
 * @param resourcesData 包含表情资源信息的字典
 * @param completion 完成回调
 */
- (void)parseAndDownloadEmojiResources:(NSDictionary *)resourcesData completion:(EmojiCompletionBlock)completion;

/**
 * 获取指定分组的所有表情
 * @param groupId 分组ID
 * @return 表情数组
 */
- (NSArray<EmojiItem *> *)emojisInGroup:(NSInteger)groupId;

/**
 * 根据ID查找指定分组中的表情
 * @param emojiId 表情ID
 * @param groupId 分组ID
 * @return 表情对象
 */
- (nullable EmojiItem *)findEmojiWithId:(NSInteger)emojiId inGroup:(NSInteger)groupId;

@end

NS_ASSUME_NONNULL_END 