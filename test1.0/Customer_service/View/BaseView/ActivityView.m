//
//  ActivityView.m
//  test1.0
//
//  Created by heiqi on 2025/4/17.
//

#import "ActivityView.h"
#import "ScreenScaling.h"
#import "Masonry.h"
@interface ActivityView()
@property (nonatomic, strong) UIImageView *activityImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIView *underline;

@end
@implementation ActivityView

#pragma mark - 初始化方法

- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
        [self setupGesture];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image 
                        title:(NSString *)title 
                     subtitle:(NSString *)subtitle 
                          url:(NSURL *)url {
    if (self = [super init]) {
        [self setupUI];
        [self setupConstraints];
        [self setupGesture];
        [self configureWithImage:image title:title subtitle:subtitle url:url];
    }
    return self;
}

#pragma mark - 配置方法

- (void)configureWithImage:(UIImage *)image 
                     title:(NSString *)title 
                  subtitle:(NSString *)subtitle 
                       url:(NSURL *)url {
    self.activityImageView.image = image;
    self.titleLabel.text = title;
    self.subtitleLabel.text = subtitle;
    self.activityURL = url;
}

#pragma mark - 私有方法

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithRed:42.0/255.0
                                           green:68.0/255.0
                                            blue:94.0/255.0
                                           alpha:1];
    
    _activityImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"banner_blessings_2024"]];
    _activityImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_activityImageView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _titleLabel.textColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0]; // 黄色
    _titleLabel.numberOfLines = 1;
    [self addSubview:_titleLabel];
    
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.font = [UIFont systemFontOfSize:15];
    _subtitleLabel.textColor = [UIColor whiteColor];
    _subtitleLabel.numberOfLines = 0;
    [self addSubview:_subtitleLabel];
    

    _underline = [[UIView alloc] init];
    _underline.backgroundColor = [UIColor colorWithRed:107.0/255.0
                                                 green:132.0/255.0
                                                  blue:145.0/255.0
                                                 alpha:1];
    [self addSubview:_underline];
}

- (void)setupConstraints {
    [_activityImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.width.height.equalTo(@(JSWidth(140)));
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_activityImageView.mas_right).offset(JSWidth(15));
        make.top.equalTo(self).offset(JSHeight(10));
    }];
    
    [_underline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_activityImageView.mas_right).offset(JSWidth(15));
        make.right.equalTo(self).inset(JSWidth(15));
        make.top.equalTo(_titleLabel.mas_bottom).offset(JSHeight(10));
        make.height.equalTo(@(JSHeight(2)));
    }];
    
    [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_activityImageView.mas_right).offset(JSWidth(15));
        make.right.equalTo(self).offset(-JSWidth(15));
        make.top.equalTo(_underline.mas_bottom).offset(JSHeight(10));
        make.bottom.lessThanOrEqualTo(self).offset(-JSHeight(20));
    }];
}

- (void)setupGesture {
    // 添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tapGesture];
    self.userInteractionEnabled = YES;
}

- (void)handleTap {
    // 如果设置了URL和代理，则触发点击事件
    if (self.activityURL && [self.delegate respondsToSelector:@selector(activityViewDidTap:withURL:)]) {
        [self.delegate activityViewDidTap:self withURL:self.activityURL];
    }
}


@end
