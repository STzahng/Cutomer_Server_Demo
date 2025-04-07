//
//  CustomerServiceViewModel.h
//  test1.0
//
//  Created by heiqi on 2025/4/3.
//

#import <Foundation/Foundation.h>
#import "MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomerServiceViewModel : NSObject

@property (nonatomic, strong, readonly) NSArray<MessageModel *> *messages;

@end

NS_ASSUME_NONNULL_END
