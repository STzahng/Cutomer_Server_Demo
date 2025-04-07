//
//  MessageModel.h
//  test1.0
//
//  Created by heiqi on 2025/4/3.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeUser,      // 用户消息
    MessageTypeService,   // 客服消息
    MessageTypeSystem,    // 系统消息
    MessageTypeAutoReply  // 自动回复
};

@interface MessageModel : NSObject

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *translatedContent;
@property (nonatomic, assign) MessageType type;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) BOOL isTranslated;

@end
