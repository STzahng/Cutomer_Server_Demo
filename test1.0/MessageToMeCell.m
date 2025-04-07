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
    [self.contentView addSubview:_headpic];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.text = @"GM";
    _nameLabel.font = [UIFont systemFontOfSize:18];
    _nameLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_nameLabel];
    
    _bubbleImage = [[UIImageView alloc] init];
    UIImage *bubbleImage = [UIImage imageNamed:@"bg_chat_message1"];
    // 设置9宫格拉伸区域，这里假设气泡图片的边角区域为20像素
    UIEdgeInsets insets = UIEdgeInsetsMake(100, 100, 100, 100);
    _bubbleImage.image = [bubbleImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [self.contentView addSubview:_bubbleImage];
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.numberOfLines = 0;
    _messageLabel.text = @"Hello, World!!!";
    _messageLabel.font = [UIFont systemFontOfSize:16];
    _messageLabel.textColor = [UIColor whiteColor];
    [_bubbleImage addSubview:_messageLabel];
    
}

- (void)setupConstraints {
    [_headpic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(JSWidth(27)));
        make.top.equalTo(self);
        make.width.height.equalTo(@(JSWidth(135)));
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(35));
        make.top.equalTo(self).offset(JSHeight(13));
        make.height.equalTo(@(JSHeight(30)));
    }];
    
    [_bubbleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(35));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(12));
        make.right.lessThanOrEqualTo(self.contentView).offset(-JSWidth(50));
        make.bottom.equalTo(_messageLabel.mas_bottom).offset(JSHeight(15));
    }];
    
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bubbleImage).offset(JSWidth(20));
        make.right.equalTo(_bubbleImage).offset(-JSWidth(20));
        make.top.equalTo(_bubbleImage).offset(JSHeight(15));
        make.bottom.equalTo(_bubbleImage).offset(-JSHeight(15));
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
