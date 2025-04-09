//
//  OptionMessageCell.m
//  test1.0
//
//  Created by heiqi on 2025/4/7.
//
#import "OptionMessageCell.h"
#import "Masonry/Masonry.h"
#import "ScreenScaling.h"
#import "RecommendView.h"

@interface OptionMessageCell ()

@property (nonatomic, strong) UIImageView *headpic;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *bubbleImage;
@property (nonatomic, strong) UIButton *translatedLabel;

// 引导文本和选项按钮
@property (nonatomic, strong) UILabel *guideLabel;
@property (nonatomic, strong) NSMutableArray<UIButton *> *optionButtons;
@property (nonatomic, strong) NSMutableArray<UIView *> *optionUnderlines;
@property (nonatomic, strong) UIStackView *optionStackView;

@end

@implementation OptionMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone; // 禁用Cell的点击效果
    
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
    
    // 创建引导文本Label
    _guideLabel = [[UILabel alloc] init];
    _guideLabel.numberOfLines = 0;
    _guideLabel.text = @"In the game, players explore the col winter ice field in the @Apocalypse";
    _guideLabel.font = [UIFont systemFontOfSize:16];
    _guideLabel.textColor = [UIColor whiteColor];
    
    // 创建推荐选项StackView
    _optionStackView = [[UIStackView alloc] init];
    _optionStackView.axis = UILayoutConstraintAxisVertical;
    _optionStackView.spacing = 0; // 无间隔
    _optionStackView.alignment = UIStackViewAlignmentFill;
    _optionStackView.distribution = UIStackViewDistributionFill;
    
    // 添加推荐选项
    NSArray *tags = @[@"1.如何購買代币", @"2.登錄遇到問題怎瓣", @"3.支付購買禮包未收到怎辦",@"4.征服赛季规則"];
    for (NSString *tag in tags) {
        RecommendView *recommendView = [[RecommendView alloc] initWithTitle:tag];
        
        // 设置点击事件
        __weak typeof(self) weakSelf = self;
        recommendView.tapAction = ^{
            NSInteger index = [tags indexOfObject:tag];
            if (weakSelf.optionClickBlock) {
                weakSelf.optionClickBlock(index);
            }
        };
        
        [_optionStackView addArrangedSubview:recommendView];
    }
    
    // 初始化选项按钮和下划线数组
    _optionButtons = [NSMutableArray array];
    _optionUnderlines = [NSMutableArray array];
    
    [self addSubview:_bubbleImage];
    [self addSubview:_guideLabel];
    [self addSubview:_optionStackView];
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
    
    [_guideLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bubbleImage.mas_left).offset(JSWidth(55));
        make.top.equalTo(_bubbleImage.mas_top).offset(JSHeight(27));
        make.right.lessThanOrEqualTo(self.mas_right).offset(-JSWidth(237));
    }];
    
    // 添加stackView的约束
    [_optionStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_guideLabel);
        make.top.equalTo(_guideLabel.mas_bottom).offset(JSHeight(20));
        make.width.equalTo(_guideLabel); // 和引导文本相同宽度
    }];
    
    // 气泡的初始约束，包含stackView
    [_bubbleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(20));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(12));
        make.right.equalTo(_guideLabel.mas_right).offset(13);
        make.bottom.equalTo(_optionStackView.mas_bottom).offset(JSHeight(16));
    }];
    
    // 确保Cell的底部约束正确
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_bubbleImage.mas_bottom).offset(JSHeight(20));
    }];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    // 确保气泡包含所有内容
    [_bubbleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(20));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(12));
        make.right.equalTo(_guideLabel.mas_right).offset(13);
        make.bottom.equalTo(_optionStackView.mas_bottom).offset(JSHeight(16));
    }];
    
    // 确保Cell的底部约束正确
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_bubbleImage.mas_bottom).offset(JSHeight(20));
    }];
}

// 修改配置方法，支持同时更新引导文本和选项
- (void)configureWithGuideText:(NSString *)guideText options:(NSArray<NSString *> *)options {
    // 设置引导文本
    _guideLabel.text = guideText;
    
    // 移除StackView中所有的子视图
    for (UIView *view in _optionStackView.arrangedSubviews) {
        [view removeFromSuperview];
    }
    
    // 添加新的选项
    for (int i = 0; i < options.count; i++) {
        NSString *option = options[i];
        RecommendView *recommendView = [[RecommendView alloc] initWithTitle:option];
        
        // 设置点击事件
        __weak typeof(self) weakSelf = self;
        recommendView.tapAction = ^{
            if (weakSelf.optionClickBlock) {
                weakSelf.optionClickBlock(i);
            }
        };
        
        [_optionStackView addArrangedSubview:recommendView];
    }
    
    // 更新约束
    [self setNeedsUpdateConstraints];
}

// 处理按钮点击事件
- (void)optionButtonClicked:(UIButton *)sender {
    NSInteger tag = sender.tag;
    NSLog(@"Option %ld clicked", (long)tag + 1);
    
    // 如果有点击回调，可以在这里调用
    if (self.optionClickBlock) {
        self.optionClickBlock(tag);
    }
}

#pragma mark - Message Configuration

- (void)configureWithMessage:(MessageModel *)message {
    // 实现待添加，这里可以根据消息模型配置Cell内容
}

@end 