//
//  UIScrollView+XYRefreshView.m
//  XYRefreshTool
//
//  Created by lixinyu on 16/10/21.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import "UIScrollView+XYRefreshView.h"

#define XYPullDownRefreshControlHeight   60
static NSInteger XPullRefreshTag = 6834598;
static NSInteger XPushRefreshTag = 8749011;

@implementation UIScrollView (XYRefreshView) 
#pragma mark - XYPullRefreshView
- (void)showPullRefreshViewWithDelegate:(id<XYPullRefreshViewDelegate>)delegate {
    XYPullRefreshView *pullView = (XYPullRefreshView *)[self viewWithTag:XPullRefreshTag];
    if (pullView == nil) {
        pullView = [[XYPullRefreshView alloc] init];
        [self addSubview:pullView];
        pullView.delegate = delegate;
        pullView.tag = XPullRefreshTag;
    }
}

- (void)startPullRefreshing {
    XYPullRefreshView *pullView = (XYPullRefreshView *)[self viewWithTag:XPullRefreshTag];
    [pullView startRefreshing];
}

- (void)endPullRefreshed {
    XYPullRefreshView *pullView = (XYPullRefreshView *)[self viewWithTag:XPullRefreshTag];
    [pullView endRefreshing];
}

- (void)hiddenPullView{
    XYPullRefreshView *pullView = (XYPullRefreshView *)[self viewWithTag:XPullRefreshTag];
    [pullView hiddenPullView];
}
#pragma mark - XYPushRefreshView
- (void)showPushRefreshViewWithDelegate:(id<XYPushRefreshViewDelegate>)delegate {
    XYPushRefreshView *pushView = (XYPushRefreshView *)[self viewWithTag:XPushRefreshTag];
    if (pushView == nil) {
        pushView = [[XYPushRefreshView alloc] init ];
        [self addSubview:pushView];
        pushView.delegate = delegate;
        pushView.tag = XPushRefreshTag;
    }
}

- (void)startPushRefreshing {
    XYPushRefreshView *pushView = (XYPushRefreshView *)[self viewWithTag:XPushRefreshTag];
    [pushView startRefreshing];
}

- (void)endPushRefreshed {
    XYPushRefreshView *pushView = (XYPushRefreshView *)[self viewWithTag:XPushRefreshTag];
    [pushView endRefreshing];
}

- (void)hiddenPushView{
    XYPushRefreshView *pushView = (XYPushRefreshView *)[self viewWithTag:XPushRefreshTag];
    [pushView hiddenPushView];
}

- (BOOL)isRefreshing {
    XYPullRefreshView *pullView = (XYPullRefreshView *)[self viewWithTag:XPullRefreshTag];
    XYPushRefreshView *pushView = (XYPushRefreshView *)[self viewWithTag:XPushRefreshTag];
    return [pullView isRefreshing] || [pushView isRefreshing];
}
@end
