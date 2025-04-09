//
//  MessageCell.h
//  test1.0
//
//  Created by heiqi on 2025/4/7.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageCell : UITableViewCell

- (void)configureWithMessage:(MessageModel *)message;

@end

NS_ASSUME_NONNULL_END
