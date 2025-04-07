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
    
    // 设置自动计算高度相关属性
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = JSHeight(200);  // 设置一个更合理的预估高度
    
    // 注册cell
    [_tableView registerClass:[MessageToMeCell class] forCellReuseIdentifier:@"cell"];
    
    [self.view addSubview:_tableView];
} 