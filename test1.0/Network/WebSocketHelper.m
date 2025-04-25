//
//  WebSocketHelper.m
//  test1.0
//

#import "WebSocketHelper.h"
#import "WebSocketManager.h"

@implementation WebSocketHelper

+ (void)connectWithPort:(NSString *)port {
    [[WebSocketManager sharedInstance] connectWithPort:port];
}

+ (void)disconnect {
    [[WebSocketManager sharedInstance] disconnect];
}

+ (void)sendTextMessage:(NSString *)message {
    [[WebSocketManager sharedInstance] sendNetWorkMessage:message];
}

+ (void)sendDictionary:(NSDictionary *)dictionary {
    [[WebSocketManager sharedInstance] sendNetWorkMessage:dictionary];
}

+ (BOOL)isConnected {
    return [[WebSocketManager sharedInstance] isConnected];
}

@end 
