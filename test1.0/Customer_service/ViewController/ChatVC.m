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
#import "NoticeScrollView.h"
#import "NoticeAlertView.h"
#import "KeywordsView.h"
#import "BaseCell.h"

@interface ChatVC ()<TopBarDelegate, UITableViewDelegate, UITableViewDataSource, OptionMessageCellDelegate, NoticeScrollViewDelegate,UITextViewDelegate, KeywordsViewDelegate, BaseCellDelegate>
@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) TopBar *topBar;
@property (nonatomic, strong) BottomBar *bottomBar;
@property (nonatomic, strong) NoticeScrollView *noticeView;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) KeywordsView *keywordsView;
@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewModel];
    [self setupUI];
    [self setupConstraints];
    [self setupKeyboard];
}

- (void)setupViewModel {
    self.viewModel = [[ChatViewModel alloc] init];
    self.viewModel.delegate = self;
    MessageModel *message =  [MessageModel recommendMessageWithContent:@"推荐问题" recommendId:@"1"];;
    [self.viewModel.dataModel addMessage: message];
    
}

- (void)setupUI {
    _backgroundImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"bg_chat_background"]];
    [self.view insertSubview: self.backgroundImageView atIndex: 0];
    
    _topBar = [[TopBar alloc] init];
    _topBar.delegate = self;
    [self.view addSubview: self.topBar];
    
    _bottomBar = [[BottomBar alloc] init];
    _bottomBar.messageField.delegate = self;
    //_bottomBar.messageField.returnKeyType = UIReturnKeySend;
    [_bottomBar.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:_bottomBar.messageField];
    
    [_bottomBar.emoticonButton addTarget:self action:@selector(sendEvaluateView) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBar.pictureButton addTarget:self action:@selector(sendGradeView) forControlEvents:UIControlEventTouchUpInside];
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
    
    _keywordsView = [[KeywordsView alloc] init];
    _keywordsView.delegate = self;
    [self.view addSubview:_keywordsView];
    
    // 创建公告栏
    _noticeView = [[NoticeScrollView alloc] init];
    _noticeView.delegate = self;
    [self.view addSubview:_noticeView];

    // 设置公告内容
    NSArray *titles = @[@"公告1：系统维护通知", @"公告2：新版本更新", @"公告3：活动预告"];
    NSArray *contents = @[@"系统将于今晚12点进行维护...系统将于今晚12点进行维护...系统将于今晚12点进行维护...系统将于今晚12点进行维护...系统将于今晚12点进行维护...系统将于今晚12点进行维护...系统将于今晚12点进行维护...系统将于今晚12点进行维护...系统将于今晚12点进行维护...系统将于今晚12点进行维护...", @"新版本v2.0已发布...", @"下周将举行周年庆活动..."];
    [_noticeView setNoticeTitles:titles contents:contents];
    // 开始自动滚动（每3秒切换一次）
    [_noticeView startAutoScrollWithInterval:3.0];
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
    
    [_noticeView mas_makeConstraints:^(MASConstraintMaker* make){
        make.top.equalTo(_topBar.mas_bottom);
        make.bottom.equalTo(_tableView.mas_top);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(JSHeight(85)));
    }];
    
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker* make){
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(JSHeight(145)));
    }];
    
    [_keywordsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(_bottomBar.mas_top);
        make.height.lessThanOrEqualTo(@(JSHeight(600))); // 最多显示5个，每个高度约120
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker* make){
        make.top.equalTo(_noticeView.mas_bottom);
        make.bottom.equalTo(_bottomBar.mas_top);
        make.left.right.equalTo(self.view);
    }];
}

- (void)setupKeyboard {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeybord:)];
    [self.view addGestureRecognizer:tapGesture];
    
    // 注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
// 实现代理方法

- (void)noticeScrollView:(NoticeScrollView *)scrollView didSelectNoticeAtIndex:(NSInteger)index {
    NSString *title = scrollView.noticeTitles[index];
    NSString *content = scrollView.noticeContents[index];

    NoticeAlertView *alertView = [[NoticeAlertView alloc] initWithTitle:title notice:content];
    __weak typeof(self) weakSelf = self;

    [alertView showInView:weakSelf.view];
    
}
#pragma mark - UITextView Notification Handler

