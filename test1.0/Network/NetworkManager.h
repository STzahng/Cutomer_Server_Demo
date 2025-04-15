//
//  NetworkManager.h
//  test1.0
//
//  Created by heiqi on 2025/4/14.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


NS_ASSUME_NONNULL_BEGIN
typedef void(^NetworkSuccessBlock)(id _Nullable responseObject);
typedef void(^NetworkFailureBlock)(NSError *error);
typedef void(^NetworkProgressBlock)(NSProgress *progress);

typedef NS_ENUM(NSInteger, RequestMethod) {
    RequestMethodGET,
    RequestMethodPOST,
    RequestMethodPUT,
    RequestMethodDELETE,
    RequestMethodPATCH
};

@interface NetworkManager : NSObject
@property (nonatomic, strong, readonly) AFHTTPSessionManager *sessionManager;

+ (instancetype)sharedInstance;
- (NSURLSessionDataTask *)requestWithMethod:(RequestMethod)method
                                  URLString:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    headers:(nullable NSDictionary<NSString *, NSString *> *)headers
                                    success:(nullable NetworkSuccessBlock)success
                                    failure:(nullable NetworkFailureBlock)failure;

- (void)cancelAllRequests;

@end

NS_ASSUME_NONNULL_END
