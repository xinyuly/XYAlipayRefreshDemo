//
//  ViewController.m
//  XYAlipayRefreshDemo
//
//  Created by smok on 17/3/16.
//  Copyright © 2017年 xinyuly. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+XYRefreshView.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,XYPullRefreshViewDelegate,XYPushRefreshViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) CGFloat topViewHeight;

@property (nonatomic, assign) NSInteger dataCount;
@end

@implementation ViewController
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentSize"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topViewHeight = 300;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topView];
    [self.scrollView addSubview:self.tableView];
    [self.tableView showPullRefreshViewWithDelegate:self];
    [self.tableView showPushRefreshViewWithDelegate:self];
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    self.dataCount = 10;
}
//根据tableView的contentSize决定scrollView的contentSize大小
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGRect tFrame = self.tableView.frame;
        tFrame.size.height = self.tableView.contentSize.height;
        self.tableView.frame = tFrame;
        self.scrollView.contentSize = CGSizeMake(0, self.tableView.contentSize.height+self.topViewHeight);
    }
}
#pragma mark - XYPullRefreshViewDelegate
- (void)pullRefreshViewStartLoad:(XYPullRefreshView *)pullView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pullView endRefreshing];
        self.dataCount += 5;
        [self.tableView reloadData];
    });
}

- (void)pushRefreshViewStartLoad:(XYPushRefreshView *)pushView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pushView endRefreshing];
        self.dataCount += 5;
        [self.tableView reloadData];
    });
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = self.scrollView.contentOffset.y;
    if (offsetY <= 0.0) {
        CGRect frame = self.topView.frame;
        frame.origin.y = offsetY;
        self.topView.frame = frame;
        
        CGRect tFrame = self.tableView.frame;
        tFrame.origin.y = offsetY + self.topViewHeight;
        self.tableView.frame = tFrame;
        
        if (![self.tableView isRefreshing]) {
            self.tableView.contentOffset = CGPointMake(0, offsetY);
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat offsetY = self.scrollView.contentOffset.y;
    if (offsetY < - 60) {
        [self.tableView startPullRefreshing];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    return cell;
}

#pragma mark - getter && setter
- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.delegate = self;
        //Indicator的显示位置
        _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.topViewHeight, 0, 0, 0);
        _scrollView.contentSize = CGSizeMake(0, self.view.bounds.size.height*2);
    }
    return _scrollView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topViewHeight, self.view.bounds.size.width, self.view.bounds.size.height*2-self.topViewHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (UIView *)topView {
    if (_topView == nil) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.topViewHeight)];
        _topView.backgroundColor = [UIColor brownColor];
    }
    return _topView;
}
@end