- (void)textViewDidChange:(NSNotification *)notification {
    // 1. 获取当前输入框的文本
    NSString *searchText = self.bottomBar.messageField.text;
    [self performSearchWithText:searchText];
}

- (void)performSearchWithText:(NSString *)searchText {
    if (searchText.length > 0) {

        _keywordsView.hidden = NO;
        NSArray *matchedQuestions = [self.viewModel.dataModel searchQuestionsWithKeyword:searchText];
        [_keywordsView updateWithSearchKeyword:searchText questions:matchedQuestions];
    } else {
        _keywordsView.hidden = YES;
    }
}
#pragma mark - Actions
- (void) sendEvaluateView {
    [self.viewModel sendEvaluateMessageAfterResponse];
}

- (void) sendGradeView {
    [self.viewModel sendActivityMessageAfterResponse];
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self sendButtonTapped];
    [textField resignFirstResponder];
    return YES;
}

- (void) closeKeybord:(UITapGestureRecognizer *)tapGesture {
    CGPoint location = [tapGesture locationInView: self.view];
    if (!CGRectContainsPoint(self.bottomBar.messageField.frame, location)){
        [self.view endEditing:YES];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {{
    // 获取键盘高度
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
    
    // 更新底部输入框约束
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-keyboardHeight + safeAreaInsets.bottom);
    }];
    
    // 调整内容区域滚动位置（如UITableView）
    [UIView animateWithDuration:0.3 animations:^{{
        [self.view layoutIfNeeded];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height  - keyboardHeight)];
    }}];
}}
 
- (void)keyboardWillHide:(NSNotification *)notification {{
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(0);
    }];
    [UIView animateWithDuration:0.3 animations:^{{
        [self.view layoutIfNeeded];
    }}];
}}

- (void)sendButtonTapped {
    NSString *message = self.bottomBar.messageField.text;
    if (message.length > 0) {
        [self.viewModel sendMessage:message];
        self.bottomBar.messageField.text = @"";
    }
    if (!_keywordsView.hidden){
        _keywordsView.hidden = YES;
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
            cell.tapAction = ^(NSIndexPath *indexPath) {
                // 更新对应的模型
                MessageModel *message = self.viewModel.getAllMessages[indexPath.row];
                message.isTranslated = YES;
                message.translatedContent = message.content; // 实际中应该是真正的翻译结果
                
                // 刷新UI
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            };
        }
        [cell configureWithMessage:message];
        return cell;
    } else if (message.type == MessageTypeUser){
        static NSString *cellIdentifier = @"MessageCell";
        MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell configureWithMessage:message];
        return cell;
    }else {
        static NSString *cellIdentifier = @"MessagefuntionCell";
        MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[BaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier messageType:message.type];
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
    //timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];

    timeLabel.font = [UIFont systemFontOfSize: 16];
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

#pragma mark - KeywordsViewDelegate

- (void)didSelectQuestion:(NSString *)question {
    [self.viewModel handleserach:question];
    _bottomBar.messageField.text = @"";
    _keywordsView.hidden = YES;
}

#pragma mark - BaseCellDelegate

- (void)baseCell:(BaseCell *)cell didSelectRecommendId:(NSString *)recommendId {
    [self.viewModel handleRecommendTap:recommendId];
}

- (void)baseCell:(BaseCell *)cell didUpdateGrade:(NSInteger)starRating forMessage:(MessageModel *)message {
    NSLog(@"更新评分: %ld", (long)starRating);
    [self.viewModel updateGradeForMessage:message withStarRating:starRating];
}

- (void)baseCell:(BaseCell *)cell didUpdateEvaluate:(NSString *)resolutionState forMessage:(MessageModel *)message {
    NSLog(@"更新评价状态: %@", resolutionState);
    [self.viewModel updateEvaluateForMessage:message withResolutionState:resolutionState];
}
@end
