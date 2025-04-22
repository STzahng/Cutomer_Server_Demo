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
    MessageTypeActivity,
    MessageTypeImageText,
};

// 图片信息结构体，用于存储图片的URL和尺寸
@interface ImageInfo : NSObject

@property (nonatomic, copy) NSString *imageURL;    // 图片URL
@property (nonatomic, assign) CGFloat width;       // 图片宽度
@property (nonatomic, assign) CGFloat height;      // 图片高度
@property (nonatomic, assign) NSInteger index;     // 图片在文本中的索引位置

+ (instancetype)imageInfoWithURL:(NSString *)url width:(CGFloat)width height:(CGFloat)height index:(NSInteger)index;

@end

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

// 图片相关的属性
@property (nonatomic, strong) NSArray<ImageInfo *> *imageInfos;   // 消息中包含的图片信息
@property (nonatomic, copy) NSString *processedTextContent;       // 处理后的纯文本内容（替换了图片标记的）

// 图片文本处理相关方法
- (void)parseImageTextContent;  // 解析消息内容中的图片标记，提取图片信息

+ (instancetype)messageWithContent:(NSString *)content type:(MessageType)type;
+ (instancetype)recommendMessageWithContent:(NSString *)content recommendId:(NSString *)recommendId;

@end
