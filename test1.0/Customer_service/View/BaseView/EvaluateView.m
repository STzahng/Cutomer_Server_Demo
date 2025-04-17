//
//  EvaluateView.m
//  test1.0
//
//  Created by heiqi on 2025/4/16.
//

#import "EvaluateView.h"
#import "ScreenScaling.h"

@interface EvaluateView()
@property (nonatomic, strong) UIImageView* solvedView;
@property (nonatomic, strong) UIImageView* unsolvedView;
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
    _solvedView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"btn_solved_unclick"]];
    _solvedView.userInteractionEnabled = YES;
    _solvedView.contentMode  = UIViewContentModeScaleAspectFit;
    
    _unsolvedView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"btn_unsolved_unclick"]];
    _unsolvedView.userInteractionEnabled = YES;
    _unsolvedView.contentMode  = UIViewContentModeScaleAspectFit;
    
    [self addSubview:_solvedView];
    [self addSubview:_unsolvedView];
    
    UITapGestureRecognizer *solvedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(solvedDidclick)];
    [_solvedView addGestureRecognizer:solvedTap];
    
    UITapGestureRecognizer *unsolvedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unsolvedDidclick)];
    [_unsolvedView addGestureRecognizer:unsolvedTap];
}

- (void)updateUIForState:(NSString *)state {
    if ([state isEqualToString:@"solved"]) {
        _solvedView.image = [UIImage imageNamed:@"btn_solved_click"];
        _unsolvedView.image = [UIImage imageNamed:@"btn_unsolved_unclick"];
        self.userInteractionEnabled = NO;
    } else if ([state isEqualToString:@"unsolved"]) {
        _unsolvedView.image = [UIImage imageNamed:@"btn_unsolved_click"]; 
        _solvedView.image = [UIImage imageNamed:@"btn_solved_unclick"];
        self.userInteractionEnabled = NO;
    } else {
        // unselected 状态
        _solvedView.image = [UIImage imageNamed:@"btn_solved_unclick"];
        _unsolvedView.image = [UIImage imageNamed:@"btn_unsolved_unclick"];
        self.userInteractionEnabled = YES;
    }
}

- (void)solvedDidclick {
    _solvedView.image = [UIImage imageNamed:@"btn_solved_click"];
    _unsolvedView.image = [UIImage imageNamed:@"btn_unsolved_unclick"];
    self.userInteractionEnabled = NO;
    
    _currentState = @"solved";
    if ([self.delegate respondsToSelector:@selector(evaluateView:didSelectState:)]) {
        [self.delegate evaluateView:self didSelectState:_currentState];
    }
}

- (void)unsolvedDidclick {
    _unsolvedView.image = [UIImage imageNamed:@"btn_unsolved_click"]; 
    _solvedView.image = [UIImage imageNamed:@"btn_solved_unclick"];
    self.userInteractionEnabled = NO;
    
    _currentState = @"unsolved";
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
    
    [_solvedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).inset(JSWidth(60));
        make.top.bottom.equalTo(self);
        //make.left.equalTo(_unsolvedView.mas_right).offset(JSWidth(80));
        make.height.equalTo(@(JSHeight(70)));
        make.width.equalTo(@(JSWidth(220)));
    }];
    
}

@end

