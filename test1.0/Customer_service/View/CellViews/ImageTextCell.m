//
//  ImageTextCell.m
//  test1.0
//
//  Created by heiqi on 2025/4/18.
//

#import "ImageTextCell.h"
#import "ScreenScaling.h"
#import "ImageCacheService.h"

@interface ImageTextCell ()

@property (nonatomic, strong) UIImageView *headpic;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIImageView *bubbleImage;

// 当前消息ID，用于跟踪Cell生命周期中正在显示的消息
@property (nonatomic, copy, readwrite) NSString *messageIdentifier;
// 未加载完成的图片URL
@property (nonatomic, strong) NSMutableSet<NSString *> *pendingImageURLs;
// 已加载的图片缓存
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *loadedImages;
// 加载失败的图片URL
@property (nonatomic, strong) NSMutableSet<NSString *> *failedImageURLs;

@end

@implementation ImageTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _pendingImageURLs = [NSMutableSet set];
        _loadedImages = [NSMutableDictionary dictionary];
        _failedImageURLs = [NSMutableSet set];
        [self setupUI];
        [self setupConstraints];
        
        NSLog(@"ImageTextCell初始化，reuseId: %@", reuseIdentifier);
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    NSLog(@"准备复用Cell，之前的messageId: %@", self.messageIdentifier);
    
    // 重置文本内容
    _messageTextView.text = @"";
    _messageTextView.attributedText = nil;
    
    // 清空图片加载状态
    [_pendingImageURLs removeAllObjects];
    [_loadedImages removeAllObjects];
    [_failedImageURLs removeAllObjects];
    _messageIdentifier = nil;
    self.currentMessage = nil;
    
    // 重置气泡布局
    [_bubbleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(10));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(11));
        make.right.equalTo(_messageTextView.mas_right).offset(13);
        make.bottom.equalTo(_messageTextView.mas_bottom).offset(16);
        make.bottom.equalTo(self.contentView).offset(-JSHeight(20));
    }];
    
    NSLog(@"Cell状态已重置");
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

#pragma mark - 公共方法

- (void)configureWithMessage:(MessageModel *)message {
    NSLog(@"配置Cell，消息ID: %@，图片数量: %lu", message.messageId, (unsigned long)message.imageInfos.count);
    
    // 保存消息ID和消息模型
    self.messageIdentifier = message.messageId;
    self.currentMessage = message;
    
    // 重置状态
    [self.pendingImageURLs removeAllObjects];
    [self.loadedImages removeAllObjects];
    [self.failedImageURLs removeAllObjects];
    
    // 显示初始文本内容（替换了图片的纯文本）
    self.messageTextView.text = message.processedTextContent;
    
    // 如果没有图片，直接返回
    if (message.imageInfos.count == 0) {
        NSLog(@"消息没有图片，配置完成");
        return;
    }
    
    // 记录所有需要加载的图片URL
    for (ImageInfo *imageInfo in message.imageInfos) {
        NSLog(@"添加待加载图片URL: %@", imageInfo.imageURL);
        [self.pendingImageURLs addObject:imageInfo.imageURL];
        
        // 检查是否已有缓存
        UIImage *cachedImage = [[ImageCacheService sharedInstance] cachedImageForURL:imageInfo.imageURL];
        if (cachedImage) {
            NSLog(@"使用缓存图片: %@", imageInfo.imageURL);
            [self updateWithImage:cachedImage forURL:imageInfo.imageURL];
        }
    }
    
    // 如果有缓存未加载的图片，请求通过通知加载
    if (self.pendingImageURLs.count > 0) {
        NSLog(@"发送加载图片请求，消息ID: %@, 待加载图片: %lu", message.messageId, (unsigned long)self.pendingImageURLs.count);
        
        // 直接加载图片，避免通知系统可能的问题
        for (ImageInfo *imageInfo in message.imageInfos) {
            if ([self.pendingImageURLs containsObject:imageInfo.imageURL]) {
                // 直接使用ImageCacheService加载图片
                [[ImageCacheService sharedInstance] loadImageWithURL:imageInfo.imageURL completion:^(UIImage * _Nullable image, NSString *url) {
                    NSLog(@"直接加载图片完成: %@, 图片%@", url, image ? @"成功" : @"失败");
                    if (image) {
                        [self updateWithImage:image forURL:url];
                    } else {
                        [self markImageAsFailedForURL:url];
                    }
                }];
            }
        }
        
    } else {
        // 所有图片都已从缓存中加载，直接更新UI
        NSLog(@"所有图片都已从缓存加载，直接更新UI");
        [self updateFinalTextView:message];
    }
}

- (void)updateWithImage:(UIImage *)image forURL:(NSString *)url {
    if (!self.messageIdentifier) {
        NSLog(@"Cell已复用，不更新图片: %@", url);
        return;
    }
    
    NSLog(@"更新图片: %@, Cell的messageId: %@", url, self.messageIdentifier);
    
    if (!image || !url) {
        NSLog(@"无效的图片或URL");
        return;
    }
    
    // 保存加载的图片
    self.loadedImages[url] = image;
    
    // 从待处理列表中移除
    [self.pendingImageURLs removeObject:url];
    [self.failedImageURLs removeObject:url]; // 如果之前失败过，现在成功了，从失败列表移除
    
    NSLog(@"图片已保存，剩余待加载图片: %lu", (unsigned long)self.pendingImageURLs.count);
    
    // 检查是否所有图片都已加载完成
    if (self.pendingImageURLs.count == 0) {
        // 所有图片已加载，更新UI
        NSLog(@"所有图片已加载完成，更新UI");
        [self updateFinalTextViewWithCurrentMessage];
    }
}

