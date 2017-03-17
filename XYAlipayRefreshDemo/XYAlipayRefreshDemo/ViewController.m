//
//  ViewController.m
//  XYAlipayRefreshDemo
//
//  Created by smok on 17/3/16.
//  Copyright © 2017年 xinyuly. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+XYRefreshView.h"

#define KScreenWidth  [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
#define KTopViewHeight  300
#define KTopHeaderViewHeight  80

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,XYPullRefreshViewDelegate,XYPushRefreshViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIView *navBGView;

@property (nonatomic, strong) UIView *navView;

@property (nonatomic, strong) UIView *navNewView;

@property (nonatomic, strong) UIView *topHeaderView;

@property (nonatomic, assign) NSInteger dataCount;

@end

@implementation ViewController
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentSize"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.navBGView];
    [self.view addSubview:self.navView];
    [self.view addSubview:self.navNewView];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topView];
    [self.scrollView addSubview:self.tableView];
    //添加刷新控件
    [self.tableView showPullRefreshViewWithDelegate:self];
    [self.scrollView showPushRefreshViewWithDelegate:self];
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    self.dataCount = 20;
}
//根据tableView的contentSize改变scrollView的contentSize大小
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGRect tFrame = self.tableView.frame;
        tFrame.size.height = self.tableView.contentSize.height;
        self.tableView.frame = tFrame;
        self.scrollView.contentSize = CGSizeMake(0, self.tableView.contentSize.height+KTopViewHeight);
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
        tFrame.origin.y = offsetY + KTopViewHeight;
        self.tableView.frame = tFrame;
        
        if (![self.tableView isRefreshing]) {
            self.tableView.contentOffset = CGPointMake(0, offsetY);
        }
    } else if (offsetY < KTopHeaderViewHeight && offsetY >0) {
        CGFloat alpha =  (offsetY*2/KTopHeaderViewHeight>0) ? offsetY*2/KTopHeaderViewHeight:0;
        if (alpha > 0.5) {
            self.navNewView.alpha = alpha*2-1;
            self.navView.alpha = 0;
        } else {
            self.navNewView.alpha = 0;
            self.navView.alpha = 1-alpha*2;
        }
        self.topHeaderView.alpha = 1-alpha;
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
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight-64)];
        _scrollView.delegate = self;
        //Indicator的显示位置
        _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(KTopViewHeight, 0, 0, 0);
        _scrollView.contentSize = CGSizeMake(0, KScreenHeight*2);
    }
    return _scrollView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopViewHeight, KScreenWidth, KScreenHeight*2-KTopViewHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (UIView *)topView {
    if (_topView == nil) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KTopViewHeight)];
        _topView.backgroundColor = [UIColor colorWithRed:66/255.0 green:128/255.0 blue:240/255.0 alpha:1];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KTopHeaderViewHeight)];
        headerView.backgroundColor = [UIColor colorWithRed:66/255.0 green:128/255.0 blue:240/255.0 alpha:1];
        for (int i = 0; i<4; i++) {
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",i+1]] forState:UIControlStateNormal];
            [headerView addSubview:button];
            button.frame = CGRectMake((KScreenWidth/4)*i, 0, KScreenWidth/4, KTopHeaderViewHeight);
        }
        self.topHeaderView = headerView;
        [_topView addSubview:headerView];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, KTopHeaderViewHeight, KScreenWidth, KTopViewHeight-KTopHeaderViewHeight)];
        view.backgroundColor = [UIColor brownColor];
        [_topView addSubview:view];
    }
    return _topView;
}

- (UIView *)navBGView {
    if (_navBGView == nil) {
        _navBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 64)];
        _navBGView.backgroundColor = [UIColor colorWithRed:66/255.0 green:128/255.0 blue:240/255.0 alpha:1];
    }
    return _navBGView;
}

- (UIView *)navView {
    if (_navView == nil) {
        _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 64)];
        _navView.backgroundColor = [UIColor clearColor];
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 20, 200, 44)];
        searchBar.backgroundImage = [[UIImage alloc] init];

        UITextField *searchField = [searchBar valueForKey:@"searchField"];
        if (searchField) {
            [searchField setBackgroundColor:[UIColor colorWithRed:230/255 green:230/250 blue:230/250 alpha:0.1]];
        }
        [_navView addSubview:searchBar];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(220, 20, 44, 44)];
        [button setImage:[UIImage imageNamed:@"contacts"] forState:UIControlStateNormal];
        [_navView addSubview:button];
    }
    return _navView;
}

- (UIView *)navNewView {
    if (_navNewView == nil) {
        _navNewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 64)];
        _navNewView.backgroundColor = [UIColor clearColor];
        UIButton *cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 44, 44)];
        [cameraBtn setImage:[UIImage imageNamed:@"nav_camera"] forState:UIControlStateNormal];
        [_navNewView addSubview:cameraBtn];
        
        UIButton *payBtn = [[UIButton alloc] initWithFrame:CGRectMake(64, 20, 44, 44)];
        [payBtn setImage:[UIImage imageNamed:@"nav_pay"] forState:UIControlStateNormal];
        [_navNewView addSubview:payBtn];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(118, 20, 44, 44)];
        [button setImage:[UIImage imageNamed:@"nav_scan"] forState:UIControlStateNormal];
        [_navNewView addSubview:button];
        _navNewView.alpha = 0;
    }
    return _navNewView;
}

@end

