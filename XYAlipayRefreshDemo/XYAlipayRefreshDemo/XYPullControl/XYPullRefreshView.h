//
//  XYPullRefreshView.h
//  XYRefreshTool
//
//  Created by lixinyu on 16/5/21.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYPullRefreshView;

@protocol XYPullRefreshViewDelegate <NSObject>
- (void)pullRefreshViewStartLoad:(XYPullRefreshView*)pullView;
@end

@interface XYPullRefreshView : UIView

@property (nonatomic, weak) id<XYPullRefreshViewDelegate>delegate;

- (void)startRefreshing;

- (void)endRefreshing;

- (void)hiddenPullView;

- (BOOL)isRefreshing;

@end
