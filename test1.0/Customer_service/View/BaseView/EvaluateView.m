//
//  EvaluateView.m
//  test1.0
//
//  Created by heiqi on 2025/4/16.
//

#import "EvaluateView.h"
#import "ScreenScaling.h"

@interface EvaluateView()
@property (nonatomic, strong) UIView* solvedView;
@property (nonatomic, strong) UIImageView* solved_bg;
@property (nonatomic, strong) UIImageView* solved_icon;
@property (nonatomic, strong) UILabel* solved_label;
@property (nonatomic, strong) UIView* unsolvedView;
@property (nonatomic, strong) UIImageView* unsolved_bg;
@property (nonatomic, strong) UIImageView* unsolved_icon;
@property (nonatomic, strong) UILabel* unsolved_label;
@property (nonatomic, copy, readwrite) NSString *currentState; // readwrite
@end

@implementation EvaluateView
- (instancetype)init{
    if (self = [super init]) {
        _currentState = @"unselected";
        [self setupUI];
        [self setupConstraints];
        
    }
    return self;
}

- (instancetype)initWithState:(NSString *)state {
    if (self = [super init]) {
        _currentState = state ?: @"unselected";
        [self setupUI];
        [self setupConstraints];
        
        // 根据当前状态设置UI显示
        [self updateUIForState:_currentState];
    }
    return self;
}

- (void)setupUI{
    _solvedView = [[UIView alloc] init];
    _solved_bg = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"btn_chat_yellow"]];
    _solved_bg.contentMode  = UIViewContentModeScaleAspectFit;
    [_solvedView insertSubview: _solved_bg atIndex: 0];
    
    _solved_icon = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"img_chat_like1"]];
    [_solvedView addSubview: _solved_icon];
    
    _solved_label = [[UILabel alloc] init];
    _solved_label.text = @"已解决";
    _solved_label.font = [UIFont systemFontOfSize:15];
    _solved_label.textColor = [UIColor blackColor];
    [_solvedView addSubview: _solved_label];
    
    _unsolvedView = [[UIView alloc] init];
    _unsolved_bg = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"btn_chat_blue"]];
    _unsolved_bg.contentMode  = UIViewContentModeScaleAspectFit;
    [_unsolvedView insertSubview: _unsolved_bg atIndex: 0];
    
    _unsolved_icon = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"img_chat_like2"]];
    [_unsolvedView addSubview: _unsolved_icon];
    
    _unsolved_label = [[UILabel alloc] init];
    _unsolved_label.text = @"未解决";
    _unsolved_label.font = [UIFont systemFontOfSize:16];
    _unsolved_label.textColor = [UIColor blackColor];
    [_unsolvedView addSubview: _unsolved_label];
    
    [self addSubview:_solvedView];
    [self addSubview:_unsolvedView];
    
    UITapGestureRecognizer *solvedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(solvedDidclick)];
    [_solvedView addGestureRecognizer:solvedTap];
    
    UITapGestureRecognizer *unsolvedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unsolvedDidclick)];
    [_unsolvedView addGestureRecognizer:unsolvedTap];
}

- (void)updateUIForState:(NSString *)state {
    if ([state isEqualToString:@"solved"]) {
        _solved_icon.image = [UIImage imageNamed:@"img_chat_like3"];
        _unsolved_icon.image = [UIImage imageNamed:@"img_chat_like5"];
        _unsolved_bg.image = [UIImage imageNamed:@"btn_chat_black"];
        self.userInteractionEnabled = NO;
    } else if ([state isEqualToString:@"unsolved"]) {
        _unsolved_icon.image = [UIImage imageNamed:@"img_chat_like4"];
        _solved_icon.image = [UIImage imageNamed:@"img_chat_like6"];
        _solved_bg.image = [UIImage imageNamed:@"btn_chat_black"];
        self.userInteractionEnabled = NO;
    } else {
        _solved_icon.image = [UIImage imageNamed:@"img_chat_like1"];
        _unsolved_icon.image = [UIImage imageNamed:@"img_chat_like2"];
        _solved_bg.image = [UIImage imageNamed:@"btn_chat_yellow"];
        _unsolved_bg.image = [UIImage imageNamed:@"btn_chat_blue"];
        self.userInteractionEnabled = YES;
    }
}

- (void)solvedDidclick {
    _currentState = @"solved";
    [self updateUIForState:_currentState];
    if ([self.delegate respondsToSelector:@selector(evaluateView:didSelectState:)]) {
        [self.delegate evaluateView:self didSelectState:_currentState];
    }
}

- (void)unsolvedDidclick {
    _currentState = @"unsolved";
    [self updateUIForState:_currentState];
    if ([self.delegate respondsToSelector:@selector(evaluateView:didSelectState:)]) {
        [self.delegate evaluateView:self didSelectState:_currentState];
    }
}

- (void)setupConstraints {
    [_unsolvedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).inset(JSWidth(60));
        make.top.bottom.equalTo(self);
        //make.right.equalTo(_solvedView.mas_left).offset(-JSWidth(80));
        make.height.equalTo(@(JSHeight(70)));
        make.width.equalTo(@(JSWidth(220)));
    }];
    
    [_unsolved_bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_unsolvedView);
    }];
    
    [_unsolved_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(JSWidth(40)));
        make.left.equalTo(_unsolvedView.mas_left).offset(JSWidth(28));
        make.centerY.equalTo(_unsolvedView);
    }];
    
    [_unsolved_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_unsolvedView);
        make.left.equalTo(_unsolved_icon.mas_right).offset(JSWidth(10));
    }];
    
    [_solvedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).inset(JSWidth(60));
        make.top.bottom.equalTo(self);
        make.height.equalTo(@(JSHeight(70)));
        make.width.equalTo(@(JSWidth(220)));
    }];
    
    [_solved_bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_solvedView);
    }];
    
    [_solved_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(JSWidth(40)));
        make.left.equalTo(_solvedView.mas_left).offset(JSWidth(28));
        make.centerY.equalTo(_solvedView);
    }];
    
    [_solved_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_solvedView);
        make.left.equalTo(_solved_icon.mas_right).offset(JSWidth(10));
    }];
}

@end

