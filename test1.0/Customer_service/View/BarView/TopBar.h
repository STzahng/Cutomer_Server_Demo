//
//  TopBar.h
//  test1.0
//
//  Created by heiqi on 2025/4/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TopBarDelegate <NSObject>
@optional
- (void) backButtonDidClick:(UIButton *)sender;

@end

@interface TopBar : UIView
@property (nonatomic,strong) UIImageView* backgroundImageView;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,weak) id<TopBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
