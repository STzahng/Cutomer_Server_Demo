#import <Foundation/Foundation.h>
#import "MessageModel.h"
#import "ChatDataModel.h"

@class ChatViewModel;

@protocol ChatViewModelDelegate <NSObject>

- (void)chatViewModel:(ChatViewModel *)viewModel didUpdateMessages:(NSArray<MessageModel *> *)messages;
- (void)chatViewModel:(ChatViewModel *)viewModel didReceiveError:(NSError *)error;

@end

@interface ChatViewModel : NSObject

@property (nonatomic, weak) id<ChatViewModelDelegate> delegate;
@property (nonatomic, strong, readonly) ChatDataModel *dataModel;

- (void)sendMessage:(NSString *)content;
- (void)handleRecommendTap:(NSString *)recommendId;
- (void)handleserach:(NSString *)serachquestion;
- (NSArray<MessageModel *> *)getAllMessages;
- (NSArray<NSString *> *)getRecommendQuestions;
- (void)sendEvaluateMessageAfterResponse;
- (void)sendGradeMessageAfterResponse;
- (void)sendActivityMessageAfterResponse;
- (void)updateGradeForMessage:(MessageModel *)message withStarRating:(NSInteger)starRating;
- (void)updateEvaluateForMessage:(MessageModel *)message withResolutionState:(NSString *)state;
- (void)updateAllmessage;
- (void)handleMessageUpdated:(MessageModel *)message;

- (void)startEvaluationTimer;
- (void)stopEvaluationTimer;
- (void)resetEvaluationTimer;
- (void)evaluationTimerExpired;

/**
 * 处理消息更新事件，当消息（特别是图片等资源）加载完成后被调用
 * @param message 已更新的消息模型
 */
- (void)handleMessageUpdated:(MessageModel *)message;

@end
