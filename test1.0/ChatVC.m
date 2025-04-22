//
//  ChatVC.m
//  test1.0
//
//  Created by heiqi on 2025/4/9.
//

#import "ChatVC.h"
#import "MessageToMeCell.h"
#import "OptionMessageCell.h"
#import "ImageTextCell.h"
#import "ChatViewModel.h"
#import "ImageCacheService.h"

@interface ChatVC () <UITableViewDelegate, UITableViewDataSource, ChatViewModelDelegate, ImageTextCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ChatViewModel *viewModel;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;

@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化ViewModel
    _viewModel = [[ChatViewModel alloc] init];
    _viewModel.delegate = self;
    
    // 设置UI
    [self setupUI];
    
    // 添加通知监听
    [self setupNotifications];
    
    // 测试数据 - 在实际应用中应该由ChatViewModel提供
    [self addTestMessages];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 当视图即将消失时，取消所有正在进行的图片下载任务
    [[ImageCacheService sharedInstance] cancelAllLoadings];
}

- (void)dealloc {
    // 清理资源
    [[ImageCacheService sharedInstance] cancelAllLoadings];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    // 设置背景
    _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_chat_background"]];
    [self.view insertSubview:_backgroundImageView atIndex:0];
    
    // 根据您现有的UI设置顶部和底部栏
    // 这里只是示例，实际应该使用您原有的代码
    _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    _topBar.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:_topBar];
    
    _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    _bottomBar.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:_bottomBar];
    
    // 设置表格视图
    CGFloat tableViewY = _topBar.frame.size.height;
    CGFloat tableViewHeight = self.view.frame.size.height - tableViewY - _bottomBar.frame.size.height;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewY, self.view.frame.size.width, tableViewHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 注册Cell
    [_tableView registerClass:[MessageToMeCell class] forCellReuseIdentifier:@"MessageToMeCell"];
    [_tableView registerClass:[OptionMessageCell class] forCellReuseIdentifier:@"OptionMessageCell"];
    [_tableView registerClass:[ImageTextCell class] forCellReuseIdentifier:@"ImageTextCell"];
    
    [self.view addSubview:_tableView];
}

- (void)setupNotifications {
    // 监听消息模型请求通知
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleRequestMessageModel:) 
                                                 name:@"RequestMessageModelForUpdate" 
                                               object:nil];
    
    // 监听图片加载请求通知
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleRequestLoadImages:) 
                                                 name:@"RequestLoadImages" 
                                               object:nil];
    
    NSLog(@"通知监听器已设置");
}

#pragma mark - 测试数据

- (void)addTestMessages {
    // 这个方法应该由您的ChatViewModel负责
    // 这里仅作为示例，显示如何添加图文消息
    // 在实际应用中，应该使用ChatViewModel已有的方法加载消息
    
    // 添加普通消息
    MessageModel *normalMessage = [MessageModel messageWithContent:@"这是一条普通消息" type:MessageTypeUser];
    [self.viewModel addMessage:normalMessage];
    
    // 示例：添加图文消息 - 使用真实可访问的图片URL
    NSString *imageTextContent = @"这是一条包含图片的消息 #image[https://picsum.photos/300/200]{w:300,h:200} 这是图片后的文字，还有第二张图片 #image[https://picsum.photos/400/300]{w:400,h:300}";
    MessageModel *imageTextMessage = [MessageModel messageWithContent:imageTextContent type:MessageTypeImageText];
    [self.viewModel addMessage:imageTextMessage];
    
    // 在实际应用中，这应该通过ChatViewModel的方法来处理
    // [self.viewModel sendMessage:imageTextContent];
    
    // 刷新表格
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 使用您现有的ChatViewModel方法获取消息数量
    return [[self.viewModel getAllMessages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 获取消息模型
    NSArray *messages = [self.viewModel getAllMessages];
    MessageModel *message = messages[indexPath.row];
    
    if (message.type == MessageTypeImageText) {
        ImageTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageTextCell" forIndexPath:indexPath];
        // 设置代理为当前控制器
        cell.delegate = self;
        [cell configureWithMessage:message];
        
        // 启动图片加载 - 直接调用加载方法而不是依赖通知
        [self loadImagesForMessage:message];
        
        return cell;
    } else if (message.type == MessageTypeRecommend) {
        OptionMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionMessageCell" forIndexPath:indexPath];
        [cell configureWithMessage:message];
        return cell;
    } else {
        MessageToMeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageToMeCell" forIndexPath:indexPath];
        [cell configureWithMessage:message];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - ChatViewModelDelegate

// 实现ChatViewModelDelegate的方法
- (void)chatViewModel:(ChatViewModel *)viewModel didUpdateMessages:(NSArray<MessageModel *> *)messages {
    [self.tableView reloadData];
}

- (void)chatViewModel:(ChatViewModel *)viewModel didReceiveError:(NSError *)error {
    // 处理错误
    NSLog(@"Error: %@", error);
}

#pragma mark - 图片加载

// 加载指定消息的图片
- (void)loadImagesForMessage:(MessageModel *)message {
    if (message.type != MessageTypeImageText || message.imageInfos.count == 0) {
        return;
    }
    
    NSLog(@"开始加载消息图片，消息ID: %@, 图片数量: %lu", message.messageId, (unsigned long)message.imageInfos.count);
    
    for (ImageInfo *imageInfo in message.imageInfos) {
        NSLog(@"请求加载图片: %@", imageInfo.imageURL);
        
        // 使用ImageCacheService加载图片
        [[ImageCacheService sharedInstance] loadImageWithURL:imageInfo.imageURL completion:^(UIImage * _Nullable image, NSString *url) {
            if (image) {
                NSLog(@"图片加载成功: %@", url);
                // 图片加载成功，通知所有可见的ImageTextCell
                [self updateCellsWithImage:image forURL:url inMessageId:message.messageId];
            } else {
                NSLog(@"图片加载失败: %@", url);
                // 即使失败也通知UI更新，显示占位符
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 通知UI更新，即使没有图片也更新状态
                    [self notifyCellsForFailedImageLoad:url messageId:message.messageId];
                });
            }
        }];
    }
}

// 通知Cell图片加载失败
- (void)notifyCellsForFailedImageLoad:(NSString *)url messageId:(NSString *)messageId {
    for (ImageTextCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[ImageTextCell class]] && 
            [cell.messageIdentifier isEqualToString:messageId]) {
            // 通知Cell该URL的图片加载失败，以便更新UI状态
            [cell markImageAsFailedForURL:url];
        }
    }
}

