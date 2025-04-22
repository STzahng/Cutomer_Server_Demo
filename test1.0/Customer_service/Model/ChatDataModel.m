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
            @"4.征服赛季规则",
            @"5.图文测试",
            @"6.图文测试2"
        ];
        
        _recommendAnswers = @{
            @"1": @"购买代币的步骤如下：\n1. 进入游戏商城\n2. 选择代币类型\n3. 选择支付方式\n4. 确认购买",
            @"2": @"登录问题解决方案：\n1. 检查网络连接\n2. 确认账号密码正确\n3. 尝试重新登录\n4. 如仍无法解决，请联系客服",
            @"3": @"礼包未收到处理方案：\n1. 检查支付是否成功\n2. 查看邮箱是否收到\n3. 检查背包物品\n4. 联系客服提供订单号",
            @"4": @"征服赛季规则说明：\n1. 赛季持续30天加长文本加长文本加长文本加长文本加长文本加长文本\n2. 根据积分排名\n3. 赛季结束发放奖励\n4. 新赛季自动开始",
            @"5": @"how to get more\n#image[http://test-eastblue.xinyoudi.com/uploads//image_(1)_67e21f82cdc81.png]{w:634,h:1069} \n 结尾",
            @"6":@"#image[https://pic4.zhimg.com/v2-91bb05348ab07dfb748bf0d34c84af5b_1440w.jpg]{w:600,h:400}"
        };
        
        _searchQuestions = @[
            @"如何购买游戏代币",
            @"登录遇到问题怎么办",
            @"支付购买礼包未收到怎么办",
            @"征服赛季规则说明",
            @"账号被盗如何找回",
            @"游戏闪退问题解决",
            @"如何绑定手机号",
            @"充值未到账处理",
            @"游戏更新失败怎么办",
            @"如何修改密码",
            @"账号被封禁申诉",
            @"游戏内举报功能使用",
            @"如何查看游戏公告",
            @"游戏内BUG反馈",
            @"如何联系游戏客服",
            @"游戏内交易问题",
            @"如何查看充值记录",
            @"游戏内活动参与方式",
            @"如何查看游戏攻略",
            @"游戏内道具使用说明"
        ];
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

- (NSArray<NSString *> *)searchQuestionsWithKeyword:(NSString *)keyword {
    if (keyword.length == 0) {
        return _recommendQuestions;
    }
    
    NSMutableArray *matchedQuestions = [NSMutableArray array];
    for (NSString *question in self.searchQuestions) {
        if ([question rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound) {
            NSLog(question);
            [matchedQuestions addObject:question];
        }
        if(matchedQuestions.count > 4){
            break;
        }
    }
    return matchedQuestions;
}

@end
