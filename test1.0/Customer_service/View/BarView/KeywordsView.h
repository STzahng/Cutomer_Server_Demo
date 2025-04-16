//
//  KeywordsView.h
//  test1.0
//
//  Created by heiqi on 2025/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class KeywordsView;
@protocol KeywordsViewDelegate <NSObject>

- (void)didSelectQuestion:(NSString *)question;

@end
@interface KeywordsView : UIStackView
@property (nonatomic, weak)id<KeywordsViewDelegate>delegate;
- (void)updateWithSearchKeyword:(NSString *)keyword questions:(NSArray<NSString *> *)questions;
@end

NS_ASSUME_NONNULL_END
