//
//  NetworkManager.m
//  test1.0
//
//  Created by heiqi on 2025/4/14.
//

#import "NetworkManager.h"
#import "APIConfig.h"

@interface NetworkManager ()

@property (nonatomic, strong, readwrite) AFHTTPSessionManager *sessionManager;

@end

@implementation NetworkManager

+ (instancetype)sharedInstance {
    static NetworkManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupNetworkManager];
    }
    return self;
}

- (void)setupNetworkManager {
    // 初始化AFHTTPSessionManager
    NSURL *baseURL = [NSURL URLWithString:[[APIConfig sharedInstance] baseURL]];
    _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    // 配置超时时间
    _sessionManager.requestSerializer.timeoutInterval = [[APIConfig sharedInstance] timeoutInterval];
    // 配置请求序列化器
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 配置响应序列化器，支持JSON和HTTP
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    
    // 设置通用请求头
    NSDictionary *commonHeaders = [[APIConfig sharedInstance] commonHeaders];
    [commonHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [self.sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
    }];
    
    // 配置安全策略
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = NO;  // 正式环境设置为NO
    securityPolicy.validatesDomainName = YES;     // 正式环境设置为YES
    _sessionManager.securityPolicy = securityPolicy;
}

#pragma mark - Public Methods

- (NSURLSessionDataTask *)requestWithMethod:(RequestMethod)method
                                  URLString:(NSString *)URLString
                                 parameters:(id)parameters
                                    headers:(NSDictionary<NSString *, NSString *> *)headers
                                    success:(NetworkSuccessBlock)success
                                    failure:(NetworkFailureBlock)failure {
    
    // 添加自定义请求头
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [self.sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
    }];
    
    // 构建完整URL
    NSString *fullURL = URLString;
    if (![URLString hasPrefix:@"http"]) {
        fullURL = [NSString stringWithFormat:@"%@/%@/%@",
                   [[APIConfig sharedInstance] baseURL],
                   [[APIConfig sharedInstance] apiVersion],
                   URLString];
    }
    
    // 打印请求信息
    NSLog(@"Request URL: %@", fullURL);
    NSLog(@"Request Method: %@", [self stringFromRequestMethod:method]);
    NSLog(@"Request Params: %@", parameters);
    
    // 根据请求方法类型创建对应的请求
    NSURLSessionDataTask *dataTask = nil;
    
    switch (method) {
        case RequestMethodGET:{
            dataTask = [self.sessionManager GET:fullURL parameters:parameters headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleSuccessResponse:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleFailureResponse:task error:error failure:failure];
            }];
            break;
        }
        case RequestMethodPOST:{
            dataTask = [self.sessionManager POST:fullURL parameters:parameters headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleSuccessResponse:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleFailureResponse:task error:error failure:failure];
            }];
            break;
        }
        case RequestMethodPUT:{
            dataTask = [self.sessionManager PUT:fullURL parameters:parameters headers:headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleSuccessResponse:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleFailureResponse:task error:error failure:failure];
            }];
            break;
        }
        case RequestMethodDELETE:{
            dataTask = [self.sessionManager DELETE:fullURL parameters:parameters headers:headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleSuccessResponse:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleFailureResponse:task error:error failure:failure];
            }];
            break;
        }
        case RequestMethodPATCH:{
            dataTask = [self.sessionManager PATCH:fullURL parameters:parameters headers:headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleSuccessResponse:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleFailureResponse:task error:error failure:failure];
            }];
            break;
        }
    }
    
    return dataTask;
}


- (void)cancelAllRequests {
    [self.sessionManager.operationQueue cancelAllOperations];
}

#pragma mark - Private Methods

- (void)handleSuccessResponse:(NSURLSessionDataTask *)task responseObject:(id)responseObject success:(NetworkSuccessBlock)success {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Response Status Code: %ld", (long)httpResponse.statusCode);
    NSLog(@"Response Data: %@", responseObject);
    
    if (success) {
        success(responseObject);
    }
}

- (void)handleFailureResponse:(NSURLSessionDataTask *)task error:(NSError *)error failure:(NetworkFailureBlock)failure {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Error: %@", error);
    NSLog(@"Response Status Code: %ld", (long)httpResponse.statusCode);
    
    if (failure) {
        failure(error);
    }
}

- (NSString *)stringFromRequestMethod:(RequestMethod)method {
    switch (method) {
        case RequestMethodGET:
            return @"GET";
        case RequestMethodPOST:
            return @"POST";
        case RequestMethodPUT:
            return @"PUT";
        case RequestMethodDELETE:
            return @"DELETE";
        case RequestMethodPATCH:
            return @"PATCH";
        default:
            return @"UNKNOWN";
    }
}

@end
