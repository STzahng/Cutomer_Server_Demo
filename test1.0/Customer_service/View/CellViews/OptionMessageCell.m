//
//  OptionMessageCell.m
//  test1.0
//
//  Created by heiqi on 2025/4/7.
//

#import "OptionMessageCell.h"
#import "ScreenScaling.h"
#import "RecommendView.h"

@interface OptionMessageCell ()

@property (nonatomic, strong) UIImageView *headpic;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *bubbleImage;
@property (nonatomic, strong) UIButton *translatedLabel;
@property (nonatomic, strong) UIStackView *optionStackView;
@property (nonatomic, strong) NSArray<RecommendView *> *recommendViews;

@end

@implementation OptionMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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
    _messageLabel.text = @"In the game, players explore the colwinter ice field in the @Apocalypse";
    _messageLabel.font = [UIFont systemFontOfSize:16];
    _messageLabel.textColor = [UIColor whiteColor];
    
    // 创建推荐选项StackView
    _optionStackView = [[UIStackView alloc] init];
    _optionStackView.axis = UILayoutConstraintAxisVertical;
    _optionStackView.spacing = 10;
    _optionStackView.alignment = UIStackViewAlignmentFill;
    _optionStackView.distribution = UIStackViewDistributionFill;
    _optionStackView.userInteractionEnabled = YES;
    
    [self.contentView addSubview:_bubbleImage];
    [self.contentView addSubview:_messageLabel];
    [self.contentView addSubview:_headpic];
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_optionStackView];
}

- (void)setupConstraints {
    [_headpic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(JSWidth(28)));
        make.top.equalTo(self.contentView);
        make.width.height.equalTo(@(JSWidth(135)));
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(65));
        make.top.equalTo(self.contentView).offset(JSHeight(13));
        make.height.equalTo(@(JSHeight(30)));
    }];
    
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bubbleImage.mas_left).offset(JSWidth(55));
        make.top.equalTo(_bubbleImage.mas_top).offset(JSHeight(20));
        make.right.equalTo(self.contentView.mas_right).offset(-JSWidth(237));
    }];

    [_optionStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_messageLabel.mas_bottom);
        make.left.equalTo(_bubbleImage.mas_left).offset(JSWidth(55));
        make.right.equalTo(self.contentView.mas_right).offset(-JSWidth(237));
    }];
    
    [_bubbleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(20));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(12));
        make.right.equalTo(_optionStackView.mas_right).offset(13);
        make.bottom.equalTo(_optionStackView.mas_bottom).offset(16);
        make.bottom.equalTo(self.contentView).offset(-JSHeight(20));
    }];
}

- (void)configureWithMessage:(MessageModel *)message {
    // 清除现有的推荐视图
    for (UIView *view in _optionStackView.arrangedSubviews) {
        [_optionStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    
    // 创建新的推荐视图
    NSArray *recommendQuestions = @[
        @"1.如何购买代币",
        @"2.登录遇到问题怎么办",
        @"3.支付购买礼包未收到怎么办",
        @"4.征服赛季规则",
        @"5.图文测试"
    ];
    
    NSMutableArray *views = [NSMutableArray array];
    for (NSString *question in recommendQuestions) {
        RecommendView *recommendView = [[RecommendView alloc] initWithTitle:question];
        recommendView.tapAction = ^{
            NSString *recommendId = [question substringToIndex:1];
            [self.delegate optionMessageCell:self didSelectRecommendId:recommendId];
        };
        [views addObject:recommendView];
        [_optionStackView addArrangedSubview:recommendView];
    }
    _recommendViews = [views copy];
}

@end
