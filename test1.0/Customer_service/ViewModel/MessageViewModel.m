//
//  MessageViewModel.m
//  test1.0
//
//  Created by heiqi on 2025/5/11.
//

#import "MessageViewModel.h"
#import "ImageCacheService.h"

@interface MessageViewModel ()

// 消息数组，用于存储所有消息
@property (nonatomic, strong) NSMutableArray<MessageModel *> *messageArray;
// 消息ID到消息的映射，用于快速查找
@property (nonatomic, strong) NSMutableDictionary<NSString *, MessageModel *> *messageDict;
// 正在加载图片的消息ID集合
@property (nonatomic, strong) NSMutableSet<NSString *> *loadingMessageIds;

@end

@implementation MessageViewModel

#pragma mark - 初始化方法

- (instancetype)init {
    if (self = [super init]) {
        _messageArray = [NSMutableArray array];
        _messageDict = [NSMutableDictionary dictionary];
        _loadingMessageIds = [NSMutableSet set];
    }
    return self;
}

#pragma mark - 公共方法

- (void)addMessage:(MessageModel *)message {
    if (!message || !message.messageId) {
        return;
    }
    
    // 防止重复添加相同ID的消息
    if (self.messageDict[message.messageId]) {
        return;
    }
    
    // 如果是图文消息，确保已经解析过图片信息
    if (message.type == MessageTypeImageText && (!message.imageInfos || !message.processedTextContent)) {
        [message parseImageTextContent];
    }
    
    // 添加到数组和字典
    [self.messageArray addObject:message];
    self.messageDict[message.messageId] = message;
}

- (MessageModel *)messageAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.messageArray.count) {
        return nil;
    }
    return self.messageArray[index];
}

- (NSInteger)messageCount {
    return self.messageArray.count;
}

- (NSArray<MessageModel *> *)messages {
    return [self.messageArray copy];
}

- (MessageModel *)messageWithId:(NSString *)messageId {
    if (!messageId) {
        return nil;
    }
    return self.messageDict[messageId];
}

- (void)loadImagesForMessageId:(NSString *)messageId {
    // 检查消息ID是否有效
    MessageModel *message = [self messageWithId:messageId];
    if (!message || message.type != MessageTypeImageText || message.imageInfos.count == 0) {
        return;
    }
    
    // 检查是否正在加载
    if ([self.loadingMessageIds containsObject:messageId]) {
        return;
    }
    
    // 标记为正在加载
    [self.loadingMessageIds addObject:messageId];
    
    // 加载所有图片
    __weak typeof(self) weakSelf = self;
    for (ImageInfo *imageInfo in message.imageInfos) {
        // 检查图片缓存
        UIImage *cachedImage = [[ImageCacheService sharedInstance] cachedImageForURL:imageInfo.imageURL];
        if (cachedImage) {
            // 有缓存，直接通知代理
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didLoadImage:forURL:inMessageId:)]) {
                [weakSelf.delegate didLoadImage:cachedImage forURL:imageInfo.imageURL inMessageId:messageId];
            }
            continue;
        }
        
        // 异步加载图片
        [[ImageCacheService sharedInstance] loadImageWithURL:imageInfo.imageURL completion:^(UIImage * _Nullable image, NSString *url) {
            if (image) {
                // 加载成功，通知代理
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 检查ViewModel是否还存在
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (!strongSelf) return;
                    
                    // 通知代理
                    if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(didLoadImage:forURL:inMessageId:)]) {
                        [strongSelf.delegate didLoadImage:image forURL:url inMessageId:messageId];
                    }
                    
                    // 检查是否所有图片都加载完成
                    [strongSelf checkAllImagesLoadedForMessageId:messageId];
                });
            } else {
                // 加载失败，也需要检查是否所有请求都完成了
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (!strongSelf) return;
                    [strongSelf checkAllImagesLoadedForMessageId:messageId];
                });
            }
        }];
    }
}

#pragma mark - 私有方法

// 检查指定消息的所有图片是否都已加载完成
- (void)checkAllImagesLoadedForMessageId:(NSString *)messageId {
    MessageModel *message = [self messageWithId:messageId];
    if (!message) {
        [self.loadingMessageIds removeObject:messageId];
        return;
    }
    
    // 检查是否所有图片都已经有缓存
    BOOL allLoaded = YES;
    for (ImageInfo *imageInfo in message.imageInfos) {
        UIImage *cachedImage = [[ImageCacheService sharedInstance] cachedImageForURL:imageInfo.imageURL];
        if (!cachedImage) {
            allLoaded = NO;
            break;
        }
    }
    
    // 如果所有图片都已加载，移除加载标记
    if (allLoaded) {
        [self.loadingMessageIds removeObject:messageId];
    }
}

@end 