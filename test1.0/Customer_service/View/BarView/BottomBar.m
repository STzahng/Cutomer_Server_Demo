//
//  BottomBar.m
//  test1.0
//
//  Created by heiqi on 2025/4/2.
//

#import "BottomBar.h"
#import "Masonry/Masonry.h"
#import "ScreenScaling.h"

@implementation BottomBar

- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI{
    
    _backgroundImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"bg_chat_bottombackground1"]];
    [self insertSubview: _backgroundImageView atIndex: 0];
    
    _messageField = [[UITextField alloc] init];
    _messageField.background = [UIImage imageNamed: @"bg_chat_bottombackground2"];
    _messageField.textColor = [UIColor whiteColor];
    _messageField.font = [UIFont systemFontOfSize: 18];
    [self addSubview: _messageField];
    
    _emoticonButton = [[UIButton alloc] init];
    [_emoticonButton setImage: [UIImage imageNamed: @"btn_chat_emoticon"] forState: UIControlStateNormal];
    [_emoticonButton addTarget: self action: @selector(emoticonButtonDidClick:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview: _emoticonButton];
    
    _pictureButton = [[UIButton alloc] init];
    [_pictureButton setImage: [UIImage imageNamed: @"btn_chat_picture"] forState: UIControlStateNormal];
    [_pictureButton addTarget: self action: @selector(pictrueButtonDidClick:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview: _pictureButton];
    
    _sendButton = [[UIButton alloc] init];
    [_sendButton setImage: [UIImage imageNamed: @"btn_chat_send"] forState: UIControlStateNormal];
    [_sendButton addTarget: self action: @selector(sendButtonDidClick:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview: _sendButton];
    
    
   
}
- (void)setupConstraints {
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker* make){
        make.edges.equalTo(self);
    }];
    
    [_messageField mas_makeConstraints:^(MASConstraintMaker* make){
        make.left.equalTo(@(JSWidth(25)));
        make.right.equalTo(_emoticonButton.mas_left).inset(JSWidth(35));
        make.centerY.equalTo(self);
        make.height.equalTo(@(JSHeight(85)));
    }];
    
    [_emoticonButton mas_makeConstraints:^(MASConstraintMaker* make){
        make.right.equalTo(_pictureButton.mas_left).inset(JSWidth(35));
        make.centerY.equalTo(self);
        make.width.height.equalTo(@(JSHeight(85)));
    }];
    
    [_pictureButton mas_makeConstraints:^(MASConstraintMaker* make){
        make.right.equalTo(_sendButton.mas_left).inset(JSWidth(35));
        make.centerY.equalTo(self);
        make.width.height.equalTo(@(JSHeight(85)));
    }];
    
    [_sendButton mas_makeConstraints:^(MASConstraintMaker* make){
        make.right.equalTo(self).inset(JSWidth(24));
        make.centerY.equalTo(self);
        make.width.height.equalTo(@(JSHeight(85)));
    }];
    
}

- (void)emoticonButtonDidClick:(UIButton*)sender{
    NSLog(@"emoticonButton clicked");
}
- (void)pictrueButtonDidClick:(UIButton*)sender{
    NSLog(@"pictureButton clicked");
}
- (void)sendButtonDidClick:(UIButton*)sender{
    NSLog(@"sendButton clicked");
}
@end
