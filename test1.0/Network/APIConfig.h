//
//  APIConfig.h
//  test1.0
//
//  Created by heiqi on 2025/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 服务器环境类型
typedef NS_ENUM(NSInteger, ServerEnvironment) {
    ServerEnvironmentDev,     // 开发环境
    ServerEnvironmentTest,    // 测试环境
    ServerEnvironmentProd     // 生产环境
};

@interface APIConfig : NSObject

// 单例方法
+ (instancetype)sharedInstance;

// 当前环境
@property (nonatomic, assign) ServerEnvironment currentEnvironment;

// 获取基础URL
- (NSString *)baseURL;

// 获取超时时间
- (NSTimeInterval)timeoutInterval;

// 获取API版本
- (NSString *)apiVersion;

// 公共请求头
- (NSDictionary *)commonHeaders;

@end

NS_ASSUME_NONNULL_END
