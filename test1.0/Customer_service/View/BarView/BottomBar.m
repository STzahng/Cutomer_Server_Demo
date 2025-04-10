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
    
    _messageField = [[UITextView alloc] init];
    _messageField.delegate = self;
    _messageField.backgroundColor = [UIColor colorWithRed:37.0/255.0
                                                    green:47.0/255.0
                                                     blue:60.0/255.0
                                                    alpha:1];
    _messageField.textColor = [UIColor whiteColor];
    _messageField.font = [UIFont systemFontOfSize: 17];
    _messageField.scrollEnabled = NO;
    _messageField.textContainerInset = UIEdgeInsetsMake(JSWidth(20), JSWidth(15), JSWidth(8), JSWidth(15));
    // 添加文本变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(textViewDidChange:)
                                                name:UITextViewTextDidChangeNotification
                                              object:_messageField];
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
        make.top.bottom.equalTo(self).inset(JSHeight(30));
       // make.height.equalTo(@(JSHeight(85)));
    }];
    
    [_emoticonButton mas_makeConstraints:^(MASConstraintMaker* make){
        make.right.equalTo(_pictureButton.mas_left).inset(JSWidth(35));
        make.bottom.equalTo(self).inset(JSHeight(30));
        make.width.height.equalTo(@(JSHeight(85)));
    }];
    
    [_pictureButton mas_makeConstraints:^(MASConstraintMaker* make){
        make.right.equalTo(_sendButton.mas_left).inset(JSWidth(35));
        make.bottom.equalTo(self).inset(JSHeight(30));
        make.width.height.equalTo(@(JSHeight(85)));
    }];
    
    [_sendButton mas_makeConstraints:^(MASConstraintMaker* make){
        make.right.equalTo(self).inset(JSWidth(24));
        make.bottom.equalTo(self).inset(JSHeight(30));
        make.width.height.equalTo(@(JSHeight(85)));
    }];
    
}
#pragma mark - Actions
- (void)emoticonButtonDidClick:(UIButton*)sender{
    NSLog(@"emoticonButton clicked");
}
- (void)pictrueButtonDidClick:(UIButton*)sender{
    NSLog(@"pictureButton clicked");
}
- (void)sendButtonDidClick:(UIButton*)sender{
    NSLog(@"sendButton clicked");
    [self mas_updateConstraints:^(MASConstraintMaker *make){
        make.height.equalTo(@(JSHeight(145)));
    }];
    
    [_messageField mas_updateConstraints:^(MASConstraintMaker *make){
        make.height.equalTo(@(JSHeight(85)));
    }];
}
#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(NSNotification *)notification {
    UITextView *textView = (UITextView *)notification.object;
    CGFloat MAXHEIGHT = JSHeight(300);
    CGSize newSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)];
    CGFloat newHeight =  newSize.height;
    newHeight = newHeight > JSHeight(85) ? newHeight : JSHeight(85);
    NSLog(@"newHeight: %f", newHeight);
    if (newHeight > MAXHEIGHT) {
        textView.scrollEnabled = YES;
        newHeight = MAXHEIGHT;
    }else{
        textView.scrollEnabled = NO;
    }
    [self mas_updateConstraints:^(MASConstraintMaker *make){
        make.height.equalTo(@(newHeight + JSHeight(60)));
    }];
    
    [textView mas_updateConstraints:^(MASConstraintMaker *make){
        //make.top.bottom.equalTo(self).inset(JSHeight(30));
        make.height.equalTo(@(newHeight));
    }];
    

    
}
@end
