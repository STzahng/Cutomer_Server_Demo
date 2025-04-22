//
//  MessageViewModel.h
//  test1.0
//
//  Created by heiqi on 2025/5/11.
//

#import <Foundation/Foundation.h>
#import "MessageModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 消息ViewModel协议，用于处理消息Cell与数据的交互
 */
@protocol MessageViewModelDelegate <NSObject>

/**
 * 当图片加载完成时通知代理
 * @param messageId 消息ID
 * @param url 图片URL
 * @param image 加载完成的图片
 */
- (void)didLoadImage:(UIImage *)image forURL:(NSString *)url inMessageId:(NSString *)messageId;

@end

/**
 * 消息ViewModel，用于处理消息数据和视图之间的交互
 */
@interface MessageViewModel : NSObject

/**
 * 代理对象
 */
@property (nonatomic, weak) id<MessageViewModelDelegate> delegate;

/**
 * 消息数据
 */
@property (nonatomic, readonly) NSArray<MessageModel *> *messages;

/**
 * 初始化方法
 */
- (instancetype)init;

/**
 * 添加一条消息
 * @param message 消息模型
 */
- (void)addMessage:(MessageModel *)message;

/**
 * 获取指定索引的消息
 * @param index 索引
 * @return 消息模型
 */
- (MessageModel *)messageAtIndex:(NSInteger)index;

/**
 * 获取消息数量
 * @return 消息数量
 */
- (NSInteger)messageCount;

/**
 * 根据消息ID获取消息
 * @param messageId 消息ID
 * @return 消息模型，不存在则返回nil
 */
- (nullable MessageModel *)messageWithId:(NSString *)messageId;

/**
 * 请求加载指定消息的图片
 * @param messageId 消息ID
 */
- (void)loadImagesForMessageId:(NSString *)messageId;

@end

NS_ASSUME_NONNULL_END 