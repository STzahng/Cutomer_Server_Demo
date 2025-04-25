//
//  EmojiViewModel.h
//  test1.0
//
//  Created by heiqi on 2025/4/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmojiViewModel : NSObject

// emoji组数据
@property (nonatomic, strong, readonly) NSArray *emojiGroups;

// emoji数据是否加载完成
@property (nonatomic, assign, readonly) BOOL emojiDataLoaded;

// 资源基础URL
@property (nonatomic, copy, readonly) NSString *resourceBaseURL;

// 头像资源基础URL
@property (nonatomic, copy, readonly) NSString *avatarResourceBaseURL;

// 表情加载状态改变回调
@property (nonatomic, copy, nullable) void (^onEmojiDataStatusChanged)(BOOL isLoaded);

// 单例方法
+ (instancetype)sharedInstance;

// 从setChatResources消息中解析emoji数据
- (void)parseEmojiDataFromMessage:(NSDictionary *)message;

// 获取特定组中的所有Emoji
- (NSArray *)emojisInGroup:(NSInteger)groupId;

// 获取所有表情组
- (NSArray *)allEmojiGroups;

// 下载指定组的所有emoji资源
- (void)downloadResourcesForGroupId:(NSInteger)groupId;

// 下载所有emoji资源
- (void)downloadAllResources;

// 获取完整的emoji图片URL
- (NSString *)fullURLForEmojiImage:(NSString *)imageName;

// 根据图片名获取已下载的表情图片
- (nullable UIImage *)imageForEmojiWithName:(NSString *)imageName;

// 注册表情图片更新回调
- (void)registerForImageUpdateWithBlock:(void(^)(NSString *imageName, UIImage *image))updateBlock;

@end

NS_ASSUME_NONNULL_END 