- (void)markImageAsFailedForURL:(NSString *)url {
    if (!self.messageIdentifier) {
        NSLog(@"Cell已复用，不标记失败: %@", url);
        return;
    }
    
    NSLog(@"标记图片加载失败: %@", url);
    if (!url) return;
    
    // 标记为加载失败
    [self.failedImageURLs addObject:url];
    
    // 从待处理列表中移除
    [self.pendingImageURLs removeObject:url];
    
    NSLog(@"图片已标记为失败，剩余待加载图片: %lu", (unsigned long)self.pendingImageURLs.count);
    
    // 检查是否所有图片都已处理完（加载成功或失败）
    if (self.pendingImageURLs.count == 0) {
        // 所有图片已处理，更新UI
        NSLog(@"所有图片已处理完成，更新UI");
        [self updateFinalTextViewWithCurrentMessage];
    }
}

#pragma mark - ImageLoadDelegate



#pragma mark - 私有方法

// 根据当前消息更新最终文本视图
- (void)updateFinalTextViewWithCurrentMessage {
    // 使用当前保存的消息模型
    if (self.currentMessage) {
        NSLog(@"使用当前消息模型更新文本视图，消息ID: %@", self.currentMessage.messageId);
        [self updateFinalTextView:self.currentMessage];
    } else {
        // 如果没有保存消息模型，请求获取
        NSLog(@"请求消息模型，消息ID: %@", self.messageIdentifier);
        [self requestCurrentMessageModelForUpdate];
    }
}

// 请求当前消息模型并更新视图
- (void)requestCurrentMessageModelForUpdate {
    // 通过通知中心请求
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestMessageModelForUpdate" 
                                                        object:self 
                                                      userInfo:@{@"messageId": self.messageIdentifier}];
}

// 根据消息模型和已加载的图片更新最终文本视图
- (void)updateFinalTextView:(MessageModel *)message {
    if (!message || ![message.messageId isEqualToString:self.messageIdentifier]) {
        NSLog(@"消息ID不匹配，不更新视图");
        return;
    }
    
    NSLog(@"更新最终文本视图，消息ID: %@, 已加载图片: %lu, 失败图片: %lu", 
          message.messageId, 
          (unsigned long)self.loadedImages.count, 
          (unsigned long)self.failedImageURLs.count);
    
    // 更新当前消息模型引用
    self.currentMessage = message;
    
    // 生成最终的富文本
    NSMutableAttributedString *finalText = [[NSMutableAttributedString alloc] init];
    NSString *currentText = message.processedTextContent;
    
    // 按索引排序图片信息
    NSArray *sortedImageInfos = [message.imageInfos sortedArrayUsingComparator:^NSComparisonResult(ImageInfo *obj1, ImageInfo *obj2) {
        return [@(obj1.index) compare:@(obj2.index)];
    }];
    
    // 逐个处理图片占位符
    for (ImageInfo *imageInfo in sortedImageInfos) {
        // 构建占位符字符串
        NSString *placeholder = [NSString stringWithFormat:@"[图片%ld]", (long)imageInfo.index];
        NSRange placeholderRange = [currentText rangeOfString:placeholder];
        
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
            
            // 获取已加载的图片
            UIImage *loadedImage = self.loadedImages[imageInfo.imageURL];
            
            if (loadedImage) {
                NSLog(@"插入图片附件: %@", imageInfo.imageURL);
                // 计算图片显示尺寸
                CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - JSWidth(237 + 65 + 28 + 135 + 10);
                CGFloat aspectRatio = imageInfo.height / imageInfo.width;
                CGFloat displayWidth = MIN(imageInfo.width, maxWidth);
                CGFloat displayHeight = displayWidth * aspectRatio;
                
                // 添加图片附件
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = loadedImage;
                attachment.bounds = CGRectMake(0, 0, displayWidth, displayHeight);
                
                NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:attachment];
                [finalText appendAttributedString:imageString];
            } else if ([self.failedImageURLs containsObject:imageInfo.imageURL]) {
                // 图片加载失败，显示错误占位符
                NSLog(@"显示加载失败占位符: %@", imageInfo.imageURL);
                NSAttributedString *failedText = [[NSAttributedString alloc] initWithString:@"[图片加载失败]" attributes:@{
                    NSFontAttributeName: [UIFont systemFontOfSize:16],
                    NSForegroundColorAttributeName: [UIColor redColor]
                }];
                [finalText appendAttributedString:failedText];
            } else {
                // 图片未加载，保留占位符
                NSLog(@"保留加载中占位符: %@", imageInfo.imageURL);
                NSAttributedString *placeholderText = [[NSAttributedString alloc] initWithString:@"[图片加载中...]" attributes:@{
                    NSFontAttributeName: [UIFont systemFontOfSize:16],
                    NSForegroundColorAttributeName: [UIColor lightGrayColor]
                }];
                [finalText appendAttributedString:placeholderText];
            }
            
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
    
    // 更新气泡布局
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
    
    
}

@end

