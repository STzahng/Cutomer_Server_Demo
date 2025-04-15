#import "ChatDataModel.h"

@implementation ChatDataModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _messages = [NSMutableArray array];
        _recommendQuestions = @[
            @"1.如何购买代币",
            @"2.登录遇到问题怎么办",
            @"3.支付购买礼包未收到怎么办",
            @"4.征服赛季规则"
        ];
        
        _recommendAnswers = @{
            @"1": @"购买代币的步骤如下：\n1. 进入游戏商城\n2. 选择代币类型\n3. 选择支付方式\n4. 确认购买",
            @"2": @"登录问题解决方案：\n1. 检查网络连接\n2. 确认账号密码正确\n3. 尝试重新登录\n4. 如仍无法解决，请联系客服",
            @"3": @"礼包未收到处理方案：\n1. 检查支付是否成功\n2. 查看邮箱是否收到\n3. 检查背包物品\n4. 联系客服提供订单号",
            @"4": @"征服赛季规则说明：\n1. 赛季持续30天加长文本加长文本加长文本加长文本加长文本加长文本\n2. 根据积分排名\n3. 赛季结束发放奖励\n4. 新赛季自动开始"
        };
    }
    return self;
}

- (void)addMessage:(MessageModel *)message {
    [self.messages addObject:message];
}

- (void)clearMessages {
    [self.messages removeAllObjects];
}

- (NSString *)getAnswerForRecommendId:(NSString *)recommendId {
    return self.recommendAnswers[recommendId];
}

- (NSString *)getQuestionForRecommendId:(NSString *)recommendId {
    return [self.recommendQuestions objectAtIndex:[recommendId integerValue] - 1];
}
@end
