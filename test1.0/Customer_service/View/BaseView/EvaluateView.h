//
//  EvaluateView.h
//  test1.0
//
//  Created by heiqi on 2025/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EvaluateView;

@protocol EvaluateViewDelegate <NSObject>
- (void)evaluateView:(EvaluateView *)evaluateView didSelectState:(NSString *)state;
@end

@interface EvaluateView : UIView
@property (nonatomic, weak) id<EvaluateViewDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *currentState;

- (instancetype)initWithState:(NSString *)state;
@end

NS_ASSUME_NONNULL_END
