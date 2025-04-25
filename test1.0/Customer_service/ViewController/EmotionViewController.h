//
//  EmotionViewController.h
//  test1.0
//
//  Created by heiqi on 2025/4/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EmotionViewDelegate <NSObject>
// 当选择表情图片时调用
- (void)didSelectEmojiWithInfo:(UIImage *)emojiInfo;
@end

@interface EmotionViewController : UICollectionViewController

// 获取表情面板高度
- (CGFloat)emotionViewHeight;

// 代理属性
@property (nonatomic, weak) id<EmotionViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END 
