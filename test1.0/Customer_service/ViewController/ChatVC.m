//
//  ChatVC.m
//  test1.0
//
//  Created by heiqi on 2025/4/1.
//

#import "ChatVC.h"
#import "Masonry/Masonry.h"
#import "ScreenScaling.h"
#import "TopBar.h"
#import "BottomBar.h"
#import "MessageToMeCell.h"
#import "MessageCell.h"
#import "OptionMessageCell.h"

@interface ChatVC ()<TopBarDelegate, UITableViewDelegate, UITableViewDataSource, OptionMessageCellDelegate>
@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) TopBar *topBar;
@property (nonatomic, strong) BottomBar *bottomBar;
@property (nonatomic, strong) UITableView* tableView;
@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewModel];
    [self setupUI];
    [self setupConstraints];
}

- (void)setupViewModel {
    self.viewModel = [[ChatViewModel alloc] init];
    self.viewModel.delegate = self;
    MessageModel *message =  [MessageModel recommendMessageWithContent:@"推荐问题" recommendId:@"1"];;
    [self.viewModel.dataModel addMessage: message];
    //[self updateUI];
}

- (void)setupUI {
    _backgroundImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"bg_chat_background"]];
    [self.view insertSubview: self.backgroundImageView atIndex: 0];
    
    _topBar = [[TopBar alloc] init];
    _topBar.delegate = self;
    [self.view addSubview: self.topBar];
    
    _bottomBar = [[BottomBar alloc] init];
    [_bottomBar.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.bottomBar];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundView = nil;
    _tableView.sectionHeaderHeight = JSHeight(95);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 100;
    
    [self.view addSubview:_tableView];
}

- (void)setupConstraints {
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker* make){
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.left.right.equalTo(self.view);
    }];
    
    [_topBar mas_makeConstraints:^(MASConstraintMaker* make){
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(JSHeight(90)));
    }];
    
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker* make){
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(JSHeight(145)));
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker* make){
        make.top.equalTo(_topBar.mas_bottom);
        make.bottom.equalTo(_bottomBar.mas_top);
        make.left.right.equalTo(self.view);
    }];
}

#pragma mark - Actions

- (void)sendButtonTapped {
    NSString *message = self.bottomBar.messageField.text;
    if (message.length > 0) {
        [self.viewModel sendMessage:message];
        self.bottomBar.messageField.text = @"";
    }
}

- (NSString *)currentTimeString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE.HH:mm"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    return currentTime;
}

#pragma mark - ChatViewModelDelegate

- (void)chatViewModel:(ChatViewModel *)viewModel didUpdateMessages:(NSArray<MessageModel *> *)messages {
    [self.tableView reloadData];
    if (messages.count > 0) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:messages.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)chatViewModel:(ChatViewModel *)viewModel didReceiveError:(NSError *)error {
    // 处理错误
    NSLog(@"Error: %@", error.localizedDescription);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.getAllMessages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100; // 设置一个预估高度
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageModel *message = self.viewModel.getAllMessages[indexPath.row];
    if(message.type == MessageTypeRecommend){
        static NSString *cellIdentifier = @"OptionMessageCell";
        OptionMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[OptionMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.delegate = self;
        }
        [cell configureWithMessage:message];
        return cell;
    }
    else if (message.type == MessageTypeSystem) {
        static NSString *cellIdentifier = @"MessageToMeCell";
        MessageToMeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[MessageToMeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell configureWithMessage:message];
        return cell;
    } else {
        static NSString *cellIdentifier = @"MessageCell";
        MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell configureWithMessage:message];
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel* timeLabel = [[UILabel alloc] init];
    timeLabel.text = [self currentTimeString];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont systemFontOfSize: 20];
    [headerView addSubview: timeLabel];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker* make){
        make.centerX.equalTo(headerView);
        make.bottom.equalTo(headerView.mas_bottom);
    }];
    
    return headerView;
}

#pragma mark - TopBarDelegate

- (void)backButtonDidClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - OptionMessageCellDelegate

- (void)optionMessageCell:(OptionMessageCell *)cell didSelectRecommendId:(NSString *)recommendId {
    [self.viewModel handleRecommendTap:recommendId];
}

@end
