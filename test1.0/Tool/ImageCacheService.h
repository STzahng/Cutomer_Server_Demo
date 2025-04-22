//
//  ImageCacheService.h
//  test1.0
//
//  Created by heiqi on 2025/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 图片缓存服务 - 单例类，用于管理图片下载和缓存
 */
@interface ImageCacheService : NSObject

/**
 * 获取单例实例
 */
+ (instancetype)sharedInstance;

/**
 * 加载图片，支持缓存
 * @param url 图片URL
 * @param completion 完成回调，返回图片对象和原始URL
 * @return 下载任务标识，可用于取消
 */
- (NSString *)loadImageWithURL:(NSString *)url 
                    completion:(void(^)(UIImage * _Nullable image, NSString *url))completion;

/**
 * 取消指定URL的加载任务
 * @param url 图片URL
 */
- (void)cancelLoadingForURL:(NSString *)url;

/**
 * 取消所有任务的加载
 */
- (void)cancelAllLoadings;

/**
 * 从缓存获取图片，如果没有则返回nil
 * @param url 图片URL
 * @return 缓存的图片对象，不存在则为nil
 */
- (nullable UIImage *)cachedImageForURL:(NSString *)url;

/**
 * 清除所有缓存
 */
- (void)clearCache;

@end

NS_ASSUME_NONNULL_END 