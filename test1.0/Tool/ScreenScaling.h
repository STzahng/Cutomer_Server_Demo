//
//  ScreenScaling.h
//  test1.0
//
//  Created by heiqi on 2025/4/3.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

#define JSWidth(width) [[ScreenScaling sharedInstance] getWidth:width]
#define JSHeight(height) [[ScreenScaling sharedInstance] getHeight:height]
#define JSSafeWidth [[ScreenScaling sharedInstance] getSafeAreaWidth]
#define JSSafeHeight [[ScreenScaling sharedInstance] getSafeAreaHeight]

@interface ScreenScaling : NSObject

+ (instancetype)sharedInstance;

// 计算实际宽度
- (CGFloat)getWidth:(CGFloat)width;

// 计算实际高度
- (CGFloat)getHeight:(CGFloat)height;

//返回当前屏幕安全区的宽度
- (CGFloat)getSafeAreaWidth;

//返回当前屏幕安全区的高度
- (CGFloat)getSafeAreaHeight;

@end

NS_ASSUME_NONNULL_END 
