//
//  XYPushRefreshView.h
//  XYRefreshTool
//
//  Created by lixinyu on 16/5/21.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define XYPushDownRefreshControlHeight   60

@class XYPushRefreshView;

@protocol XYPushRefreshViewDelegate <NSObject>
- (void)pushRefreshViewStartLoad:(XYPushRefreshView*)pushView;
@end

@interface XYPushRefreshView : UIView

@property (nonatomic, weak) id<XYPushRefreshViewDelegate>delegate;
- (void)startRefreshing;

- (void)endRefreshing;

- (void)hiddenPushView;

- (BOOL)isRefreshing;

@end
