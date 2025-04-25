//
//  EmotionViewController.m
//  test1.0
//
//  Created by heiqi on 2025/4/1.
//

#import "EmotionViewController.h"
#import "ScreenScaling.h"
#import "EmojiViewModel.h"

@interface EmotionViewController () < UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic, assign) NSInteger visibleRows;
@property (nonatomic, assign) NSInteger totalRows;
@property (nonatomic, assign) NSInteger emotionsPerRow;
@property (nonatomic, assign) CGFloat itemSize;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, strong) NSArray *emojiData; // 表情数据源
@property (nonatomic, strong) EmojiViewModel *emojiViewModel;

@end

@implementation EmotionViewController
- (instancetype)init {
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:layout];
    if(self){
        _visibleRows = 4;
        _emotionsPerRow = 9;
        _itemSpacing = JSWidth(20);
        _itemSize = (JSSafeWidth - 2 * _itemSpacing - 8 * _itemSpacing) / _emotionsPerRow;

        
        layout.itemSize = CGSizeMake(_itemSize, _itemSize);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = _itemSpacing;
        layout.minimumLineSpacing = _itemSpacing;
        layout.sectionInset = UIEdgeInsetsMake(_itemSpacing, _itemSpacing, _itemSpacing, _itemSpacing);

        
        // 获取EmojiViewModel单例
        _emojiViewModel = [EmojiViewModel sharedInstance];
        
        // 注册表情数据状态变化的回调
        __weak typeof(self) weakSelf = self;
        _emojiViewModel.onEmojiDataStatusChanged = ^(BOOL isLoaded) {
            if (isLoaded) {
                [weakSelf loadEmojisFromViewModel];
            }
        };
        
        // 注册表情图片更新的回调
        [_emojiViewModel registerForImageUpdateWithBlock:^(NSString *imageName, UIImage *image) {
            // 当有新图片下载完成时，刷新collectionView
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadData];
            });
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化视图
    [self setupViews];
    [self setupConstraints];
    
    // 加载表情数据
    [self loadEmotions];
}

- (void)setupViews {
    // 创建容器视图
    [ self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"EmojiCell"];
    self.collectionView.backgroundColor = [UIColor colorWithRed:43/255.0 green:49/255.0 blue:64/255.0 alpha:1.0];
    self.collectionView.showsVerticalScrollIndicator = NO;//隐藏垂直滚动条
    self.collectionView.showsHorizontalScrollIndicator = NO;//隐藏水平滚动条
    self.collectionView.bounces = YES;//允许滚动回弹效果
    self.collectionView.alwaysBounceVertical = YES;//即使内容不足也允许垂直方向的回弹
}

- (void)setupConstraints {
    // 布局约束
}

- (void)loadEmotions {
    // 检查ViewModel中是否已有数据
    if (self.emojiViewModel.emojiDataLoaded) {
        [self loadEmojisFromViewModel];
    } else {
        // 使用默认表情数据
        NSLog(@"使用默认表情数据");
    }
}

- (void)loadEmojisFromViewModel {
    // 从ViewModel中获取表情数据
    NSArray *groups = [self.emojiViewModel allEmojiGroups];
    if (groups.count > 0) {
        // 获取第一组表情
        NSDictionary *firstGroup = groups.firstObject;
        NSArray *emojis = firstGroup[@"emojis"];
        
        if (emojis.count > 0) {
            self.emojiData = emojis;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
            NSLog(@"从ViewModel加载了 %lu 个表情", (unsigned long)emojis.count);
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout


#pragma mark - UICollectionViewDataSource
// 返回分区数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//返回表情总数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.emojiData.count;
}

// 配置表情单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 获取可重用的单元格
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmojiCell"
                                                                          forIndexPath:indexPath];
    
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    id emojiItem = self.emojiData[indexPath.item];
    
    if ([emojiItem isKindOfClass:[NSString class]]) {
        // 显示字符串表情
        UILabel *emojiLabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
        emojiLabel.textAlignment = NSTextAlignmentCenter;
        emojiLabel.font = [UIFont systemFontOfSize:20]; // 设置表情大小
        emojiLabel.text = (NSString *)emojiItem;
        [cell.contentView addSubview:emojiLabel];
    } else if ([emojiItem isKindOfClass:[NSDictionary class]]) {
        // 显示从ViewModel获取的表情
        NSDictionary *emoji = (NSDictionary *)emojiItem;
        
        // 创建ImageView显示表情图片
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        // 获取表情图片名
        NSString *imageName = emoji[@"img"];
        
        // 从EmojiViewModel获取已下载的图片
        UIImage *emojiImage = [self.emojiViewModel imageForEmojiWithName:imageName];
        
        if (emojiImage) {
            // 如果图片已下载，直接显示
            imageView.image = emojiImage;
        } else {
            // 图片未下载，显示占位图
            imageView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.3];
            
//            // 可选：在这里添加加载指示器
//            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
//            activityIndicator.center = CGPointMake(imageView.bounds.size.width / 2, imageView.bounds.size.height / 2);
//            [activityIndicator startAnimating];
//            [imageView addSubview:activityIndicator];
        }
        
        [cell.contentView addSubview:imageView];
    }

    cell.backgroundColor = [UIColor clearColor];
    cell.layer.masksToBounds = YES;
    cell.userInteractionEnabled = YES;
    return cell;
}

#pragma mark - UICollectionViewDelegate

// 表情选中事件
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id selectedEmoji = self.emojiData[indexPath.item];
    
    if ([selectedEmoji isKindOfClass:[NSString class]]) {
        NSString *emojiStr = (NSString *)selectedEmoji;
        NSLog(@"选中表情: %@", emojiStr);
        // 文本表情不做处理
    } else if ([selectedEmoji isKindOfClass:[NSDictionary class]]) {
        NSDictionary *emoji = (NSDictionary *)selectedEmoji;
        NSLog(@"选中表情: ID=%@, 图片=%@", emoji[@"id"], emoji[@"img"]);
        UIImage *emojiImage = [self.emojiViewModel imageForEmojiWithName:emoji[@"img"]];
        // 调用代理方法，将图片表情信息传递给控制器
        if ([self.delegate respondsToSelector:@selector(didSelectEmojiWithInfo:)]) {
            [self.delegate didSelectEmojiWithInfo:emojiImage];
        }
    }
    
    // 选中动画效果
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1 animations:^{
        cell.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            cell.transform = CGAffineTransformIdentity;
        }];
    }];
}

#pragma mark - 公共方法
- (CGFloat)emotionViewHeight {
    CGFloat totalHeight = (_itemSize + 2 * _itemSpacing) * _visibleRows;
    return totalHeight;
}

@end

