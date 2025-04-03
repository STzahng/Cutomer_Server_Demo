//
//  TopBar.m
//  test1.0
//
//  Created by heiqi on 2025/4/1.
//

#import "TopBar.h"
#import "Masonry/Masonry.h"
#import "ScreenScaling.h"

@implementation TopBar
- (instancetype)init{
    if (self = [super init]) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}
- (void)setupUI{

    _backgroundImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"bg_chat_topbar"]];
    [self insertSubview: _backgroundImageView atIndex: 0];

    
    _backButton = [[UIButton alloc] init];
    [_backButton setImage: [UIImage imageNamed: @"btn_chat_previouspage"] forState: UIControlStateNormal];
    [_backButton addTarget: self.delegate action: @selector(backButtonDidClick:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview: _backButton];
    
    _titleLabel = [[UILabel alloc] init];
    
    _titleLabel.text = @"GM";
    _titleLabel.font = [UIFont systemFontOfSize:24];
    //_titleLabel.backgroundColor = [UIColor whiteColor];
    _titleLabel.textColor = [UIColor colorWithRed:183.0/255.0
                                            green:220.0/255.0
                                             blue:236.0/255.0
                                            alpha:0.8];
    [self addSubview: _titleLabel];
}
- (void)setupConstraints {
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker* make){
        make.edges.equalTo(self);
    }];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker* make){
        make.left.equalTo(@(JSWidth(60)));
        make.centerY.equalTo(self);
        make.width.height.equalTo(@(JSWidth(80)));
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker* make){
        make.center.equalTo(self);
    }];
    
}
@end
