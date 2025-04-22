//
//  ImageTextCell.h
//  test1.0
//
//  Created by heiqi on 2025/4/18.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"
#import "ChatViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ImageTextCell;

@protocol ImageTextCellDelegate <NSObject>
- (void)imageTextCell:(ImageTextCell *)cell withMessage:(MessageModel *)message;
@end

@interface ImageTextCell : UITableViewCell

@property (nonatomic, weak) id<ImageTextCellDelegate> delegate;
- (void)configureWithMessage:(MessageModel *)message;

/**
 * 更新Cell的图片，当某个图片加载完成时调用
 * @param image 加载完成的图片
 * @param url 图片URL
 */
- (void)updateWithImage:(UIImage *)image forURL:(NSString *)url;

/**
 * 标记指定URL的图片加载失败
 * @param url 图片URL
 */
- (void)markImageAsFailedForURL:(NSString *)url;

/**
 * 根据消息模型更新最终文本视图
 * @param message 消息模型
 */
- (void)updateFinalTextView:(MessageModel *)message;

/**
 * 消息标识符，用于跟踪Cell生命周期中正在显示的消息
 */
@property (nonatomic, copy, readonly) NSString *messageIdentifier;

// 保存当前消息模型以便检查Cell复用状态
@property (nonatomic, strong) MessageModel *currentMessage;

@end

NS_ASSUME_NONNULL_END
