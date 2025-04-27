//
//  MessageCell.m
//  test1.0
//
//  Created by heiqi on 2025/4/7.
//

#import "MessageCell.h"
#import "Masonry/Masonry.h"
#import "ScreenScaling.h"
#import "EmojiViewModel.h"

@interface MessageCell ()

@property (nonatomic, strong) UIImageView *headpic;
@property (nonatomic, strong, readwrite) UITextView *messageTextView;
@property (nonatomic, strong) UIImageView *bubbleImage;
@property (nonatomic, strong) UIButton *translatedLabel;

@end

@implementation MessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 创建头像
    _headpic = [[UIImageView alloc] init];
    [_headpic setImage:[UIImage imageNamed:@"img_chat_head"]];
    
    _bubbleImage = [[UIImageView alloc] init];
    UIImage *bubbleImage = [UIImage imageNamed:@"bg_chat_message"];
    // 设置9宫格拉伸区域，这里假设气泡图片的边角区域为20像素
    UIEdgeInsets insets = UIEdgeInsetsMake(28, 10, 7, 15);
    _bubbleImage.image = [bubbleImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    _messageTextView = [[UITextView alloc] init];
    _messageTextView.editable = NO;
    _messageTextView.scrollEnabled = NO;
    _messageTextView.backgroundColor = [UIColor clearColor];
    _messageTextView.textAlignment = NSTextAlignmentLeft;
    _messageTextView.text = @"Hello world！！";
    _messageTextView.font = [UIFont systemFontOfSize:16];
    _messageTextView.textColor = [UIColor whiteColor];
    _messageTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _messageTextView.textContainer.lineFragmentPadding = 0;
    
    [self addSubview:_bubbleImage];
    [self addSubview:_messageTextView];
    [self addSubview:_headpic];
}

- (void)setupConstraints {
    [_headpic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).inset(JSWidth(28));
        make.top.equalTo(self);
        make.width.height.equalTo(@(JSWidth(135)));
    }];
    
    [_messageTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bubbleImage.mas_right).inset(JSWidth(55));
        make.top.equalTo(_bubbleImage.mas_top).offset(JSHeight(27));
        make.left.greaterThanOrEqualTo(self.mas_left).inset(JSWidth(237));
    }];
    
    [_bubbleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_headpic.mas_left).inset(JSWidth(20));
        make.top.equalTo(_headpic.mas_top).offset(JSHeight(20));
        make.left.equalTo(_messageTextView.mas_left).offset(-13);
        make.bottom.equalTo(_messageTextView.mas_bottom).offset(16);
        make.bottom.equalTo(self).offset(-JSHeight(20));
    }];
}

- (void)configureWithMessage:(MessageModel *)message {
    // 首先设置基本文本
    NSString *content = message.content ?: @"";
    
    // 检测是否有表情标记 [#数字]
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[#(\\d+)\\]" options:0 error:nil];
    NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    
    if (matches.count == 0) {
        // 没有表情标记，直接显示文本
        _messageTextView.text = content;
        return;
    }
    // 保存当前样式属性
    UIFont *currentFont = [UIFont systemFontOfSize:16];
    UIColor *currentTextColor = [UIColor whiteColor];
    
    // 创建富文本
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedString addAttribute:NSFontAttributeName value:currentFont range:NSMakeRange(0, content.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:currentTextColor range:NSMakeRange(0, content.length)];
    
    // 从后向前替换，避免替换过程中影响位置
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        @try {
            NSRange fullRange = match.range;
            if (fullRange.location + fullRange.length > content.length) {
                continue; // 安全检查，防止范围越界
            }
            
            NSRange numberRange = [match rangeAtIndex:1]; // 数字部分
            if (numberRange.location + numberRange.length > content.length) {
                continue; // 安全检查，防止范围越界
            }
            
            // 获取表情ID
            NSString *emojiId = [content substringWithRange:numberRange];
            // 获取表情图片
            NSArray *allGroups = [[EmojiViewModel sharedInstance] allEmojiGroups];
            UIImage *emojiImage = nil;
            
            // 遍历所有表情组查找对应ID的表情
            for (NSDictionary *group in allGroups) {
                NSArray *emojis = group[@"emojis"];
                for (NSDictionary *emoji in emojis) {
                    if ([emoji[@"id"] isEqual:@([emojiId integerValue])]) {
                        NSString *imageName = emoji[@"img"];
                        emojiImage = [[EmojiViewModel sharedInstance] imageForEmojiWithName:imageName];
                        break;
                    }
                }
                if (emojiImage) break;
            }
            
            if (emojiImage) {
                // 直接使用固定大小
                CGFloat emojiSize = JSHeight(55);
                
                // 绘制调整大小后的图片
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(emojiSize, emojiSize), NO, 0.0);
                [emojiImage drawInRect:CGRectMake(0, 0, emojiSize, emojiSize)];
                UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                // 创建表情图片附件
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = resizedImage;
                attachment.bounds = CGRectMake(0, -4, emojiSize, emojiSize); // -4调整垂直位置
                
                // 创建带附件的属性字符串
                NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:attachment];
                
                // 替换原文本中的占位符
                [attributedString replaceCharactersInRange:fullRange withAttributedString:emojiAttributedString];
            }
        } @catch (NSException *exception) {
            NSLog(@"消息单元格处理表情占位符异常: %@", exception.reason);
            continue; // 跳过这个匹配项，继续处理下一个
        }
    }
    
    // 设置富文本
    _messageTextView.attributedText = attributedString;
    
    // 确保文本样式一致
    _messageTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _messageTextView.textContainer.lineFragmentPadding = 0;
}

@end
