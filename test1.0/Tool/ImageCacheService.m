//
//  ImageCacheService.m
//  test1.0
//
//  Created by heiqi on 2025/4/21.
//

#import "ImageCacheService.h"

@interface ImageCacheService ()

@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURLSessionDataTask *> *downloadTasks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *completionHandlers;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation ImageCacheService

#pragma mark - 初始化方法

+ (instancetype)sharedInstance {
    static ImageCacheService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _imageCache = [[NSCache alloc] init];
        _imageCache.countLimit = 100; // 最多缓存100张图片
        _imageCache.totalCostLimit = 50 * 1024 * 1024; // 50MB上限
        
        _downloadTasks = [NSMutableDictionary dictionary];
        _completionHandlers = [NSMutableDictionary dictionary];
        _serialQueue = dispatch_queue_create("com.app.imagecache.queue", DISPATCH_QUEUE_SERIAL);
        
        NSLog(@"ImageCacheService 初始化完成");
    }
    return self;
}

#pragma mark - 公共方法

- (NSString *)loadImageWithURL:(NSString *)url completion:(void (^)(UIImage * _Nullable, NSString *))completion {
    if (!url || url.length == 0) {
        NSLog(@"URL为空，无法加载图片");
        if (completion) {
            completion(nil, url);
        }
        return nil;
    }
    
    NSLog(@"请求加载图片: %@", url);
    
    // 生成一个唯一的任务ID
    NSString *taskId = [NSUUID UUID].UUIDString;
    
    // 尝试从缓存获取图片
    UIImage *cachedImage = [self cachedImageForURL:url];
    if (cachedImage) {
        // 已缓存，直接返回
        NSLog(@"已从缓存加载图片: %@", url);
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(cachedImage, url);
            });
        }
        return taskId;
    }
    
    // 在串行队列中执行，避免线程安全问题
    dispatch_async(self.serialQueue, ^{
        // 检查是否已经有正在下载的任务
        NSURLSessionDataTask *existingTask = self.downloadTasks[url];
        
        if (existingTask) {
            NSLog(@"已有下载任务，添加到回调队列: %@", url);
            // 已有下载任务，添加回调
            NSMutableArray *handlers = self.completionHandlers[url];
            if (!handlers) {
                handlers = [NSMutableArray array];
                self.completionHandlers[url] = handlers;
            }
            
            // 添加新的回调和任务ID
            NSDictionary *handlerDict = completion ? @{
                @"completion": completion,
                @"taskId": taskId
            } : @{
                @"taskId": taskId
            };
            [handlers addObject:handlerDict];
        } else {
            NSLog(@"创建新的下载任务: %@", url);
            // 创建新的下载任务
            NSURL *imageURL = [NSURL URLWithString:url];
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"图片下载失败: %@, 错误: %@", url, error);
                } else if (data) {
                    NSLog(@"图片下载成功: %@, 数据大小: %lu bytes", url, (unsigned long)data.length);
                }
                [self handleCompletionForURL:url withData:data error:error];
            }];
            
            // 保存任务和回调
            self.downloadTasks[url] = task;
            
            NSMutableArray *handlers = [NSMutableArray array];
            NSDictionary *handlerDict = completion ? @{
                @"completion": completion,
                @"taskId": taskId
            } : @{
                @"taskId": taskId
            };
            [handlers addObject:handlerDict];
            self.completionHandlers[url] = handlers;
            
            // 开始下载
            [task resume];
        }
    });
    
    return taskId;
}

- (void)cancelLoadingForURL:(NSString *)url {
    if (!url) return;
    
    NSLog(@"取消加载图片: %@", url);
    
    dispatch_async(self.serialQueue, ^{
        NSURLSessionDataTask *task = self.downloadTasks[url];
        if (task) {
            [task cancel];
            [self.downloadTasks removeObjectForKey:url];
        }
        [self.completionHandlers removeObjectForKey:url];
    });
}

- (void)cancelAllLoadings {
    NSLog(@"取消所有图片加载任务");
    
    dispatch_async(self.serialQueue, ^{
        // 取消所有任务
        for (NSURLSessionDataTask *task in [self.downloadTasks allValues]) {
            [task cancel];
        }
        
        // 清空任务和回调字典
        [self.downloadTasks removeAllObjects];
        [self.completionHandlers removeAllObjects];
    });
}

- (UIImage *)cachedImageForURL:(NSString *)url {
    if (!url) return nil;
    UIImage *image = [self.imageCache objectForKey:url];
    if (image) {
        NSLog(@"缓存命中: %@", url);
    } else {
        NSLog(@"缓存未命中: %@", url);
    }
    return image;
}

- (void)clearCache {
    NSLog(@"清除所有图片缓存");
    [self.imageCache removeAllObjects];
}

#pragma mark - 私有方法

- (void)handleCompletionForURL:(NSString *)url withData:(NSData *)data error:(NSError *)error {
    UIImage *image = nil;
    
    if (!error && data) {
        // 从数据创建图片
        image = [UIImage imageWithData:data];
        
        // 如果成功，缓存图片
        if (image) {
            NSLog(@"图片创建成功，加入缓存: %@", url);
            [self.imageCache setObject:image forKey:url cost:data.length];
        } else {
            NSLog(@"无法从数据创建图片: %@", url);
        }
    }
    
    // 在主队列回调
    dispatch_async(dispatch_get_main_queue(), ^{
        // 获取所有回调
        NSArray *handlers = [self.completionHandlers[url] copy];
        
        NSLog(@"准备执行回调，URL: %@, 回调数量: %lu", url, (unsigned long)handlers.count);
        
        // 通知所有回调
        for (NSDictionary *handler in handlers) {
            id completion = handler[@"completion"];
            if (completion && completion != [NSNull null]) {
                void(^callback)(UIImage *, NSString *) = completion;
                NSLog(@"执行回调: %@", url);
                callback(image, url);
            }
        }
        
        // 在串行队列中清理
        dispatch_async(self.serialQueue, ^{
            [self.downloadTasks removeObjectForKey:url];
            [self.completionHandlers removeObjectForKey:url];
        });
    });
}

@end 
