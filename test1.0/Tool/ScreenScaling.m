//
//  ScreenScaling.m
//  test1.0
//
//  Created by heiqi on 2025/4/3.
//

#import "ScreenScaling.h"

@interface ScreenScaling ()
@property (nonatomic, assign) CGFloat designWidth;
@property (nonatomic, assign) CGFloat designHeight;
@property (nonatomic, assign) CGFloat widthScale;
@property (nonatomic, assign) CGFloat heightScale;
@property (nonatomic, assign) CGFloat safeAreaWidth;
@property (nonatomic, assign) CGFloat safeAreaHeight;
@end

@implementation ScreenScaling

+ (instancetype)sharedInstance {
    static ScreenScaling *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ScreenScaling alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _designWidth = 1080;
        _designHeight = 1920;
        [self updateScale];
    }
    return self;
}

- (void)updateScale {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    UIEdgeInsets safeAreaInsets = window.safeAreaInsets;
    CGFloat screenWidth = window.bounds.size.width;
    CGFloat screenHeight = window.bounds.size.height;
    
    // 计算实际可用区域
    CGFloat availableWidth = screenWidth - safeAreaInsets.left - safeAreaInsets.right;
    CGFloat availableHeight = screenHeight - safeAreaInsets.top - safeAreaInsets.bottom;
    
    // 保存安全区域的尺寸
    _safeAreaWidth = availableWidth;
    _safeAreaHeight = availableHeight;
    
    // 计算缩放比例
    _widthScale = availableWidth / _designWidth;
    _heightScale = availableHeight / _designHeight;
}

- (CGFloat)getWidth:(CGFloat)width {
    return width * _widthScale;
}

- (CGFloat)getHeight:(CGFloat)height {
    return height * _heightScale;
}

- (CGFloat)getSafeAreaWidth {
    // 确保数据是最新的
    [self updateScale];
    return _safeAreaWidth;
}

- (CGFloat)getSafeAreaHeight {
    // 确保数据是最新的
    [self updateScale];
    return _safeAreaHeight;
}

@end 
