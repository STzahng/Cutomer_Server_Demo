//
//  RecommendView.m
//  test1.0
//
//  Created by heiqi on 2025/4/7.
//

#import "RecommendView.h"
#import "Masonry/Masonry.h"
#import "ScreenScaling.h"

@interface RecommendView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *underlineView;

@end

@implementation RecommendView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        _title = title;
        [self setupUI];
        [self setupConstraints];
        [self setupTapGesture];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupConstraints];
        [self setupTapGesture];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.text = _title ?: @"";
    
    _underlineView = [[UIView alloc] init];
    _underlineView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:_titleLabel];
    [self addSubview:_underlineView];
}

- (void)setupConstraints {
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
    }];
    
    [_underlineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_titleLabel);
        make.top.equalTo(_titleLabel.mas_bottom).offset(2);
        make.height.equalTo(@1);
        make.bottom.equalTo(self);
    }];
}

- (void)setupWithTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setupTapGesture {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tapGesture];
}

- (void)handleTap {
    if (self.tapAction) {
        self.tapAction();
    }
}

@end 