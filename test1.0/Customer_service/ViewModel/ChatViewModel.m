#import "ChatViewModel.h"

@interface ChatViewModel ()

@property (nonatomic, strong) ChatDataModel *dataModel;
@property (nonatomic, strong) NSTimer *evaluationTimer;

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
    [self resetEvaluationTimer];
    
    [self notifyDelegate];
}

- (void)handleRecommendTap:(NSString *)recommendId {
    NSString *answer = [self.dataModel getAnswerForRecommendId:recommendId];
    NSString *question = [self.dataModel getQuestionForRecommendId:recommendId];
    [self resetEvaluationTimer];
    if ([recommendId integerValue] > 4){
        MessageModel *message = [MessageModel messageWithContent:question type:MessageTypeUser];
        MessageModel *messageToMe = [MessageModel messageWithContent:answer type:MessageTypeImageText];
        [self.dataModel addMessage:message];
        [self.dataModel addMessage:messageToMe];
        [self notifyDelegate];
        return;
    }
    if (answer) {
        MessageModel *message = [MessageModel messageWithContent:question type:MessageTypeUser];
        MessageModel *messageToMe = [MessageModel messageWithContent:answer type:MessageTypeSystem];
        [self.dataModel addMessage:message];
        [self.dataModel addMessage:messageToMe];
        [self notifyDelegate];
    }
}

- (void)handleserach:(NSString *)serachquestion{
    MessageModel *message = [MessageModel messageWithContent:serachquestion type:MessageTypeUser];
    MessageModel *messageToMe = [MessageModel messageWithContent:@"仅测试环境下回复"type:MessageTypeSystem];
    [self.dataModel addMessage:message];
    [self.dataModel addMessage:messageToMe];
    [self resetEvaluationTimer];
    [self notifyDelegate];
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
// 发送评价对话框消息
- (void)sendEvaluateMessageAfterResponse {
    MessageModel *evaluateMessage = [MessageModel messageWithContent:@"请对我们的回复进行评价" type:MessageTypeEvaluate];
    evaluateMessage.resolutionState = @"unselected"; // 初始状态为未选择
    [self.dataModel addMessage:evaluateMessage];
    [self notifyDelegate];
}

- (void)sendGradeMessageAfterResponse {
    MessageModel *gradeMessage = [MessageModel messageWithContent:@"请对人工客服进行评价" type:MessageTypeGrade];
    gradeMessage.starRating = 3; // 初始评分为0
    [self.dataModel addMessage:gradeMessage];
    [self notifyDelegate];
}
- (void)sendActivityMessageAfterResponse {
    MessageModel *activeMessage = [MessageModel messageWithContent:@"In the game, players explore the colwinter ice field in the ~ OCR by Picview!" type:MessageTypeActivity];
    [self.dataModel addMessage:activeMessage];
    [self notifyDelegate];
}
// 处理评分更新
- (void)updateGradeForMessage:(MessageModel *)message withStarRating:(NSInteger)starRating {
    if (message && message.type == MessageTypeGrade) {
        message.starRating = starRating;
        // 这里可以添加保存到服务器的逻辑
        NSLog(@"评分已更新为: %ld", (long)starRating);
        [self notifyDelegate]; // 通知 UI 刷新
    }
}

// 处理评价更新
- (void)updateEvaluateForMessage:(MessageModel *)message withResolutionState:(NSString *)state {
    if (message && message.type == MessageTypeEvaluate) {
        message.resolutionState = state;
        message.hasEvaluated = YES;
        // 这里可以添加保存到服务器的逻辑
        NSLog(@"问题解决状态已更新为: %@", state);
        [self notifyDelegate]; // 通知 UI 刷新
    }
}
- (void)updateAllmessage {
    [self notifyDelegate]; 
}

- (void)handleMessageUpdated:(MessageModel *)message {
    NSLog(@"ViewModel处理消息更新，消息ID: %@", message.messageId);
   // [self notifyDelegate];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewModel:didUpdateMessages:)]) {
        // 注意：这里只传递单个消息，如果需要传递所有消息，请修改为获取所有消息的调用
        [self.delegate chatViewModel:self didUpdateMessages:@[message]];
    }
}

#pragma mark - 定时器相关方法

- (void)startEvaluationTimer {
    [self stopEvaluationTimer]; // 先停止已有定时器
    
    // 创建新的10秒定时器
    self.evaluationTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                           target:self
                                                         selector:@selector(evaluationTimerExpired)
                                                         userInfo:nil
                                                          repeats:NO];
    NSLog(@"评价定时器已启动，10秒后触发");
}

- (void)stopEvaluationTimer {
    if (self.evaluationTimer && [self.evaluationTimer isValid]) {
        [self.evaluationTimer invalidate];
        self.evaluationTimer = nil;
        NSLog(@"评价定时器已停止");
    }
}

- (void)resetEvaluationTimer {
    // 只有在用户消息后才启动/重置定时器，而不是所有非用户消息
    [self startEvaluationTimer];
    NSLog(@"评价定时器已重置");
}

- (void)evaluationTimerExpired {
    NSLog(@"评价定时器触发，发送评价消息");
    
    // 发送评价消息和评分消息
    [self sendEvaluateMessageAfterResponse];
    [self sendGradeMessageAfterResponse];
    
    // 停止定时器，等待用户回复后再次启动
    [self stopEvaluationTimer];
}

@end
