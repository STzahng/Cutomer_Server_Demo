//
//  GradeView.h
//  test1.0
//
//  Created by heiqi on 2025/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GradeView;

@protocol GradeViewDelegate <NSObject>
- (void)gradeView:(GradeView *)gradeView didChangeValue:(NSInteger)starRating;
@end

@interface GradeView : UIView
@property (nonatomic, weak) id<GradeViewDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger currentRating;
- (instancetype)initWithGrade:(NSInteger)starRating;
@end

NS_ASSUME_NONNULL_END
