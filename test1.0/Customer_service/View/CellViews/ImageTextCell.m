//
//  imageTextCell.m
//  test1.0
//
//  Created by heiqi on 2025/4/18.
//

#import "ImageTextCell.h"
#import "ScreenScaling.h"

@interface ImageTextCell ()

@property (nonatomic, strong) UIImageView *headpic;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIImageView *bubbleImage;

// 添加属性用于跟踪当前消息和下载任务
@property (nonatomic, strong) NSMutableArray<NSURLSessionDataTask *> *downloadTasks;
@property (nonatomic, assign) NSInteger pendingImageCount; // 添加计数器跟踪待加载图片
@property (nonatomic, strong) NSMutableArray *loadedImages; // 存储已加载的图片信息

@end

@implementation ImageTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _downloadTasks = [NSMutableArray array];
        _loadedImages = [NSMutableArray array];
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self cancelAllDownloads]; // 取消所有下载任务
    _messageTextView.text = @"";
    _messageTextView.attributedText = nil;
    self.currentMessage = nil;
    self.pendingImageCount = 0;
    [self.loadedImages removeAllObjects];
    
    // 重置气泡布局
    [_bubbleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(10));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(11));
        make.right.equalTo(_messageTextView.mas_right).offset(13);
        make.bottom.equalTo(_messageTextView.mas_bottom).offset(16);
        make.bottom.equalTo(self.contentView).offset(-JSHeight(20));
    }];
}

// 取消所有下载任务的辅助方法
- (void)cancelAllDownloads {
    for (NSURLSessionDataTask *task in self.downloadTasks) {
        [task cancel];
    }
    [self.downloadTasks removeAllObjects];
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 创建头像
    _headpic = [[UIImageView alloc] init];
    [_headpic setImage:[UIImage imageNamed:@"img_chat_head"]];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.text = @"GM";
    _nameLabel.font = [UIFont systemFontOfSize:17];
    _nameLabel.textColor = [UIColor whiteColor];
    
    _bubbleImage = [[UIImageView alloc] init];
    UIImage *bubbleImage = [UIImage imageNamed:@"bg_chat_message2"];
    // 设置9宫格拉伸区域，这里假设气泡图片的边角区域为20像素
    UIEdgeInsets insets = UIEdgeInsetsMake(28, 15, 7, 10);
    _bubbleImage.image = [bubbleImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    _messageTextView = [[UITextView alloc] init];
    _messageTextView.backgroundColor = [UIColor clearColor];
    _messageTextView.textColor = [UIColor whiteColor];
    _messageTextView.font = [UIFont systemFontOfSize:16];
    _messageTextView.editable = NO;
    _messageTextView.scrollEnabled = NO;
    _messageTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _messageTextView.textContainer.lineFragmentPadding = 0;

    
    [self.contentView addSubview:_bubbleImage];
    [self.contentView addSubview:_messageTextView];
    [self.contentView addSubview:_headpic];
    [self.contentView addSubview:_nameLabel];
}

- (void)setupConstraints {
    [_headpic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(JSWidth(28)));
        make.top.equalTo(self.contentView);
        make.width.height.equalTo(@(JSWidth(135)));
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(35));
        make.top.equalTo(self.contentView).offset(JSHeight(13));
        make.height.equalTo(@(JSHeight(30)));
    }];
    
    [_messageTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(65));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(40));
        make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-JSWidth(237));
    }];

    [_bubbleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(10));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(11));
        make.right.equalTo(_messageTextView.mas_right).offset(13);
        make.bottom.equalTo(_messageTextView.mas_bottom).offset(16);
        make.bottom.equalTo(self.contentView).offset(-JSHeight(20));
    }];
}

// 异步加载消息内容
- (void)configureWithMessage:(MessageModel *)message {
    // 保存当前消息模型
    self.currentMessage = message;
    
    // 先取消所有正在进行的下载任务
    [self cancelAllDownloads];
    [self.loadedImages removeAllObjects];
    
    // 先设置纯文本内容，保证界面可以显示
    _messageTextView.text = message.content;
    
    // 处理富文本内容
    [self parseMessageContent:message.content];
}

#pragma mark - 图文混排消息处理

