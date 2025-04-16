//
//  KeywordsView.m
//  test1.0
//
//  Created by heiqi on 2025/4/15.
//

#import "KeywordsView.h"
#import "ScreenScaling.h"
#import "RecommendView.h"

@interface KeywordsView()
@property (nonatomic, strong) NSArray<RecommendView *> *recommendViews;

@end
@implementation KeywordsView

- (instancetype)init{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.axis = UILayoutConstraintAxisVertical;
    self.distribution = UIStackViewDistributionFillEqually;
    //self.spacing = 10;
    self.backgroundColor = [UIColor colorWithRed:44.0/255.0
                                                    green:61.0/255.0
                                                     blue:80.0/255.0
                                                    alpha:1];
    self.layoutMargins = UIEdgeInsetsMake(0, JSWidth(63), 0, JSWidth(48));
    self.layoutMarginsRelativeArrangement = YES;
}

- (void)setupConstraints{
    
}

- (void)updateWithSearchKeyword:(NSString *)keyword questions:(NSArray<NSString *> *)questions{
    // 清除现有的推荐视图
    for (UIView *view in self.arrangedSubviews) {
        [self removeArrangedSubview:view];
        [view removeFromSuperview];
    }

    UIColor *highlightColor = [UIColor colorWithRed:1.0
                                              green:204.0/255.0
                                               blue:116.0/255.0
                                              alpha:1]; 
    UIColor *normalColor = [UIColor whiteColor];     // 正常颜色
    
    NSMutableArray *views = [NSMutableArray array];
    for (NSString *question in questions) {
        RecommendView *recommendView = [[RecommendView alloc] initWithTitle:@""];
        
        // 创建富文本
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
            initWithString:question
            attributes:@{NSForegroundColorAttributeName: normalColor,
                        NSFontAttributeName: [UIFont systemFontOfSize:15]}];
        
        // 查找关键词位置
        NSRange keywordRange = [question rangeOfString:keyword];
        if (keywordRange.location != NSNotFound) {
            // 设置关键词部分的颜色
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:highlightColor
                                     range:keywordRange];
        }
        
        // 设置富文本
        [recommendView setupWithAttributedTitle:attributedString];
        
        recommendView.tapAction = ^{
            [self.delegate didSelectQuestion:question];
        };
        
        [views addObject:recommendView];
        [self addArrangedSubview:recommendView];
        [recommendView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(JSWidth(63));
            make.right.equalTo(self.mas_right).offset(-JSWidth(48));
            make.height.equalTo(@(JSHeight(120)));
        }];

    }
    _recommendViews = [views copy];
}
@end
