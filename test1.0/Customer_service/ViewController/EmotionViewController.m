//
//  EmotionViewController.m
//  test1.0
//
//  Created by heiqi on 2025/4/1.
//

#import "EmotionViewController.h"
#import "ScreenScaling.h"



@interface EmotionViewController () < UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic, assign) NSInteger visibleRows;
@property (nonatomic, assign) NSInteger totalRows;
@property (nonatomic, assign) NSInteger emotionsPerRow;
@property (nonatomic, assign) CGFloat itemSize;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, strong) NSArray *emojiData; // 表情数据源

@end

@implementation EmotionViewController
- (instancetype)init {
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:layout];
    if(self){
        _visibleRows = 4;
        _emotionsPerRow = 9;
        _itemSize = (JSSafeWidth - 2 * _itemSpacing - 8 * _itemSpacing) / 9;
        _itemSpacing = JSWidth(5);
        
        layout.itemSize = CGSizeMake(_itemSize, _itemSize);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = _itemSpacing;
        layout.minimumLineSpacing = _itemSpacing;
        layout.sectionInset = UIEdgeInsetsMake(_itemSpacing, _itemSpacing, _itemSpacing, _itemSpacing);
        _emojiData = @[@"😀", @"😂", @"😇", @"😎", @"😍", @"😘", @"😜", @"🤓", @"🙄", @"😏", @"😘", @"😜", @"🤓", @"🙄", @"😏",@"😣", @"😢", @"😭", @"😤", @"😱",@"😘", @"😜", @"🤓", @"🙄", @"😏",@"😣", @"😢", @"😭", @"😤", @"😱",@"😳", @"😨", @"😈", @"👻",@"😏",@"😣", @"😢", @"😭", @"😤", @"😱",@"😳", @"😨", @"😈", @"👻",@"😏",@"😣", @"😢", @"😭", @"😤", @"😱",@"😳", @"😨", @"😈", @"👻",@"😣", @"😢", @"😭", @"😤", @"😱",@"😘", @"😜", @"🤓", @"🙄", @"😏",@"😣", @"😢", @"😭", @"😤", @"😱",@"😳",]; // 示例表情数据
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化视图
    [self setupViews];
    [self setupConstraints];
    // 设置初始状态
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

}

- (void)loadEmotions {

}

#pragma mark - UICollectionViewDelegateFlowLayout


#pragma mark - IOCollectionViewDataSource
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
    // 7. 获取可重用的单元格
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmojiCell"
                                                                          forIndexPath:indexPath];
    
    for (UIView *subview in cell.contentView.subviews)  {
        [subview removeFromSuperview];
    }
    

    UILabel *emojiLabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    emojiLabel.textAlignment  = NSTextAlignmentCenter;
    emojiLabel.font  = [UIFont systemFontOfSize:25]; // 设置表情大小
    emojiLabel.text  = self.emojiData[indexPath.item];
    [cell.contentView addSubview:emojiLabel];
    

    cell.backgroundColor  = [UIColor clearColor];
    cell.layer.masksToBounds  = YES;
    
    return cell;
}
#pragma mark - UICollectionViewDelegate

// 表情选中事件
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedEmoji = self.emojiData[indexPath.item];
    NSLog(@"选中表情: %@", selectedEmoji);
    
    // 11. 选中动画效果
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1 animations:^{
        cell.transform  = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            cell.transform  = CGAffineTransformIdentity;
        }];
    }];
}

#pragma mark - 公共方法
- (CGFloat)emotionViewHeight {
    CGFloat  totalHeight = (_itemSize + 2 * _itemSpacing) * _visibleRows;
    
    return totalHeight;

}
@end

