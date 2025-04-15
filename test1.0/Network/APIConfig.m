//
//  APIConfig.m
//  test1.0
//
//  Created by heiqi on 2025/4/14.
//

#import "APIConfig.h"

@implementation APIConfig

+ (instancetype)sharedInstance {
    static APIConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.currentEnvironment = ServerEnvironmentDev;
    });
    return instance;
}

- (NSString *)baseURL {
    switch (self.currentEnvironment) {
        case ServerEnvironmentDev:
            return @"https://dev-api.example.com";
        case ServerEnvironmentTest:
            return @"https://test-api.example.com";
        case ServerEnvironmentProd:
            return @"https://api.example.com";
        default:
            return @"https://api.example.com";
    }
}

- (NSTimeInterval)timeoutInterval {
    return 30.0; // 默认30秒超时
}

- (NSString *)apiVersion {
    return @"v1";
}

- (NSDictionary *)commonHeaders {
    return @{
        @"Content-Type": @"application/json",
        @"Accept": @"application/json",
        @"app-version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
        @"platform": @"iOS"
    };
}

@end
