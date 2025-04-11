//
//  NoticeAlertView.h
//  test1.0
//
//  Created by heiqi on 2025/4/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoticeAlertView : UIView
- (instancetype)initWithTitle:(NSString *)title notice:(NSString *)notice;
- (void)showInView:(UIView *)view;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UITextView *noticeText;

@property (nonatomic, copy) void (^tapAction)(void);
@end

NS_ASSUME_NONNULL_END
