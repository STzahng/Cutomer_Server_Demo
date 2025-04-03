//
//  AppDelegate.m
//  test
//
//  Created by heiqi on 2025/4/1.
//

#import "AppDelegate.h"
#import "RootController.h"
@interface AppDelegate ()
@property (nonatomic, strong) UINavigationController *navC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *vc = [[RootController alloc] init];
    _navC = [[UINavigationController alloc] initWithRootViewController:vc];
    _navC.navigationBarHidden = YES;
    self.window.rootViewController = _navC;
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
