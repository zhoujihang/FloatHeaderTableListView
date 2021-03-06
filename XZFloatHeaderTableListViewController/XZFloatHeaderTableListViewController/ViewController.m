//
//  ViewController.m
//  XZFloatHeaderTableListViewController
//
//  Created by 周际航 on 2019/4/22.
//  Copyright © 2019年 zjh. All rights reserved.
//

#import "ViewController.h"
#import "XZTableListScrollView.h"
#import "XZHeaderView.h"
#import <MJRefresh/MJRefresh.h>

@interface ViewController ()  <XZTableListScrollViewDelegate>

@property (nonatomic, strong, nullable) XZTableListScrollView *tableListView;
@property (nonatomic, strong, nullable) XZHeaderView *headerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    [self setupView];
    [self setupFrame];
//    [self refresh];
}

- (void)refresh {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSInteger i=0; i<self.tableListView.tableList.count; i++) {
            [self.tableListView reloadTableViewAtIndex:i];
        }
        [self refresh];
    });
}

- (void)setupView {
    self.navigationItem.title = @"贝壳蛋糕";
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.headerView = [[XZHeaderView alloc] init];
    self.headerView.floatHeight = 44;
    [self.headerView sizeToFit];
    
    XZTableListScrollViewModel *viewModel = [[XZTableListScrollViewModel alloc] init];
    viewModel.tableCount = 10;
    viewModel.headerView = self.headerView;
    viewModel.headerViewHeight = self.headerView.intrinsicContentSize.height;
    viewModel.headerFloatHeight = self.headerView.floatHeight;
    self.tableListView = [[XZTableListScrollView alloc] init];
    self.tableListView.viewModel = viewModel;
    self.tableListView.delegate = self;
    for (UITableView *tableView in self.tableListView.tableList) {
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        MJRefreshHeader *refresh = [MJRefreshHeader headerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [tableView.mj_header endRefreshing];
            });
        }];
        tableView.mj_header = refresh;
    }
    [self.view addSubview:self.tableListView];
}

- (void)setupFrame {
    self.tableListView.frame = self.view.bounds;
}

#pragma mark - UITableView 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger tableIndex = [self.tableListView.tableList indexOfObject:tableView];
    return tableIndex==0 ? 3 : arc4random_uniform(50);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *text = [[NSString alloc] initWithFormat:@"%ld - %ld", (long)indexPath.section, (long)indexPath.row];
    if (indexPath.row == 0) {
        text = @"0 - 0";
    } else if (indexPath.row == 1) {
        text = @"0 - 1";
    }
    cell.textLabel.text = text;
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView.mj_header beginRefreshing];
    NSInteger index = [self.tableListView.tableList indexOfObject:tableView];
    if (index == 0) {
        [self.tableListView reloadTableViewAtIndex:0];
    } else if (index == 1) {
        [self.tableListView scrollToIndex:8 animated:YES];
    } else if (index == 2) {
        [self.tableListView currentTableViewScrollToTopAnimated:YES];
    } else if (index == 3) {
        [self.tableListView currentTableViewScrollToTopAnimated:NO];
    } else if (index == 8) {
        [self.tableListView scrollToIndex:0 animated:NO];
    }
}

- (void)xzTableListScrollView:(XZTableListScrollView *)view didScrollToIndex:(NSInteger)index {
    NSLog(@"zjh index:%ld", (long)index);
}

@end
