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


@interface ChatVC ()<TopBarDelegate>
@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) TopBar *topBar;
@property (nonatomic, strong) BottomBar *bottomBar;
@property (nonatomic, strong) UITableView* tableView;
@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupConstraints];
}

- (void)setupUI{
    _backgroundImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"bg_chat_background"]];
    [self.view insertSubview: self.backgroundImageView atIndex: 0];
    
    _topBar = [[TopBar alloc] init];
    [self.view addSubview: self.topBar];
    
    _bottomBar = [[BottomBar alloc] init];
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
- (NSString *)currentTimeString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE.HH:mm"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    return currentTime;
}

#pragma mark - TopBarDelegate
- (void)backButtonDidClick:(UIButton *)button {
    NSLog(@"backButton clicked");
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100; // 设置一个预估高度
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        if(indexPath.row % 2 == 0){
            
            cell = [[MessageToMeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        } else {
            
            cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
    }
    return cell;
}
@end
