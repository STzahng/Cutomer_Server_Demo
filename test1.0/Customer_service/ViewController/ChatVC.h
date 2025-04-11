//
//  ChatVC.h
//  test1.0
//
//  Created by heiqi on 2025/4/1.
//

#import <UIKit/UIKit.h>
#import "ChatViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatVC : UIViewController <ChatViewModelDelegate>

@property (nonatomic, strong) ChatViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
