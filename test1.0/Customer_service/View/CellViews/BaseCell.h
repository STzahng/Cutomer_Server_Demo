//
//  BaseCell.h
//  test1.0
//
//  Created by heiqi on 2025/4/16.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"
NS_ASSUME_NONNULL_BEGIN

@class BaseCell;

@protocol BaseCellDelegate <NSObject>

- (void)baseCell:(BaseCell *)cell didSelectRecommendId:(NSString *)recommendId;
- (void)baseCell:(BaseCell *)cell didUpdateGrade:(NSInteger)starRating forMessage:(MessageModel *)message;
- (void)baseCell:(BaseCell *)cell didUpdateEvaluate:(NSString *)resolutionState forMessage:(MessageModel *)message;

@end

@interface BaseCell : UITableViewCell

@property (nonatomic, weak) id<BaseCellDelegate> delegate;
@property (nonatomic, strong) MessageModel *message;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier messageType:(MessageType)type;
- (void)configureWithMessage:(MessageModel *)message;

@end


NS_ASSUME_NONNULL_END
