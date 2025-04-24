//
//  WebSocketManager.h
//  test1.0
//
//  Created by heiqi on 2025/4/20
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebSocketManager : NSObject

+ (instancetype)sharedInstance;

/**
 * 连接WebSocket服务器
 * @param port 端口号
 */
- (void)connectWithPort:(NSString *)port;

/**
 * 断开WebSocket连接
 */
- (void)disconnect;

/**
 * 发送消息
 * @param message 要发送的消息
 */
- (void)sendMessage:(id)message;

/**
 * 当前连接状态
 */
- (BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END 
