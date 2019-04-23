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

@end

@interface XZTableListScrollView : UIView

@property (nonatomic, weak, nullable) id<XZTableListScrollViewDelegate> delegate;
@property (nonatomic, strong, nullable) XZTableListScrollViewModel *viewModel;

@property (nonatomic, strong, nullable, readonly) NSMutableArray<UITableView *> *tableList;
@property (nonatomic, strong, nullable, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) NSInteger currentIndex;
@property (nonatomic, strong, nullable, readonly) UITableView *currentTableView;

@end

NS_ASSUME_NONNULL_END
