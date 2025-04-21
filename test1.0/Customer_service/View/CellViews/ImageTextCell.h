//
//  imageTextCell.h
//  test1.0
//
//  Created by heiqi on 2025/4/18.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageTextCell : UITableViewCell

// 配置Cell的方法
- (void)configureWithMessage:(MessageModel *)message;

// 保存当前消息模型以便检查Cell复用状态
@property (nonatomic, strong) MessageModel *currentMessage;

@end

NS_ASSUME_NONNULL_END
