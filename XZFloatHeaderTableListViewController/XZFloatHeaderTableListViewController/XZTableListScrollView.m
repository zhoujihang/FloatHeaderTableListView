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

@property (nonatomic, assign) BOOL isScrollAnimating;

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
    self.scrollView.showsHorizontalScrollIndicator = NO;
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
#pragma mark - headerView
- (void)addHeaderViewToSelf {
    UIView *headerView = self.viewModel.headerView;
    if (!headerView) {return;}
    if (headerView.superview != self) {
        [headerView removeFromSuperview];
        [self addSubview:headerView];
    }
    [self updateHeaderViewFrameWhenScrollHorizontal];
}
- (void)addHeaderViewToCurrentTableView {
    UIView *headerView = self.viewModel.headerView;
    if (!headerView) {return;}
    if (headerView.superview != self.currentTableView) {
        [headerView removeFromSuperview];
        [self.currentTableView addSubview:headerView];
    }
    [self updateHeaderViewFrameWhenScrollVertical];
}
/// 水平滚动时，headerView 在self身上
- (void)updateHeaderViewFrameWhenScrollHorizontal {
    CGFloat offsetY = self.currentTableView.contentOffset.y;
    CGFloat headerY = MAX(-ABS(self.viewModel.headerViewHeight - self.viewModel.headerFloatHeight), MIN(0, -offsetY));
    self.viewModel.headerView.frame = CGRectMake(0, headerY, self.bounds.size.width, self.viewModel.headerViewHeight);
}
/// 垂直滚动时，headerView 在self.currentTableView身上
- (void)updateHeaderViewFrameWhenScrollVertical {
    CGFloat offsetY = self.currentTableView.contentOffset.y;
    CGFloat hiddenHeight = self.viewModel.headerViewHeight - self.viewModel.headerFloatHeight;
    CGFloat headerY = 0;
    if (offsetY >= hiddenHeight) {
        headerY = offsetY - hiddenHeight;
    }
    self.viewModel.headerView.frame = CGRectMake(0, headerY, self.bounds.size.width, self.viewModel.headerViewHeight);
}

#pragma mark - 公开方法
- (void)setViewModel:(XZTableListScrollViewModel *)viewModel {
    if (_viewModel.headerView) {
        [_viewModel.headerView removeFromSuperview];
    }
    _viewModel = viewModel;
    [self createTableViewList];
    [self updateFrame];
    if (self.viewModel.headerView) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
        [self.viewModel.headerView addGestureRecognizer:pan];
        [self.currentTableView addSubview:self.viewModel.headerView];
        /// 设置手势优先级 tableView > headerView > scrollView
        [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:pan];
        for (UITableView *tableView in self.tableList) {
            [pan requireGestureRecognizerToFail:tableView.panGestureRecognizer];
        }
    }
    for (NSInteger i=0; i<self.tableList.count; i++) {
        [self reloadTableViewAtIndex:i];
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

- (void)setCurrentIndex:(NSInteger)currentIndex {
    BOOL isChanged = _currentIndex != currentIndex;
    _currentIndex = currentIndex;
    if (isChanged && [self.delegate respondsToSelector:@selector(xzTableListScrollView:didScrollToIndex:)]) {
        [self.delegate xzTableListScrollView:self didScrollToIndex:currentIndex];
    }
}

- (UITableView *)currentTableView {
    if (self.currentIndex >= self.tableList.count) {return nil;}
    return self.tableList[self.currentIndex];
}

- (void)reloadTableViewAtIndex:(NSInteger)index {
    if (index >= self.tableList.count) {return;}
    self.isScrollAnimating = YES;
    UITableView *tableView = self.tableList[index];
    CGPoint offset = tableView.contentOffset;
    [tableView reloadData];
    CGFloat minHeight = (self.viewModel.headerViewHeight - self.viewModel.headerFloatHeight) + self.bounds.size.height;
    CGFloat contentHeight = tableView.contentInset.top + tableView.contentSize.height;
    CGFloat footerExtraHeight = MAX(0, minHeight - contentHeight);
    UIEdgeInsets insets = tableView.contentInset;
    insets.bottom = footerExtraHeight;
    tableView.contentInset = insets;
    offset.y = MAX(0, MIN(offset.y, tableView.contentSize.height + tableView.contentInset.top + tableView.contentInset.bottom - tableView.frame.size.height));
    tableView.contentOffset = offset;
    self.isScrollAnimating = NO;
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    if (self.isScrollAnimating) {return;}
    index = MAX(0, MIN(self.tableList.count-1, index));
    CGPoint point = CGPointMake(index * self.scrollView.frame.size.width, 0);
    
    self.isScrollAnimating = YES;
    [self fixupTableViewContentOffset];
    [self addHeaderViewToSelf];
    
    __weak typeof(self) weakSelf = self;
    CGFloat time = animated ? 5.25 : 0;
    [UIView animateWithDuration:time animations:^{
        [weakSelf.scrollView setContentOffset:point];
    } completion:^(BOOL finished) {
        weakSelf.currentIndex = (weakSelf.scrollView.contentOffset.x + weakSelf.scrollView.frame.size.width * 0.5) / weakSelf.scrollView.frame.size.width;
        [weakSelf addHeaderViewToCurrentTableView];
        weakSelf.isScrollAnimating = NO;
    }];
}

- (void)currentTableViewScrollToTopAnimated:(BOOL)animated {
    if (self.isScrollAnimating) {return;}
    self.isScrollAnimating = YES;
    [self reloadTableViewAtIndex:self.currentIndex];
    __weak typeof(self) weakSelf = self;
    CGFloat time = animated ? 0.25 : 0;
    [UIView animateWithDuration:time animations:^{
        [weakSelf.currentTableView setContentOffset:CGPointMake(0, weakSelf.viewModel.headerViewHeight - weakSelf.viewModel.headerFloatHeight) animated:animated];
    } completion:^(BOOL finished) {
        weakSelf.isScrollAnimating = NO;
    }];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}
#pragma mark - UIScrollView 代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isScrollAnimating) {return;}
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
    if (scrollView == self.scrollView) {
        self.currentIndex = (self.scrollView.contentOffset.x + self.scrollView.frame.size.width * 0.5) / self.scrollView.frame.size.width;
        return;
    }
    [self updateHeaderViewFrameWhenScrollVertical];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isScrollAnimating) {return;}
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
    if (scrollView != self.scrollView) {return;}
    [self fixupTableViewContentOffset];
    [self addHeaderViewToSelf];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isScrollAnimating) {return;}
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if (scrollView != self.scrollView) {return;}
    if (!decelerate) {
        [self scrollViewDidScrollStop:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.isScrollAnimating) {return;}
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
    if (scrollView != self.scrollView) {return;}
    [self scrollViewDidScrollStop:scrollView];
}
/// self.scrollView 左右滑动停止
- (void)scrollViewDidScrollStop:(UIScrollView *)scrollView {
    [self addHeaderViewToCurrentTableView];
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.isScrollAnimating) {return;}
    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
#pragma mark - 处理 tableview 的偏移
- (void)fixupTableViewContentOffset {
    if (self.currentIndex >= self.tableList.count) {return;}
    CGFloat offsetY = self.currentTableView.contentOffset.y;
    if (offsetY < self.viewModel.headerViewHeight - self.viewModel.headerFloatHeight) {
        /// headerView 处于未完全收缩状态
        [self allTableViewScrollToOffsetY:offsetY];
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
        point.y = MAX(ABS(self.viewModel.headerViewHeight - self.viewModel.headerFloatHeight), point.y);
        tableView.contentOffset = point;
    }
}

@end
