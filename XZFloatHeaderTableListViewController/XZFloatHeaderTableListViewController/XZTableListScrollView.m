//
//  XZTableListScrollView.m
//  XZFloatHeaderTableListViewController
//
//  Created by 周际航 on 2019/4/22.
//  Copyright © 2019年 zjh. All rights reserved.
//

#import "XZTableListScrollView.h"

@implementation XZTableListScrollViewModel

@end

@interface XZTableListScrollView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, nullable, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, nullable, readwrite) NSMutableArray<UITableView *> *tableList;
/// 当前显示的tableview索引
@property (nonatomic, assign, readwrite) NSInteger currentIndex;
@property (nonatomic, strong, nullable, readwrite) UITableView *currentTableView;
/// headerView.frame.origin.y 的最小值
@property (nonatomic, assign) CGFloat headerMinY;
/// pan 手势上一个手势点
@property (nonatomic, assign) CGPoint oldPoint;

@end

@implementation XZTableListScrollView

- (void)dealloc {
    self.scrollView.delegate = nil;
    for (UITableView *tableView in self.tableList) {
        tableView.delegate = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.scrollView];
}

- (void)updateFrame {
    CGFloat width = self.bounds.size.width;
    CGFloat height =self.bounds.size.height;
    for (NSInteger i=0; i<self.tableList.count; i++) {
        UIView *view = self.tableList[i];
        view.frame = CGRectMake(i*width, 0, width, height);
    }
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.tableList.count*width, height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

- (void)setViewModel:(XZTableListScrollViewModel *)viewModel {
    _viewModel = viewModel;
    [self createTableViewList];
    
    if (self.viewModel.headerView) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewDidPan:)];
        [self.viewModel.headerView addGestureRecognizer:pan];
        [self addSubview:self.viewModel.headerView];
        self.headerMinY = -ABS(self.viewModel.headerViewHeight - self.viewModel.headerFloatHeight);
    }
}

- (void)createTableViewList {
    for (UIView *view in self.tableList) {
        [view removeFromSuperview];
    }
    self.tableList = [@[] mutableCopy];
    for (NSInteger i=0; i<self.viewModel.tableCount; i++) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor colorWithRed:0.2+arc4random_uniform(80)/100.0 green:0.2+arc4random_uniform(80)/100.0 blue:0.2+arc4random_uniform(80)/100.0 alpha:1];
        tableView.alwaysBounceVertical = YES;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        UIView *header = [[UIView alloc] init];
        header.backgroundColor = [UIColor clearColor];
        header.bounds = CGRectMake(0, 0, 0, self.viewModel.headerViewHeight);
        tableView.tableHeaderView = header;
        [self.scrollView addSubview:tableView];
        [self.tableList addObject:tableView];
    }
}

- (UITableView *)currentTableView {
    if (self.currentIndex >= self.tableList.count) {return nil;}
    return self.tableList[self.currentIndex];
}

#pragma mark - 视图大小
- (CGSize)sizeThatFits:(CGSize)size {
    return [self intrinsicContentSize];
}
- (CGSize)intrinsicContentSize {
    return [UIScreen mainScreen].bounds.size;
}

#pragma mark - UITableView 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        return [self.delegate numberOfSectionsInTableView:tableView];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        return [self.delegate tableView:tableView numberOfRowsInSection:section];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        return [[UITableViewCell alloc] init];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    } else {
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.delegate tableView:tableView viewForHeaderInSection:section];
    } else {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.delegate tableView:tableView heightForHeaderInSection:section];
    } else {
        return 0.01;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [self.delegate tableView:tableView viewForFooterInSection:section];
    } else {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.delegate tableView:tableView heightForFooterInSection:section];
    } else {
        return 0.01;
    }
}

#pragma mark - UIScrollView 代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
    CGFloat viewWidth = self.scrollView.frame.size.width;
    if (scrollView == self.scrollView) {
        self.currentIndex = self.scrollView.contentOffset.x / viewWidth;
        NSLog(@"zjh currentIndex:%ld", self.currentIndex);
        return;
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat headerY = MAX(self.headerMinY, MIN(0, -offsetY));
    self.viewModel.headerView.frame = CGRectMake(0, headerY, self.bounds.size.width, self.viewModel.headerViewHeight);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
    if (scrollView != self.scrollView) {return;}
    [self fixupTableViewContentOffset];
}

#pragma mark - 处理 tableview 的偏移
- (void)fixupTableViewContentOffset {
    if (self.currentIndex >= self.tableList.count) {return;}
    UITableView *tableView = self.tableList[self.currentIndex];
    if (self.viewModel.headerView.frame.origin.y > self.headerMinY) {
        /// headerView 处于未完全收缩状态
        [self allTableViewScrollToOffsetY:tableView.contentOffset.y];
    } else {
        /// headerView 处于完全收缩状态
        [self allTableViewCheckOriginY];
    }
}
- (void)allTableViewScrollToOffsetY:(CGFloat)offsetY {
    for (UITableView *tableView in self.tableList) {
        CGPoint point = tableView.contentOffset;
        point.y = offsetY;
        tableView.contentOffset = point;
    }
}
- (void)allTableViewCheckOriginY {
    for (UITableView *tableView in self.tableList) {
        CGPoint point = tableView.contentOffset;
        point.y = MAX(ABS(self.headerMinY), point.y);
        tableView.contentOffset = point;
    }
}

#pragma mark - header手势
- (void)headerViewDidPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self];
    if (pan.state == UIGestureRecognizerStateChanged) {
        UITableView *tableView = self.currentTableView;
        CGPoint offset = tableView.contentOffset;
        offset.y -= point.y - self.oldPoint.y;
        offset.y = MAX(0, offset.y);
        tableView.contentOffset = offset;
    }
    self.oldPoint = point;
}

@end
