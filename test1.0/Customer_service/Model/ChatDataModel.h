#import <Foundation/Foundation.h>
#import "MessageModel.h"

@interface ChatDataModel : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<MessageModel *> *messages;
@property (nonatomic, strong, readonly) NSArray<NSString *> *recommendQuestions;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *recommendAnswers;

- (void)addMessage:(MessageModel *)message;
- (void)clearMessages;
- (NSString *)getAnswerForRecommendId:(NSString *)recommendId;

@end 