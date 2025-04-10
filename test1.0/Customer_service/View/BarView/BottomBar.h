//
//  BottomBar.h
//  test1.0
//
//  Created by heiqi on 2025/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BottomBar : UIView <UITextViewDelegate>
@property (nonatomic,strong) UIImageView *backgroundImageView;
@property (nonatomic,strong) UITextView *messageField;
@property (nonatomic,strong) UIButton *emoticonButton;
@property (nonatomic,strong) UIButton *pictureButton;
@property (nonatomic,strong) UIButton *sendButton;
@end

NS_ASSUME_NONNULL_END
