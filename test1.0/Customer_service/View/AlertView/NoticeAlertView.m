//
//  NoticeAlertView.m
//  test1.0
//
//  Created by heiqi on 2025/4/11.
//

#import "NoticeAlertView.h"
#import "ScreenScaling.h"
@interface NoticeAlertView ()
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) UIView *confirmView;
@property(nonatomic, strong) UIImageView *confirmImageView;
@property(nonatomic, strong) UILabel *confirmLabel;
@property(nonatomic, strong) UIImageView *backgroundView;

@end
@implementation NoticeAlertView
- (instancetype)initWithTitle:(NSString *)title notice:(NSString *)notice{
    if (self = [super init]) {
        [self setupUI];
        [self setupConstraints];
        self.alpha = 0;
        _titleLabel.text = title;
        _noticeText.text = notice;
    }
    return self;
}
- (void)setupUI{
    _backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"bg_chat_noticebg"]];
    [self insertSubview: _backgroundView atIndex: 0];
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton setImage: [UIImage imageNamed: @"btn_chat_cancel"] forState: UIControlStateNormal];
    [_cancelButton addTarget: self action: @selector(cancelButtonClick:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview: _cancelButton];
    
    _confirmView = [[UIView alloc] init];
    _confirmView.userInteractionEnabled  = YES;
    [self addSubview:_confirmView];

    _confirmImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"btn_chat_yellow"]];
    //[_confirmImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_confirmView addSubview:_confirmImageView];
    
     
    _confirmLabel = [[UILabel alloc] init];
    _confirmLabel.text  = @"确定";
    _confirmLabel.font = [UIFont systemFontOfSize: 22];
    _confirmLabel.textColor = [UIColor blackColor];
    _confirmLabel.textAlignment  = NSTextAlignmentCenter;
    [_confirmView addSubview:_confirmLabel];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                          action:@selector(confirmClick:)];
    [_confirmView addGestureRecognizer:tapGesture];
    
//    _confirmButton = [[UIButton alloc] init];
//    _confirmButton.titleLabel.text = @"确定";
//    _confirmButton.titleLabel.font = [UIFont systemFontOfSize: 22];
//    _confirmButton.titleLabel.textColor = [UIColor blackColor];
//    _confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [_confirmButton setBackgroundImage:[UIImage imageNamed: @"btn_chat_yellow"] forState:UIControlStateNormal];
//    [_confirmButton addTarget: self.delegate action: @selector(cancelButtonDidClick:) forControlEvents: UIControlEventTouchUpInside];
//    [self addSubview: _confirmButton];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"遊戲服務器卡頓公告";
    _titleLabel.font = [UIFont systemFontOfSize: 24];
    _titleLabel.textColor = [UIColor colorWithRed:183.0/255.0
                                            green:220.0/255.0
                                             blue:236.0/255.0
                                            alpha:1];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview: _titleLabel];
    
    _noticeText = [[UITextView alloc] init];
    _noticeText.text = @"游戏服务器即将于4月11日进行维护，预计维护时间为2小时。";
    _noticeText.font = [UIFont systemFontOfSize: 18];
    _noticeText.backgroundColor = [UIColor clearColor];
    _noticeText.textColor = [UIColor colorWithRed:166.0/255.0
                                            green:199.0/255.0
                                             blue:225.0/255.0
                                            alpha:1];
    
    _noticeText.textAlignment = NSTextAlignmentNatural;
    _noticeText.editable = NO;
    [self addSubview: _noticeText];
    
}

- (void)setupConstraints{
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker* make){
        make.edges.equalTo(self);
    }];
    
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self);
        make.width.height.equalTo(@(JSWidth(100)));
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.height.equalTo(@(JSHeight(90)));
    }];
    
    [_noticeText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(JSHeight(37));
        make.left.right.equalTo(self).inset(JSWidth(50));
        make.bottom.equalTo(_confirmView.mas_top).offset(-JSHeight(35));
    }];
    
    [_confirmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).inset(JSHeight(35));
        make.centerX.equalTo(self);
        make.width.equalTo(@(JSWidth(275)));
        make.height.equalTo(@(JSHeight(85)));
        
    }];
    
    [_confirmImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_confirmView);
    }];
    
    [_confirmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_confirmView);
    }];

    
}
// 显示弹窗的方法
- (void)showInView:(UIView *)view {

    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.5;
    backgroundView.tag = 1000;
    [view addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];

    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(view);
        make.width.equalTo(@(JSWidth(980)));
        make.height.equalTo(@(JSHeight(1132)));
    }];

    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }];
}

// 关闭弹窗的方法
- (void)dismiss {
    UIView *backgroundView = [self.superview viewWithTag:1000];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        // 动画完成后移除视图
        [backgroundView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)confirmClick:(UITapGestureRecognizer *)tapGesture{
    [self dismiss];
}

- (void)cancelButtonClick:(UIButton *)sender{
    [self dismiss];
}
@end
