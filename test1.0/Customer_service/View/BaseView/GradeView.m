//
//  GradeView.m
//  test1.0
//
//  Created by heiqi on 2025/4/16.
//

#import "GradeView.h"
#import "ScreenScaling.h"
#import "HCSStarRatingView.h"
@interface GradeView()
@property (nonatomic, strong) HCSStarRatingView *starView;
@property (nonatomic, assign, readwrite) NSInteger currentRating;
@end

@implementation GradeView
- (instancetype)init{
    if (self = [super init]) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}
- (instancetype)initWithGrade:(NSInteger)starRating{
    if (self = [super init]) {
        _currentRating = starRating;
        [self setupUI];
        [self setupConstraints];
        _starView.value = starRating;
    }
    return self;
}
- (void)setupUI{
    _starView = [[HCSStarRatingView alloc] init];
    _starView.maximumValue = 5;
    _starView.minimumValue = 1;
    _starView.allowsHalfStars = NO;
    _starView.accurateHalfStars = YES;
    _starView.backgroundColor = [UIColor clearColor];
    _starView.emptyStarImage = [UIImage imageNamed: @"img_chat_star1"];
    _starView.filledStarImage = [UIImage imageNamed: @"img_chat_star2"];
    [_starView addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_starView];
    
}
- (void)setupConstraints {
    [_starView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.height.equalTo(@(JSHeight(80)));

    }];
    
}
- (void)didChangeValue:(HCSStarRatingView*)sender{
    //NSLog(@"starView.value:%f",_starView.value);
    _currentRating = (NSInteger)_starView.value;
    if ([self.delegate respondsToSelector:@selector(gradeView:didChangeValue:)]) {
        [self.delegate gradeView:self didChangeValue:_currentRating];
    }
}

@end
