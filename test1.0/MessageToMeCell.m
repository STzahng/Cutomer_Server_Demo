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


    [self addSubview:_bubbleImage];
    [self addSubview:_messageLabel];
    [self addSubview:_headpic];
    [self addSubview:_nameLabel];
    
}

- (void)setupConstraints {
    [_headpic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(JSWidth(27)));
        make.top.equalTo(self);
        make.width.height.equalTo(@(JSWidth(135)));
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(65));
        make.top.equalTo(self).offset(JSHeight(13));
        make.height.equalTo(@(JSHeight(30)));
    }];
    
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bubbleImage.mas_left).offset(JSWidth(55));
        make.top.equalTo(_bubbleImage.mas_top).offset(JSHeight(27));
        make.right.lessThanOrEqualTo(self.mas_right).offset(-JSWidth(237));
    }];

    [_bubbleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(20));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(12));
        make.right.equalTo(_messageLabel.mas_right).offset(13);
        make.bottom.equalTo(_messageLabel.mas_bottom).offset(16);
        make.bottom.equalTo(self).offset(-JSHeight(20));
    }];
    
}

//- (void)configureWithMessage:(MessageModel *)message {
//    // 设置头像
//    if (message.avatarUrl) {
//        // 这里应该使用图片加载库（如SDWebImage）来加载头像
//        // [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:message.avatarUrl]];
//    } else {
//        _avatarImageView.image = [UIImage imageNamed:@"default_avatar"];
//    }
//    
//    // 设置消息内容
//    _messageLabel.text = message.content;
//    
//    // 设置翻译内容
//    if (message.isTranslated) {
//        _translatedLabel.text = message.translatedContent;
//        _translatedLabel.hidden = NO;
//    } else {
//        _translatedLabel.hidden = YES;
//    }
//    
//    // 根据消息类型调整布局
//    if (message.type == MessageTypeUser) {
//        _avatarImageView.hidden = YES;
//        [_messageContainer mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.contentView).offset(10);
//        }];
//    } else {
//        _avatarImageView.hidden = NO;
//        [_messageContainer mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_avatarImageView.mas_right).offset(10);
//        }];
//    }
//}

@end
