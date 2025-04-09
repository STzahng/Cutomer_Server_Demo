#import "ChatViewModel.h"

@interface ChatViewModel ()

@property (nonatomic, strong) ChatDataModel *dataModel;

@end

@implementation ChatViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataModel = [[ChatDataModel alloc] init];
    }
    return self;
}

- (void)sendMessage:(NSString *)content {
    MessageModel *message = [MessageModel messageWithContent:content type:MessageTypeUser];
    [self.dataModel addMessage:message];
    [self notifyDelegate];
}

- (void)handleRecommendTap:(NSString *)recommendId {
    NSString *answer = [self.dataModel getAnswerForRecommendId:recommendId];
    NSString *question = [self.dataModel getQuestionForRecommendId:recommendId];
    if (answer) {
        MessageModel *message = [MessageModel messageWithContent:question type:MessageTypeUser];
        MessageModel *messageToMe = [MessageModel messageWithContent:answer type:MessageTypeSystem];
        [self.dataModel addMessage:message];
        [self.dataModel addMessage:messageToMe];
        [self notifyDelegate];
    }
}

- (NSArray<MessageModel *> *)getAllMessages {
    return [self.dataModel.messages copy];
}

- (NSArray<NSString *> *)getRecommendQuestions {
    return self.dataModel.recommendQuestions;
}

- (void)notifyDelegate {
    if ([self.delegate respondsToSelector:@selector(chatViewModel:didUpdateMessages:)]){
        [self.delegate chatViewModel:self didUpdateMessages:[self getAllMessages]];
    }
}

@end 
