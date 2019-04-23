//
//  XZHeaderView.m
//  XZFloatHeaderTableListViewController
//
//  Created by 周际航 on 2019/4/22.
//  Copyright © 2019年 zjh. All rights reserved.
//

#import "XZHeaderView.h"

@interface XZHeaderView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong, nullable) UILabel *titleLabel;
@property (nonatomic, strong, nullable) UIView *bottomView;
@property (nonatomic, strong, nullable) UICollectionView *collectionView1;
@property (nonatomic, strong, nullable) UICollectionViewFlowLayout *layout1;
@property (nonatomic, strong, nullable) UICollectionView *collectionView2;
@property (nonatomic, strong, nullable) UICollectionViewFlowLayout *layout2;

@end

@implementation XZHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setupView];
}

- (void)setupView {
    self.backgroundColor = [UIColor yellowColor];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:120];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor orangeColor];
    
    self.layout1 = [[UICollectionViewFlowLayout alloc] init];
    self.layout1.itemSize = CGSizeMake(100, 100);
    self.layout1.minimumInteritemSpacing = 10;
    self.layout1.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView1 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout1];
    self.collectionView1.delegate = self;
    self.collectionView1.dataSource = self;
    self.collectionView1.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [self.collectionView1 registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.layout2 = [[UICollectionViewFlowLayout alloc] init];
    self.layout2.itemSize = CGSizeMake(100, 100);
    self.layout2.minimumInteritemSpacing = 10;
    self.layout2.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.layout2.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView2 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout2];
    self.collectionView2.delegate = self;
    self.collectionView2.dataSource = self;
    self.collectionView2.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [self.collectionView2 registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.bottomView];
    [self addSubview:self.collectionView1];
    [self addSubview:self.collectionView2];
}

- (void)updateFrame {
    CGSize size = self.intrinsicContentSize;
    self.collectionView1.frame = CGRectMake(0, 100, size.width, self.layout1.itemSize.height + 50);
    self.collectionView2.frame = CGRectMake(0, 350, size.width, self.layout2.itemSize.height + 50);
    self.titleLabel.frame = CGRectMake(0, 0, size.width, size.height - self.floatHeight);
    self.bottomView.frame = CGRectMake(0, size.height - self.floatHeight, size.width, self.floatHeight);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

- (void)setFloatHeight:(CGFloat)floatHeight {
    _floatHeight = floatHeight;
    [self updateFrame];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

#pragma mark - UICollectionView 代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:0.2+arc4random_uniform(80)/100.0 green:0.2+arc4random_uniform(80)/100.0 blue:0.2+arc4random_uniform(80)/100.0 alpha:1];
    return cell;
}

#pragma mark - 视图大小
- (CGSize)sizeThatFits:(CGSize)size {
    return [self intrinsicContentSize];
}
- (CGSize)intrinsicContentSize {
    CGFloat height = 600;
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, height);
}

@end
