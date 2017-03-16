//
//  UIScrollView+XYRefreshView.h
//  XYRefreshTool
//
//  Created by lixinyu on 16/10/21.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPushRefreshView.h"
#import "XYPullRefreshView.h"

@interface UIScrollView (XYRefreshView)
//pull
- (void)showPullRefreshViewWithDelegate:(id<XYPullRefreshViewDelegate>)delegate;
- (void)startPullRefreshing;
- (void)endPullRefreshed;
- (void)hiddenPullView;

//push
- (void)showPushRefreshViewWithDelegate:(id<XYPullRefreshViewDelegate>)delegate;
- (void)startPushRefreshing;
- (void)endPushRefreshed;
- (void)hiddenPushView;

- (BOOL)isRefreshing;
@end
