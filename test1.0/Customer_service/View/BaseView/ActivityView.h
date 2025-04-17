//
//  ActivityView.h
//  test1.0
//
//  Created by heiqi on 2025/4/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ActivityView;

@protocol ActivityViewDelegate <NSObject>
- (void)activityViewDidTap:(ActivityView *)activityView withURL:(NSURL *)url;
@end

@interface ActivityView : UIView


@property (nonatomic, strong) NSURL *activityURL;
@property (nonatomic, weak) id<ActivityViewDelegate> delegate;

// 初始化方法
- (instancetype)initWithImage:(UIImage *)image 
                        title:(NSString *)title 
                     subtitle:(NSString *)subtitle 
                          url:(NSURL *)url;

// 配置方法
- (void)configureWithImage:(UIImage *)image 
                     title:(NSString *)title 
                  subtitle:(NSString *)subtitle 
                       url:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
