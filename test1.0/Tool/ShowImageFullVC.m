//
//  ShowImageFullVC.m
//  test1.0
//
//  Created by heiqi on 2025/4/28.
//

#import "ShowImageFullVC.h"
#import "ScreenScaling.h"

@interface ShowImageFullVC ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *displayimage;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation ShowImageFullVC
- (instancetype)initWithImage: (UIImage *)image{
    self = [super init];
    if (self) {
        _displayimage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupConstraints];
    
}
- (void)setupUI {
    
    self.view.backgroundColor = [UIColor blackColor];
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 4.0;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] initWithImage:_displayimage];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageView];
    
    // 添加手势识别器
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleSingleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self.scrollView addGestureRecognizer:singleTapGesture];
    

}

- (void)setupConstraints {
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.left.right.equalTo(self.view);
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.height.equalTo(@(JSSafeHeight));
        make.width.equalTo(@(JSSafeWidth));
    }];
}
#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 保持图片在缩放时居中
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0);
    
    self.imageView.center = CGPointMake(
        scrollView.contentSize.width * 0.5 + offsetX,
        scrollView.contentSize.height * 0.5 + offsetY
    );
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (self.scrollView.zoomScale  > self.scrollView.minimumZoomScale)  {
        // 当前已放大，则缩放到原始比例
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale  animated:YES];
    } else {
        // 计算双击点的放大位置
        CGPoint touchPoint = [gesture locationInView:self.imageView];
        CGRect zoomRect = [self zoomRectForScale:self.scrollView.maximumZoomScale withCenter:touchPoint];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}
 
// 计算放大区域（以点击点为中心）
- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.size.height  = self.scrollView.frame.size.height  / scale;
    zoomRect.origin.x  = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y  = center.y - (zoomRect.size.height  / 2.0);
    return zoomRect;
}

@end