// 解析文本并异步加载图片
- (void)parseMessageContent:(NSString *)content {
    // 正则表达式来识别图片标记
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#image\\[(.*?)\\]\\{w:(\\d+),h:(\\d+)\\}"
                                                                          options:0
                                                                            error:&error];
    if (error) {
        NSLog(@"正则表达式错误: %@", error);
        return;
    }
    
    NSArray *matches = [regex matchesInString:content
                                      options:0
                                        range:NSMakeRange(0, content.length)];
    
    // 如果没有图片标记，直接显示纯文本
    if (matches.count == 0) {
        NSMutableAttributedString *plainText = [[NSMutableAttributedString alloc] initWithString:content];
        [plainText addAttributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:16],
            NSForegroundColorAttributeName: [UIColor whiteColor]
        } range:NSMakeRange(0, content.length)];
        
        _messageTextView.attributedText = plainText;
        return;
    }
    
    // 处理纯文本部分，替换图片标记为占位符
    NSMutableString *textOnlyContent = [NSMutableString stringWithString:content];
    for (NSInteger i = matches.count - 1; i >= 0; i--) {
        NSTextCheckingResult *match = matches[i];
        [textOnlyContent replaceCharactersInRange:match.range withString:@"[图片加载中]"];
    }
    
    // 先显示没有图片的文本
    _messageTextView.text = textOnlyContent;
    
    // 设置待加载图片计数
    self.pendingImageCount = matches.count;
    
    // 为每个图片创建一个加载位置标记
    NSMutableArray *placeholderPositions = [NSMutableArray array];
    for (NSInteger i = 0; i < matches.count; i++) {
        [placeholderPositions addObject:@(i)];
    }
    
    // 异步加载每个图片
    for (NSInteger i = 0; i < matches.count; i++) {
        NSTextCheckingResult *match = matches[i];
        NSString *imageUrl = [content substringWithRange:[match rangeAtIndex:1]];
        NSInteger width = [[content substringWithRange:[match rangeAtIndex:2]] integerValue];
        NSInteger height = [[content substringWithRange:[match rangeAtIndex:3]] integerValue];
        
        // 计算图片显示尺寸
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - JSWidth(237 + 65 + 28 + 135 + 10);
        CGFloat aspectRatio = (CGFloat)height / (CGFloat)width;
        CGFloat displayWidth = MIN(width, maxWidth);
        CGFloat displayHeight = displayWidth * aspectRatio;
        
        // 使用简单的异步加载方式
        NSURLSessionDataTask *task = [self downloadImageWithURL:[NSURL URLWithString:imageUrl] completion:^(UIImage *image) {
            // 确保Cell没有被复用
            if (image && self.currentMessage) {
                // 创建图片附件
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = image;
                attachment.bounds = CGRectMake(0, 0, displayWidth, displayHeight);
                
                // 保存加载成功的图片信息
                @synchronized(self) {
                    [self.loadedImages addObject:@{
                        @"index": @(i),
                        @"attachment": attachment
                    }];
                    
                    // 减少待加载计数
                    self.pendingImageCount--;
                    
                    // 如果所有图片都已加载，更新UI
                    if (self.pendingImageCount == 0) {
                        [self updateUIWithAllImages];
                    }
                }
            } else {
                // 图片加载失败，也减少计数
                @synchronized(self) {
                    self.pendingImageCount--;
                    if (self.pendingImageCount == 0) {
                        [self updateUIWithAllImages];
                    }
                }
            }
        }];
        
        // 保存下载任务便于取消
        if (task) {
            [self.downloadTasks addObject:task];
        }
    }
}

// 所有图片加载完成后更新UI
- (void)updateUIWithAllImages {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 排序已加载的图片，确保顺序正确
        [self.loadedImages sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1[@"index"] compare:obj2[@"index"]];
        }];
        
        // 重新构建带图片的文本
        NSMutableAttributedString *finalText = [[NSMutableAttributedString alloc] init];
        NSString *currentText = self.messageTextView.text;
        
        // 替换每个占位符为实际图片
        for (NSDictionary *imageInfo in self.loadedImages) {
            NSTextAttachment *attachment = imageInfo[@"attachment"];
            NSRange placeholderRange = [currentText rangeOfString:@"[图片加载中]"];
            
            if (placeholderRange.location != NSNotFound) {
                // 分割文本：占位符前 + 图片 + 占位符后
                NSString *textBeforePlaceholder = [currentText substringToIndex:placeholderRange.location];
                NSString *textAfterPlaceholder = [currentText substringFromIndex:placeholderRange.location + placeholderRange.length];
                
                // 添加占位符前的文本
                NSAttributedString *beforeText = [[NSAttributedString alloc] initWithString:textBeforePlaceholder attributes:@{
                    NSFontAttributeName: [UIFont systemFontOfSize:16],
                    NSForegroundColorAttributeName: [UIColor whiteColor]
                }];
                [finalText appendAttributedString:beforeText];
                
                // 添加图片
                NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:attachment];
                [finalText appendAttributedString:imageString];
                
                // 更新当前文本为剩余部分
                currentText = textAfterPlaceholder;
            }
        }
        
        // 添加最后剩余的文本
        if (currentText.length > 0) {
            NSAttributedString *afterText = [[NSAttributedString alloc] initWithString:currentText attributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:16],
                NSForegroundColorAttributeName: [UIColor whiteColor]
            }];
            [finalText appendAttributedString:afterText];
        }
        
        // 设置最终文本
        self.messageTextView.attributedText = finalText;
        //NSLog(finalText);
        // 确保重新布局气泡

        [self.bubbleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headpic.mas_right).offset(JSWidth(10));
            make.top.equalTo(self.nameLabel.mas_bottom).offset(JSHeight(11));
            make.right.equalTo(self.messageTextView.mas_right).offset(13);
            make.bottom.equalTo(self.messageTextView.mas_bottom).offset(16);
            make.bottom.equalTo(self.contentView).offset(-JSHeight(20));
        }];
        
        // 强制立即布局
        [self setNeedsLayout];
        [self layoutIfNeeded];
    });
}

// 简单的图片下载方法
- (NSURLSessionDataTask *)downloadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image))completion {
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // 从下载任务列表中移除
        [self.downloadTasks removeObject:task];
        
        // 只在没有错误且有数据时处理图片
        if (!error && data) {
            UIImage *image = [UIImage imageWithData:data];
            if (completion && image) {
                completion(image);
            } else {
                // 图片创建失败也回调
                completion(nil);
            }
        } else {
            // 网络错误也回调
            completion(nil);
        }
    }];
    
    [task resume];
    return task;
}

@end

