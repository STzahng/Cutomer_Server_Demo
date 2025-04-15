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
@property (nonatomic, strong) UIButton *translatedButton;
@property (nonatomic, strong) UIImageView *translatedLine;
@property (nonatomic, strong) UILabel *translatedMessage;
@property (nonatomic, assign) BOOL isTranslated; // 添加标记是否已翻译

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

    _translatedButton = [[UIButton alloc] init];
    [_translatedButton setImage:[UIImage imageNamed:@"btn_chat_translation"] forState:UIControlStateNormal];
    [_translatedButton addTarget:self action:@selector(translateButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    _translatedLine = [[UIImageView alloc] init];
    _translatedLine.backgroundColor = [UIColor colorWithRed:107.0/255.0
                                                      green:132.0/255.0
                                                       blue:145.0/255.0
                                                      alpha:1];
    
    _translatedMessage = [[UILabel alloc] init];
    _translatedMessage.numberOfLines = 0;
    _translatedMessage.font = [UIFont systemFontOfSize:16];
    _translatedMessage.textColor = [UIColor whiteColor];
    
    // 初始化为未翻译状态
    _isTranslated = NO;

    [self.contentView addSubview:_bubbleImage];
    [self.contentView addSubview:_messageLabel];
    [self.contentView addSubview:_headpic];
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_translatedButton];
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
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(65));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(40));
        make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-JSWidth(237));
    }];

    [_bubbleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(10));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(11));
        make.right.equalTo(_messageLabel.mas_right).offset(13);
        make.bottom.equalTo(_messageLabel.mas_bottom).offset(16);
        make.bottom.equalTo(self.contentView).offset(-JSHeight(20));
    }];
    
    [_translatedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bubbleImage.mas_right).offset(JSWidth(20));
        make.centerY.equalTo(_bubbleImage);
        make.width.height.equalTo(@(JSWidth(80)));
    }];
}

- (void)configureWithMessage:(MessageModel *)message {
    _messageLabel.text = message.content;
    
    // 先重置状态
    [self resetTranslationState];
    
    // 如果模型已翻译，则显示翻译内容
    if (message.isTranslated) {
        [self showTranslation];
    }
}

// 重置翻译状态的辅助方法
- (void)resetTranslationState {
    _isTranslated = NO;
    // 移除翻译相关视图
    [_translatedLine removeFromSuperview];
    [_translatedMessage removeFromSuperview];
    
    // 重置气泡和按钮
    [_bubbleImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_messageLabel.mas_right).offset(13);
        make.bottom.equalTo(_messageLabel.mas_bottom).offset(16);
        make.bottom.equalTo(self.contentView).offset(-JSHeight(20));
    }];
    
    [_translatedButton setImage:[UIImage imageNamed:@"btn_chat_translation"] forState:UIControlStateNormal];
    [self layoutIfNeeded];
}

- (void)translateButtonDidClick {
    // 如果已经翻译过，不做任何处理
    if (_isTranslated) {
        return;
    }
    
    // 更换按钮图片并开始旋转动画
    [_translatedButton setImage:[UIImage imageNamed:@"img_chat_sending"] forState:UIControlStateNormal];
    [self startRotationAnimation];
    
    // 3秒后显示翻译结果
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 停止动画，恢复按钮图片
        [self stopRotationAnimation];
        [_translatedButton setImage:[UIImage imageNamed:@"btn_chat_translation"] forState:UIControlStateNormal];
        
        // 显示翻译结果
        [self showTranslation];
        UITableView *tableView = (UITableView *)self.superview;
        NSIndexPath *indexPath = [tableView indexPathForCell:self];
        self.tapAction(indexPath);
    });
}

- (void)showTranslation {
    // 标记为已翻译
    _isTranslated = YES;
    
    // 设置翻译文本（这里直接使用原文本作为示例）
    _translatedMessage.text = _messageLabel.text;
    
    // 添加分割线和翻译文本到视图
    [self.contentView addSubview:_translatedLine];
    [self.contentView addSubview:_translatedMessage];
    
    // 设置分割线约束
    [_translatedLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_translatedMessage);
        make.top.equalTo(_messageLabel.mas_bottom).offset(JSHeight(15));
        make.height.equalTo(@(JSHeight(2)));
    }];
    
    // 设置翻译文本约束
    [_translatedMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(65));
        make.top.equalTo(_messageLabel.mas_bottom).offset(JSHeight(32));
        make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-JSWidth(237));
    }];
    
    // 更新气泡约束包含翻译内容
    [_bubbleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(10));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(11));
        make.right.equalTo(_translatedMessage.mas_right).offset(13);
        make.bottom.equalTo(_translatedMessage.mas_bottom).offset(16);
        make.bottom.equalTo(self.contentView).offset(-JSHeight(20));
    }];
    
    // 强制更新布局
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)startRotationAnimation {
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.fromValue  = @0; // 起始角度
    rotation.toValue  = @(2 * M_PI); // 终止角度（360度）
    rotation.duration  = 1.0; // 单次动画时长
    rotation.repeatCount  = HUGE_VALF; // 无限循环
    [_translatedButton.imageView.layer addAnimation:rotation forKey:@"rotationAnimation"];
}
 
- (void)stopRotationAnimation {
    [_translatedButton.imageView.layer removeAnimationForKey:@"rotationAnimation"];
}

@end
