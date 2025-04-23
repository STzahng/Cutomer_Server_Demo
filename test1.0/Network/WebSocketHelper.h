//
//  WebSocketHelper.h
//  test1.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebSocketHelper : NSObject

/**
 * 连接WebSocket服务器
 * @param port 端口号
 */
+ (void)connectWithPort:(NSString *)port;

/**
 * 断开WebSocket连接
 */
+ (void)disconnect;

/**
 * 发送文本消息
 * @param message 要发送的文本消息
 */
+ (void)sendTextMessage:(NSString *)message;

/**
 * 发送字典数据
 * @param dictionary 要发送的字典数据
 */
+ (void)sendDictionary:(NSDictionary *)dictionary;

/**
 * 当前连接状态
 */
+ (BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END 