//
//  WebSocketManager.m
//  test1.0
//
//  Created by heiqi on 2025/4/20
//

#import "WebSocketManager.h"
#import <SocketRocket/SRWebSocket.h>

@interface WebSocketManager () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) BOOL isConnecting;

@end

@implementation WebSocketManager

+ (instancetype)sharedInstance {
    static WebSocketManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WebSocketManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isConnecting = NO;
    }
    return self;
}

#pragma mark - Public Methods

- (void)connectWithPort:(NSString *)port {
    if (self.isConnecting) {
        return;
    }
    
    [self disconnect];
    
    self.isConnecting = YES;
    
    // 构建WebSocket URL
    self.urlString = [NSString stringWithFormat:@"ws://192.168.91.114:3001/chat/%@", port];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    self.webSocket.delegate = self;
    
    NSLog(@"正在连接WebSocket: %@", self.urlString);
    [self.webSocket open];
}

- (void)disconnect {
    if (self.webSocket) {
        self.webSocket.delegate = nil;
        [self.webSocket close];
        self.webSocket = nil;
        self.isConnecting = NO;
        NSLog(@"WebSocket已断开连接");
    }
}

- (void)sendMessage:(id)message {
    if (![self isConnected]) {
        NSLog(@"WebSocket未连接，无法发送消息");
        return;
    }
    
    NSString *jsonString = nil;
    
    if ([message isKindOfClass:[NSString class]]) {
        jsonString = message;
    } else if ([message isKindOfClass:[NSDictionary class]] || [message isKindOfClass:[NSArray class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    
    if (jsonString) {
        //NSLog(@"WebSocket发送消息: %@", jsonString);
        [self.webSocket send:jsonString];
    } else {
        //NSLog(@"WebSocket发送消息失败: 无效的消息格式");
    }
}

- (BOOL)isConnected {
    return self.webSocket && self.webSocket.readyState == SR_OPEN;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    self.isConnecting = NO;
    //NSLog(@"WebSocket连接成功: %@", self.urlString);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    self.isConnecting = NO;
    self.webSocket = nil;
    //NSLog(@"WebSocket连接失败: %@", error.localizedDescription);
    
    // 可以在这里添加重连逻辑
    // [self reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    // 先打印原始消息长度，便于调试
    if ([message isKindOfClass:[NSString class]]) {
        //NSLog(@"收到WebSocket原始字符串消息，长度: %lu", (unsigned long)[(NSString *)message length]);
    } else if ([message isKindOfClass:[NSData class]]) {
        //NSLog(@"收到WebSocket原始数据消息，长度: %lu bytes", (unsigned long)[(NSData *)message length]);
    } else {
        //NSLog(@"收到WebSocket未知类型消息: %@", [message class]);
    }
    
    // 转换为NSData进行处理
    NSData *jsonData;
    if ([message isKindOfClass:[NSString class]]) {
        NSString *messageStr = (NSString *)message;
        // 检查是否是URL编码的字符串
        if ([messageStr hasPrefix:@"%"]) {
            // URL解码
            NSString *decodedString = [messageStr stringByRemovingPercentEncoding];
            if (decodedString) {
                jsonData = [decodedString dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                jsonData = [messageStr dataUsingEncoding:NSUTF8StringEncoding];
            }
        } else {
            jsonData = [messageStr dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        // 打印原始字符串消息，避免截断
        NSLog(@"原始字符串消息: %@", messageStr);
    } else if ([message isKindOfClass:[NSData class]]) {
        jsonData = message;
        
        // 尝试将数据直接转换为字符串
        NSString *rawString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (rawString) {
            //NSLog(@"数据转字符串: %@", rawString);
        } else {
            //NSLog(@"数据无法转换为UTF-8字符串");
        }
    } else {
        //NSLog(@"未知消息类型，无法处理");
        return;
    }
    
    // 尝试解析JSON
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                   options:kNilOptions
                                                     error:&jsonError];
    if (jsonError) {
        //NSLog(@"JSON解析失败 - 错误: %@", jsonError.localizedDescription);
        // 尝试以不同编码方式解析
        NSArray *encodings = @[@(NSUTF8StringEncoding), @(NSASCIIStringEncoding), @(NSISOLatin1StringEncoding)];
        for (NSNumber *encoding in encodings) {
            NSStringEncoding enc = [encoding unsignedIntegerValue];
            NSString *encodedString = [[NSString alloc] initWithData:jsonData encoding:enc];
            if (encodedString) {
                //NSLog(@"使用编码 %lu 解析: %@", (unsigned long)enc, encodedString);
                break;
            }
        }
    } else {
        // 美化输出JSON
        if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
            NSData *prettyData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                                options:NSJSONWritingPrettyPrinted
                                                                  error:nil];
            NSString *prettyString = [[NSString alloc] initWithData:prettyData encoding:NSUTF8StringEncoding];
            
            // 将JSON分段打印，避免被截断
            //NSLog(@"收到JSON消息开始 ================");
            
            // 分段输出，每次最多输出1000个字符
            NSUInteger length = [prettyString length];
            NSUInteger chunkSize = 1000;
            NSUInteger offset = 0;
            
            while (offset < length) {
                NSUInteger thisChunkSize = MIN(chunkSize, length - offset);
                NSString *chunk = [prettyString substringWithRange:NSMakeRange(offset, thisChunkSize)];
                NSLog(@"%@", chunk);
                offset += thisChunkSize;
            }
            
            //NSLog(@"收到JSON消息结束 ================");
            
            // 发送通知，将解析后的JSON对象传递给监听者
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WebSocketMessageReceived"
                                                                object:nil
                                                              userInfo:@{@"message": jsonObject}];
        } else {
            //NSLog(@"收到非标准JSON对象: %@", jsonObject);
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    self.isConnecting = NO;
    self.webSocket = nil;
    //NSLog(@"WebSocket已关闭, code: %ld, reason: %@, wasClean: %d", (long)code, reason, wasClean);
    
    // 可以在这里添加重连逻辑
    // [self reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    //NSLog(@"WebSocket收到pong响应");
}

@end 

//{
//    "method" : "setChatResources"
//    "params" :{
//        {
//            "res_url":""
//            "avatar_res_url":""
//            "emoji_groups":[EmojiGroup] // 不设置则不显示
//            "share_msg_groups" : [ShareMsgGroup]
//        }
//        
//    }
//    
//}
