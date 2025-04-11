//
//  NoticeScrollView.m
//  test1.0
//
//  Created by heiqi on 2025/4/10.
//

#import "NoticeScrollView.h"
#import "ScreenScaling.h"
@interface NoticeScrollView()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *noticeIcon;
@property (nonatomic, strong) NSMutableArray<UIButton *> *noticeButtons;
@property (nonatomic, strong) NSTimer *scrollTimer;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGFloat buttonHeight;

@end
@implementation NoticeScrollView

- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    _backgroundImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"bg_chat_announcement"]];
    [self insertSubview: _backgroundImageView atIndex: 0];
    
    _noticeIcon = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"img_chat_announcement"]];
    [self addSubview: _noticeIcon];
    
    _noticeButtons = [NSMutableArray array];
    //self.contentInset = UIEdgeInsetsMake(0,162,self.frame.size.width,self.frame.size.height);
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.userInteractionEnabled = YES;
    _scrollView.scrollEnabled = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.clipsToBounds = YES; // 避免内容溢出
    _scrollView.delegate = self;
    _scrollView.bounces  = YES;
    [self addSubview: _scrollView];
    
    
}

- (void)setupConstraints {
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker* make){
        make.edges.equalTo(self);
        make.height.equalTo(@(JSHeight(85)));
    }];
    
    [_noticeIcon mas_makeConstraints:^(MASConstraintMaker* make){
        make.left.equalTo(self).offset(JSWidth(67));
        make.centerY.equalTo(self);
        make.width.equalTo(@(JSWidth(55)));
        make.height.equalTo(@(JSHeight(50)));
    }];
    
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_noticeIcon.mas_right).offset(JSWidth(40));
        make.right.equalTo(self);
        make.top.bottom.equalTo(self);
    }];
    

        
}
#pragma mark - Public Methods
- (void)setNoticeTitles:(NSArray<NSString *> *)noticeTitles contents:(NSArray<NSString *> *)contents {
    _noticeTitles = noticeTitles;
    _noticeContents = contents;
    _buttonHeight = JSHeight(85);
    CGFloat availableWidth = [UIScreen mainScreen].bounds.size.width - JSWidth(162); // 减去图标和边距
    
    for (UIButton *button in _noticeButtons) {
        [button removeFromSuperview];
    }
    [_noticeButtons removeAllObjects];
    
    
    for (NSInteger i = 0; i < noticeTitles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, i * _buttonHeight, availableWidth, _buttonHeight);
        button.tag = i;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleLabel.textColor = [UIColor colorWithRed:1 green:247.0/255.0 blue:184.0/255.0 alpha:1];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitle:noticeTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(noticeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        [_scrollView addSubview:button];
        [_noticeButtons addObject:button];
    }
    
    // 设置滚动区域大小 - JSWidth(162),
    _scrollView.contentSize = CGSizeMake(self.frame.size.width, _buttonHeight * noticeTitles.count);
}

- (void)startAutoScrollWithInterval:(NSTimeInterval)interval {
    [self stopAutoScroll];
    
    __weak typeof(self) weakSelf = self;
    _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:interval repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf scrollToNextNotice];
    }];
    // 将定时器添加到RunLoop中，确保滑动时不会暂停
    [[NSRunLoop currentRunLoop] addTimer:_scrollTimer forMode:NSRunLoopCommonModes];
}

- (void)stopAutoScroll {
    [_scrollTimer invalidate];
    _scrollTimer = nil;
}

#pragma mark - Private Methods
- (void)scrollToNextNotice {
    if (_noticeButtons.count == 0) {
        return;
    }
    
    _currentIndex = (_currentIndex + 1) % _noticeTitles.count;
    
    [UIView animateWithDuration:0.5 animations:^{
        self->_scrollView.contentOffset = CGPointMake(0, self->_currentIndex * self->_buttonHeight);
    }];
}

- (void)noticeButtonClicked:(UIButton *)sender {
    if (sender.tag < _noticeContents.count) {
        if ([self.delegate respondsToSelector:@selector(noticeScrollView:didSelectNoticeAtIndex:)]) {
            [self.delegate noticeScrollView:self didSelectNoticeAtIndex:sender.tag];
        }
    }
}



- (void)dealloc {
    [self stopAutoScroll];
}
@end




