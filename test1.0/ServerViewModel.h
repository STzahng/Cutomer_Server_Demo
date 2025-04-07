//
//  ServerViewModel.h
//  test1.0
//
//  Created by heiqi on 2025/4/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServerViewModel : NSObject

@end

NS_ASSUME_NONNULL_END
#import <Foundation/Foundation.h>
#import "MessageModel.h"
#import "FAQModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomerServiceViewModel : NSObject

@property (nonatomic, strong, readonly) NSArray<MessageModel *> *messages;
@property (nonatomic, strong, readonly) NSArray<FAQModel *> *faqList;
@property (nonatomic, strong, readonly) NSArray<FAQModel *> *suggestedQuestions;

// 发送消息
- (void)sendMessage:(NSString *)content completion:(void(^)(BOOL success))completion;

// 获取FAQ列表
- (void)loadFAQList:(void(^)(BOOL success))completion;

// 根据关键字搜索FAQ
- (void)searchFAQWithKeyword:(NSString *)keyword completion:(void(^)(NSArray<FAQModel *> *results))completion;

// 翻译消息
- (void)translateMessage:(MessageModel *)message completion:(void(^)(NSString *translatedText))completion;

// 加载自动回复
- (void)loadAutoReply:(void(^)(NSArray<FAQModel *> *autoReplies))completion;

@end

NS_ASSUME_NONNULL_END
