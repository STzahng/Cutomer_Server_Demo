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
- (NSArray<MessageModel *> *)getAllMessages;
- (NSArray<NSString *> *)getRecommendQuestions;

@end 