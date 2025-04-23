# WebSocket网络连接层

这是一个用于处理WebSocket连接的网络层实现，连接地址为`ws://192.168.91.114:3001/chat/{端口}`，并会打印收到的所有消息。

## 依赖

此实现依赖于[SocketRocket](https://github.com/facebookincubator/SocketRocket)库，请在使用前确保已添加此依赖。

### 通过CocoaPods添加依赖

在Podfile中添加：

```ruby
pod 'SocketRocket'
```

然后运行：

```bash
pod install
```

## 使用方法

### 连接到WebSocket服务器

```objc
// 连接到指定端口
[WebSocketHelper connectWithPort:@"8080"];
```

### 发送消息

```objc
// 发送文本消息
[WebSocketHelper sendTextMessage:@"Hello, WebSocket!"];

// 发送字典数据
NSDictionary *dict = @{@"type": @"message", @"content": @"Hello", @"userId": @"12345"};
[WebSocketHelper sendDictionary:dict];
```

### 断开连接

```objc
[WebSocketHelper disconnect];
```

### 检查连接状态

```objc
BOOL isConnected = [WebSocketHelper isConnected];
if (isConnected) {
    NSLog(@"WebSocket已连接");
} else {
    NSLog(@"WebSocket未连接");
}
```

## 接收消息

所有接收到的WebSocket消息会通过NSLog打印到控制台，你可以在`WebSocketManager.m`文件中的`webSocket:didReceiveMessage:`方法中处理这些消息。

如果需要添加消息处理的回调，你可以扩展WebSocketManager类，添加delegate或block回调。 