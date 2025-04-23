//
//  WebSocketHelper.m
//  test1.0
//

#import "WebSocketHelper.h"
#import "WebSocketManager.h"

@implementation WebSocketHelper

+ (void)connectWithPort:(NSString *)port {
    [[WebSocketManager sharedManager] connectWithPort:port];
}

+ (void)disconnect {
    [[WebSocketManager sharedManager] disconnect];
}

+ (void)sendTextMessage:(NSString *)message {
    [[WebSocketManager sharedManager] sendMessage:message];
}

+ (void)sendDictionary:(NSDictionary *)dictionary {
    [[WebSocketManager sharedManager] sendMessage:dictionary];
}

+ (BOOL)isConnected {
    return [[WebSocketManager sharedManager] isConnected];
}

@end 