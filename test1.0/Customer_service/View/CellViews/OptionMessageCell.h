//
//  OptionMessageCell.h
//  test1.0
//
//  Created by heiqi on 2025/4/7.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

@class OptionMessageCell;

@protocol OptionMessageCellDelegate <NSObject>

- (void)optionMessageCell:(OptionMessageCell *)cell didSelectRecommendId:(NSString *)recommendId;

@end

@interface OptionMessageCell : UITableViewCell

@property (nonatomic, weak) id<OptionMessageCellDelegate> delegate;
- (void)configureWithMessage:(MessageModel *)message;

@end
