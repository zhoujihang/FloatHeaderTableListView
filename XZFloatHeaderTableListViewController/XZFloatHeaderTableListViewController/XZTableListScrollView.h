//
//  XZTableListScrollView.h
//  XZFloatHeaderTableListViewController
//
//  Created by 周际航 on 2019/4/22.
//  Copyright © 2019年 zjh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZTableListScrollViewModel : NSObject

/// tableView 总个数
@property (nonatomic, assign) NSInteger tableCount;
/// header 视图总高度
@property (nonatomic, assign) CGFloat headerViewHeight;
/// header 视图悬浮高度
@property (nonatomic, assign) CGFloat headerFloatHeight;
/// header 设置后将被添加为 XZTableListScrollView 的子视图
@property (nonatomic, strong, nullable) UIView *headerView;

@end

@class XZTableListScrollView;
/// 虽然继承了 UITableViewDelegate UITableViewDataSource 但只支持其中常用的那几个代理
@protocol XZTableListScrollViewDelegate <UITableViewDelegate, UITableViewDataSource>

- (void)xzTableListScrollView:(XZTableListScrollView *)view didScrollToIndex:(NSInteger)index;

@end

@interface XZTableListScrollView : UIView

@property (nonatomic, weak, nullable) id<XZTableListScrollViewDelegate> delegate;
@property (nonatomic, strong, nullable) XZTableListScrollViewModel *viewModel;

@property (nonatomic, strong, nullable, readonly) NSMutableArray<UITableView *> *tableList;
@property (nonatomic, strong, nullable, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) NSInteger currentIndex;
@property (nonatomic, strong, nullable, readonly) UITableView *currentTableView;

/// 使用此方法刷新，能使 headerView 收缩到最小状态 （通过修改contentInset.bottom扩大contentSize的高度）
- (void)reloadTableViewAtIndex:(NSInteger)index;
/// 滚动到指定的tableView
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
/// 当前显示的tableView滚动到顶部，使得 headerView 恰好收缩到最小
- (void)currentTableViewScrollToTopAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
