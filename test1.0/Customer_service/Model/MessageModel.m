//
//  MessageModel.m
//  test1.0
//
//  Created by heiqi on 2025/4/8.
//

#import "MessageModel.h"

@implementation ImageInfo

+ (instancetype)imageInfoWithURL:(NSString *)url width:(CGFloat)width height:(CGFloat)height index:(NSInteger)index {
    ImageInfo *info = [[ImageInfo alloc] init];
    info.imageURL = url;
    info.width = width;
    info.height = height;
    info.index = index;
    return info;
}

@end

@implementation MessageModel

+ (instancetype)messageWithContent:(NSString *)content type:(MessageType)type {
    MessageModel *message = [[MessageModel alloc] init];
    message.content = content;
    message.type = type;
    message.timestamp = [NSDate date];
    message.messageId = [[NSUUID UUID] UUIDString];
    message.isImageTextLoaded = NO;
    
    // 如果是图文消息，自动解析图片信息
    if (type == MessageTypeImageText) {
        [message parseImageTextContent];
    }
    
    return message;
}

+ (instancetype)recommendMessageWithContent:(NSString *)content recommendId:(NSString *)recommendId {
    MessageModel *message = [self messageWithContent:content type:MessageTypeRecommend];
    message.recommendId = recommendId;
    return message;
}

- (void)parseImageTextContent {
    if (self.type != MessageTypeImageText || !self.content) {
        return;
    }
    
    // 使用正则表达式识别图片标记：#image[URL]{w:width,h:height}
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#image\\[(.*?)\\]\\{w:(\\d+),h:(\\d+)\\}"
                                                                          options:0
                                                                            error:&error];
    if (error) {
        NSLog(@"正则表达式错误: %@", error);
        return;
    }
    
    NSString *content = self.content;
    NSArray *matches = [regex matchesInString:content
                                      options:0
                                        range:NSMakeRange(0, content.length)];
    
    // 如果没有找到图片标记，不做处理
    if (matches.count == 0) {
        self.processedTextContent = content;
        self.imageInfos = @[];
        return;
    }
    
    // 提取图片信息
    NSMutableArray<ImageInfo *> *imageInfos = [NSMutableArray array];
    NSMutableString *processedText = [NSMutableString stringWithString:content];
    
    // 从后向前替换，避免索引变化
    for (NSInteger i = matches.count - 1; i >= 0; i--) {
        NSTextCheckingResult *match = matches[i];
        
        // 提取URL和尺寸
        NSString *imageUrl = [content substringWithRange:[match rangeAtIndex:1]];
        CGFloat width = [[content substringWithRange:[match rangeAtIndex:2]] floatValue];
        CGFloat height = [[content substringWithRange:[match rangeAtIndex:3]] floatValue];
        
        // 创建图片信息对象
        ImageInfo *info = [ImageInfo imageInfoWithURL:imageUrl width:width height:height index:i];
        [imageInfos addObject:info];
        
        // 替换文本中的图片标记为占位符
        NSString *placeholder = [NSString stringWithFormat:@"[图片%ld]", (long)i];
        [processedText replaceCharactersInRange:match.range withString:placeholder];
    }
    
    // 因为是从后向前处理的，需要逆序图片信息数组
    NSArray *reversedInfos = [[imageInfos reverseObjectEnumerator] allObjects];
    
    self.imageInfos = reversedInfos;
    self.processedTextContent = processedText;
}

@end
