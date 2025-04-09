//
//  MessageCell.m
//  test1.0
//
//  Created by heiqi on 2025/4/7.
//

#import "MessageCell.h"
#import "Masonry/Masonry.h"
#import "ScreenScaling.h"

@interface MessageCell ()

@property (nonatomic, strong) UIImageView *headpic;
@property (nonatomic, strong) UILabel *messageLabel;
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
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.numberOfLines = 0;
    _messageLabel.textAlignment = NSTextAlignmentLeft;
    _messageLabel.text = @"Hello world！！";
    _messageLabel.font = [UIFont systemFontOfSize:16];
    _messageLabel.textColor = [UIColor whiteColor];
    
    
    [self addSubview:_bubbleImage];
    [self addSubview:_messageLabel];
    [self addSubview:_headpic];
}

- (void)setupConstraints {
    [_headpic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).inset(JSWidth(28));
        make.top.equalTo(self);
        make.width.height.equalTo(@(JSWidth(135)));
    }];
    
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bubbleImage.mas_right).inset(JSWidth(55));
        make.top.equalTo(_bubbleImage.mas_top).offset(JSHeight(27));
        make.left.greaterThanOrEqualTo(self.mas_left).inset(JSWidth(237));
    }];
    
    [_bubbleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_headpic.mas_left).inset(JSWidth(20));
        make.top.equalTo(_headpic.mas_top).offset(JSHeight(20));
        make.left.equalTo(_messageLabel.mas_left).offset(-13);
        make.bottom.equalTo(_messageLabel.mas_bottom).offset(16);
        make.bottom.equalTo(self).offset(-JSHeight(20));
    }];
}


- (void)configureWithMessage:(MessageModel *)message {
    _messageLabel.text = message.content;
}

@end
