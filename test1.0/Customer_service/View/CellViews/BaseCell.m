//
//  BaseCell.m
//  test1.0
//
//  Created by heiqi on 2025/4/16.
//

#import "BaseCell.h"
#import "ScreenScaling.h"
#import "EvaluateView.h"
#import "GradeView.h"
#import "ActivityView.h"

@interface BaseCell() <GradeViewDelegate, EvaluateViewDelegate>

@property (nonatomic, strong) UIImageView *headpic;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *bubbleImage;
@property (nonatomic, strong) UIButton *translatedLabel;
@property (nonatomic, strong) UIView *functionView;
@property (nonatomic, strong) UIView *underline;
@property (nonatomic, assign) MessageType funtionType;

@end
@implementation BaseCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier messageType:(MessageType)type{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _funtionType = type;
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
    
    _underline = [[UIView alloc] init];
    _underline.backgroundColor = [UIColor colorWithRed:107.0/255.0
                                                                   green:132.0/255.0
                                                                    blue:145.0/255.0
                                                                   alpha:1];
    switch (_funtionType) {
        case MessageTypeEvaluate:
            _functionView = [[EvaluateView alloc] init];
            break;
        case MessageTypeGrade:
            _functionView = [[GradeView alloc] init];
            break;
        case MessageTypeActivity:
            _functionView = [[ActivityView alloc] init];
    }

    [self.contentView addSubview:_bubbleImage];
    [self.contentView addSubview:_messageLabel];
    [self.contentView addSubview:_headpic];
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_underline];
    [self.contentView addSubview:_functionView];


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

    [_underline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_messageLabel);
        make.top.equalTo(_messageLabel.mas_bottom).offset(JSHeight(20));
        make.height.equalTo(@(JSHeight(2)));
    }];
    
    [_functionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_underline.mas_bottom).offset(JSHeight(20));
        make.left.right.equalTo(_messageLabel);
        make.bottom.equalTo(_bubbleImage.mas_bottom).inset(JSHeight(20));
    }];
    
    
    [_bubbleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headpic.mas_right).offset(JSWidth(20));
        make.top.equalTo(_nameLabel.mas_bottom).offset(JSHeight(12));
        make.right.equalTo(_messageLabel.mas_right).offset(13);
        make.bottom.equalTo(_functionView.mas_bottom).offset(20);
        make.bottom.equalTo(self.contentView).offset(-JSHeight(20));
    }];
}

- (void)configureWithMessage:(MessageModel *)message {
    _message = message;
    _messageLabel.text = message.content;
    [self setupFunctionViewWithMessage:message];
}

- (void)clearFunctionView {
    if (_functionView) {
        [_functionView removeFromSuperview];
        _functionView = nil;
    }
}

- (void)setupFunctionViewWithMessage:(MessageModel *)message {
    [self clearFunctionView]; // 确保清除旧视图
    _funtionType = message.type;
    
    switch (_funtionType) {
        case MessageTypeEvaluate: {
            EvaluateView *evaluateView = [[EvaluateView alloc] initWithState:message.resolutionState];
            evaluateView.delegate = self;
            _functionView = evaluateView;
            break;
        }
        case MessageTypeGrade: {
            GradeView *gradeView = [[GradeView alloc] initWithGrade:message.starRating];
            gradeView.delegate = self;
            _functionView = gradeView;
            break;
        }
        case MessageTypeActivity:{
            ActivityView *activityView = [[ActivityView alloc] initWithImage:[UIImage imageNamed:@"banner_blessings_2024"]
                                                                       title:@"小游戏推荐"
                                                                    subtitle:@"in the game"
                                                                         url:[NSURL URLWithString:@"https://baidu.com"]];
            activityView.delegate = self;
            _functionView = activityView;
            break;
        }
        default:
            break;
    }
    
    if (_functionView) {
        [self.contentView addSubview:_functionView];
        [self setupConstraints]; // 重新设置约束
    }
}

#pragma mark - GradeViewDelegate

- (void)activityViewDidTap:(ActivityView *)activityView withURL:(NSURL *)url {
   // 处理 URL 打开，例如：
   [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)gradeView:(GradeView *)gradeView didChangeValue:(NSInteger)starRating {
    if (_message) {
        _message.starRating = starRating;
        if ([self.delegate respondsToSelector:@selector(baseCell:didUpdateGrade:forMessage:)]) {
            [self.delegate baseCell:self didUpdateGrade:starRating forMessage:_message];
        }
    }
}

#pragma mark - EvaluateViewDelegate

- (void)evaluateView:(EvaluateView *)evaluateView didSelectState:(NSString *)state {
    if (_message) {
        _message.resolutionState = state;
        _message.hasEvaluated = YES;
        if ([self.delegate respondsToSelector:@selector(baseCell:didUpdateEvaluate:forMessage:)]) {
            [self.delegate baseCell:self didUpdateEvaluate:state forMessage:_message];
        }
    }
}

@end
