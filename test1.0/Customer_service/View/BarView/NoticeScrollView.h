//
//  NoticeScrollView.h
//  test1.0
//
//  Created by heiqi on 2025/4/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//@class NoticeScrollView;
@protocol NoticeScrollViewDelegate <NSObject>
- (void)noticeScrollView:(UIView *)scrollView didSelectNoticeAtIndex:(NSInteger)index;
@end

@interface NoticeScrollView : UIView

@property (nonatomic, weak) id<NoticeScrollViewDelegate> delegate;
@property (nonatomic, strong) NSArray<NSString *> *noticeTitles; // 公告标题数组
@property (nonatomic, strong) NSArray<NSString *> *noticeContents; // 公告内容数组
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)setNoticeTitles:(NSArray<NSString *> *)noticeTitles contents:(NSArray<NSString *> *)contents;
- (void)startAutoScrollWithInterval:(NSTimeInterval)interval;
- (void)stopAutoScroll;

@end

NS_ASSUME_NONNULL_END
