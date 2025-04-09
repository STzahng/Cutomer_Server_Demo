//
//  RecommendView.m
//  test1.0
//
//  Created by heiqi on 2025/4/8.
//

#import "RecommendView.h"
#import "ScreenScaling.h"

@interface RecommendView ()
@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UIImageView *nextImage;
@property (nonatomic, strong) UIImageView *underline;
@property (nonatomic, strong) NSString *question;
@end

@implementation RecommendView
- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        _question = title;
        [self setupUI];
        [self setupConstraints];
        NSLog(@"%@", _questionLabel.text);
    }
    return self;
}

- (void)setupUI{
    _questionLabel = [[UILabel alloc] init];
    _questionLabel.text = _question;
    _questionLabel.textColor = [UIColor colorWithRed:77.0/255.0
                                               green:239.0/255.0
                                                blue:241.0/255.0
                                               alpha:1];
    _questionLabel.font = [UIFont systemFontOfSize:17];
    _questionLabel.backgroundColor = [UIColor clearColor];
    
    _nextImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_chat_nextpage2"]];

    _underline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_chat_divider"]];
    
    [self addSubview:_questionLabel];
    [self addSubview:_nextImage];
    [self addSubview:_underline];
    
    // 添加点击手势识别器
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tapGesture];
    self.userInteractionEnabled = YES; // 确保视图可以接收触摸事件
}

- (void)setupConstraints{
    [_questionLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.top.equalTo(self);
        make.right.equalTo(_nextImage.mas_left).offset(-JSWidth(10));
        make.bottom.equalTo(_underline.mas_top);
        make.height.equalTo(@(JSHeight(90))); 
    }];
    
    [_nextImage mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self);
        make.width.equalTo(@(JSWidth(30)));
        make.height.equalTo(@(JSHeight(50)));
        make.centerY.equalTo(_questionLabel);
        
    }];
    
    [_underline mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.equalTo(@(JSHeight(2)));
        make.top.equalTo(_questionLabel.mas_bottom);
    }];
}

- (void)handleTap {
    if (self.tapAction) {
        self.tapAction();
    }
}
@end
