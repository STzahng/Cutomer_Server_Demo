//
//  MessageCell.h
//  test1.0
//
//  Created by heiqi on 2025/4/3.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageToMeCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, copy) void (^tapAction)(NSIndexPath *indexPath);

- (void)configureWithMessage:(MessageModel *)message;

@end

NS_ASSUME_NONNULL_END
