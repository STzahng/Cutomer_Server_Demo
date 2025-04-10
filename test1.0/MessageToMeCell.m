//
//  MessageCell.m
//  test1.0
//
//  Created by heiqi on 2025/4/3.
//
#import "MessageToMeCell.h"
#import "Masonry/Masonry.h"
#import "ScreenScaling.h"

@interface MessageToMeCell ()

@property (nonatomic, strong) UIImageView *headpic;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *bubbleImage;
@property (nonatomic, strong) UIButton *translatedLabel;

@end

@implementation MessageToMeCell

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
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.text = @"GM";
    _nameLabel.font = [UIFont systemFontOfSize:17];
    _nameLabel.textColor = [UIColor whiteColor];
    
    _bubbleImage = [[UIImageView alloc] init];
    UIImage *bubbleImage = [UIImage imageNamed:@"bg_chat_message2"];
    // 设置9宫格拉伸区域，这里假设气泡图片的边角区域为20像素
    UIEdgeInsets insets = UIEdgeInsetsMake(28, 15, 7, 10);
    _bubbleImage.image = [bubbleImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.numberOfLines = 0;
    _messageLabel.text = @"Are you ready OK？";
    _messageLabel.font = [UIFont systemFontOfSize:16];
    _messageLabel.textColor = [UIColor whiteColor];


    [self.contentView addSubview:_bubbleImage];
    [self.contentView addSubview:_messageLabel];
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
    
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bubbleImage.mas_left).offset(JSWidth(55));
        make.top.equalTo(_bubbleImage.mas_top).offset(JSHeight(20));
        make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-JSWidth(237));
    }];

    [_bubbleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(10));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(11));
        make.right.equalTo(_messageLabel.mas_right).offset(13);
        make.bottom.equalTo(_messageLabel.mas_bottom).offset(16);
        make.bottom.equalTo(self.contentView).offset(-JSHeight(20));
    }];
    
}

- (void)configureWithMessage:(MessageModel *)message {
    _messageLabel.text = message.content;
}
@end
