//
//  EmojiManager.h
//  test1.0
//
//  Created by heiqi on 2025/4/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Emoji组模型
@interface EmojiGroup : NSObject

@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) NSMutableArray *emojis; // 存储EmojiItem对象

@end

// 单个Emoji项模型
@interface EmojiItem : NSObject

@property (nonatomic, assign) NSInteger emojiId;
@property (nonatomic, copy) NSString *imgName;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isDownloaded;

@end

// Emoji管理器
@interface EmojiManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<EmojiGroup *> *emojiGroups;
@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, copy) void (^onEmojiLoadingComplete)(BOOL success);

+ (instancetype)sharedInstance;

// 从JSON数据中解析Emoji信息
- (void)parseEmojiGroupsFromJSON:(NSDictionary *)jsonData;

// 下载所有Emoji图片资源
- (void)downloadAllEmojiResources;

// 获取特定组中的所有Emoji
- (NSArray<EmojiItem *> *)emojisInGroup:(NSInteger)groupId;

// 根据ID获取Emoji
- (nullable EmojiItem *)emojiWithId:(NSInteger)emojiId inGroup:(NSInteger)groupId;

// 清除所有数据
- (void)clearAllData;

@end

NS_ASSUME_NONNULL_END 