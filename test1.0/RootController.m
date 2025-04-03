//
//  RootControllerViewController.m
//  test1.0
//
//  Created by heiqi on 2025/4/1.
//

#import "RootController.h"
#import "Masonry/Masonry.h"
#import "ChatVC.h"
@interface RootController ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView* backgroundImageView;
@end

@implementation RootController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupConstraints];
}

- (void)setupUI{
    self.backgroundImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"bg_chat_background"]];
    [self.view insertSubview: self.backgroundImageView atIndex: 0];
    
    self.button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [self.button setTitle: @"点击跳转客服" forState: UIControlStateNormal];
    [self.button setTitleColor: [UIColor blackColor] forState: UIControlStateHighlighted];
    [self.button setFont: [UIFont systemFontOfSize: 24]];
    [self.button addTarget: self action: @selector(buttonClicked) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: self.button];
    
}
- (void)setupConstraints {
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker* make){
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.left.right.equalTo(self.view);
    }];
    
    [_button mas_makeConstraints:^(MASConstraintMaker* make){
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(75);
    }];
    

}

- (void)buttonClicked {
    NSLog(@"button clicked");
    ChatVC *chatVC = [[ChatVC alloc] init];
    [self.navigationController pushViewController: chatVC animated: YES];
    
}

@end
