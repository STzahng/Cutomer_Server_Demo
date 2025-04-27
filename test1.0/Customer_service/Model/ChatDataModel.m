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
            @"4.url跳转测试",
            @"5.图文测试",
            @"6.url跳转测试"
        ];
        
        _recommendAnswers = @{
            @"1": @"购买代币的步骤如下：\n1. 进入游戏商城\n2. 选择代币类型\n3. 选择支付方式\n4. 确认购买",
            @"2": @"登录问题解决方案：\n1. 检查网络连接\n2. 确认账号密码正确\n3. 尝试重新登录\n4. 如仍无法解决，请联系客服",
            @"3": @"礼包未收到处理方案：\n1. 检查支付是否成功\n2. 查看邮箱是否收到\n3. 检查背包物品\n4. 联系客服提供订单号",
            @"4": @"接下来是URL跳转测试@点击跳转网址:\"https://bot.n.cn/chat/f57d27ae8ba14255816dbf2ae9ebb994\" 同时检测如果出现多个url文本能否正常使用，@另一个链接:\"https://blog.csdn.net/qq_63884623?type=blog\"",
            @"5": @"how to get more\n#image[http://test-eastblue.xinyoudi.com/uploads//image_(1)_67e21f82cdc81.png]{w:634,h:1069} \n 结尾",
            @"6":@"@点击跳转网址:\"https://www.cnblogs.com/sundaysgarden/p/13232967.html\"后续的文字显示"
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