// 更新所有显示指定消息的Cell
- (void)updateCellsWithImage:(UIImage *)image forURL:(NSString *)url inMessageId:(NSString *)messageId {
    NSLog(@"准备更新Cell的图片: %@, 消息ID: %@", url, messageId);
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL foundCell = NO;
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:[ImageTextCell class]]) {
                ImageTextCell *imageTextCell = (ImageTextCell *)cell;
                NSLog(@"检查Cell, Cell的messageId: %@, 目标messageId: %@", imageTextCell.messageIdentifier, messageId);
                
                if ([imageTextCell.messageIdentifier isEqualToString:messageId]) {
                    NSLog(@"找到匹配的Cell，更新图片");
                    [imageTextCell updateWithImage:image forURL:url];
                    foundCell = YES;
                }
            }
        }
        
        if (!foundCell) {
            NSLog(@"未找到匹配的Cell用于消息: %@", messageId);
        }
    });
}

#pragma mark - 通知处理

- (void)handleRequestMessageModel:(NSNotification *)notification {
    // 从通知中获取消息ID和发送者
    NSString *messageId = notification.userInfo[@"messageId"];
    id sender = notification.object;
    
    if (!messageId || ![sender isKindOfClass:[ImageTextCell class]]) {
        return;
    }
    
    // 从现有消息列表中查找对应的消息
    NSArray *messages = [self.viewModel getAllMessages];
    MessageModel *targetMessage = nil;
    
    for (MessageModel *message in messages) {
        if ([message.messageId isEqualToString:messageId]) {
            targetMessage = message;
            break;
        }
    }
    
    // 将消息模型发送回Cell
    if (targetMessage) {
        [(ImageTextCell *)sender updateFinalTextView:targetMessage];
    }
}

- (void)handleRequestLoadImages:(NSNotification *)notification {
    NSString *messageId = notification.userInfo[@"messageId"];
    if (!messageId) {
        NSLog(@"请求加载图片的通知没有消息ID");
        return;
    }
    
    NSLog(@"收到加载图片请求，消息ID: %@", messageId);
    
    // 从现有消息列表中查找对应的消息
    NSArray *messages = [self.viewModel getAllMessages];
    
    for (MessageModel *message in messages) {
        if ([message.messageId isEqualToString:messageId]) {
            NSLog(@"找到目标消息，开始加载图片");
            [self loadImagesForMessage:message];
            break;
        }
    }
}

#pragma mark - ImageTextCellDelegate

- (void)imageTextCellDidUpdateUI:(ImageTextCell *)cell withMessage:(MessageModel *)message {
    NSLog(@"收到Cell更新通知，消息ID: %@", message.messageId);
    
    // 可以在这里进行一些额外处理，比如：
    // 1. 调整tableView的布局（如果Cell高度变化）
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    // 2. 通知ViewModel消息已更新（如需要）
    // 如果ChatViewModel有对应的方法来处理消息更新
    if ([self.viewModel respondsToSelector:@selector(handleMessageUpdated:)]) {
        NSLog(@"通知ViewModel消息已更新");
        [self.viewModel performSelector:@selector(handleMessageUpdated:) withObject:message];
    }
    
    // 3. 根据需要执行其他操作
    NSLog(@"Cell更新处理完成");
}

@end 