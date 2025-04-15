//
//  MessageModel.m
//  test1.0
//
//  Created by heiqi on 2025/4/8.
//

#import "MessageModel.h"

@implementation MessageModel

+ (instancetype)messageWithContent:(NSString *)content type:(MessageType)type {
    MessageModel *message = [[MessageModel alloc] init];
    message.messageId = [[NSUUID UUID] UUIDString];
    message.content = content;
    message.type = type;
    message.timestamp = [NSDate date];
    message.isTranslated = NO;
    message.translatedContent = @"fanyijieguo";
    return message;
}

+ (instancetype)recommendMessageWithContent:(NSString *)content recommendId:(NSString *)recommendId {
    MessageModel *message = [self messageWithContent:content type:MessageTypeRecommend];
    message.recommendId = recommendId;
    return message;
}

@end
