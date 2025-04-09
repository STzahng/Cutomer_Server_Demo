//
//  OptionMessageCell.h
//  test1.0
//
//  Created by heiqi on 2025/4/7.
//
#import <UIKit/UIKit.h>
#import "MessageModel.h"

@interface OptionMessageCell : UITableViewCell

@property (nonatomic, copy) void (^optionClickBlock)(NSInteger optionIndex);

/**
 * 配置引导文本和选项按钮
 * @param guideText 引导文本
 * @param options 选项按钮文本数组
 */
- (void)configureWithGuideText:(NSString *)guideText options:(NSArray<NSString *> *)options;

/**
 * 配置消息模型
 * @param message 消息模型
 */
- (void)configureWithMessage:(MessageModel *)message;

@end 