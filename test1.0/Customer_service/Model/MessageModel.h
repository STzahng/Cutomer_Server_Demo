//
//  MessageModel.h
//  test1.0
//
//  Created by heiqi on 2025/4/8.
//
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MessageType) {
    MessageTypeUser,
    MessageTypeSystem,
    MessageTypeRecommend,
    MessageTypeEvaluate,
    MessageTypeGrade,
};

@interface MessageModel : NSObject

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) MessageType type;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, copy) NSString *recommendId; // 如果是推荐消息，存储推荐ID
@property (nonatomic, assign) BOOL isTranslated;
@property (nonatomic, copy) NSString *translatedContent;
@property (nonatomic, assign) NSInteger starRating;
@property (nonatomic, copy) NSString *resolutionState; // @"unselected"/@"solved"/@"unsolved"
@property (nonatomic, assign) BOOL hasEvaluated; 


+ (instancetype)messageWithContent:(NSString *)content type:(MessageType)type;
+ (instancetype)recommendMessageWithContent:(NSString *)content recommendId:(NSString *)recommendId;

@end
