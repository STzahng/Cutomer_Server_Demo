//
//  RecommendView.h
//  test1.0
//
//  Created by heiqi on 2025/4/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecommendView : UIView

@property (nonatomic, copy) void (^tapAction)(void);

- (instancetype)initWithTitle:(NSString *)title;
- (void)setupWithAttributedTitle:(NSAttributedString *)attributedTitle;
@end

NS_ASSUME_NONNULL_END
