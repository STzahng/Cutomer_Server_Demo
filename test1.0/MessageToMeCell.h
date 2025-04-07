//
//  MessageCell.h
//  test1.0
//
//  Created by heiqi on 2025/4/3.
//
#import <UIKit/UIKit.h>
#import "MessageModel.h"

@interface MessageToMeCell : UITableViewCell

- (void)configureWithMessage:(MessageModel *)message;

@end
