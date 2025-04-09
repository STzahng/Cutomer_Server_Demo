//
//  RecommendView.h
//  test1.0
//
//  Created by heiqi on 2025/4/7.
//

#import <UIKit/UIKit.h>

@interface RecommendView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) void (^tapAction)(void);

- (instancetype)initWithTitle:(NSString *)title;
- (void)setupWithTitle:(NSString *)title;

@end 