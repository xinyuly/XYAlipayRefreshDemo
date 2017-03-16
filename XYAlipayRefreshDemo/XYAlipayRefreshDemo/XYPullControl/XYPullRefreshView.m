//
//  XYPullRefreshView.m
//  XYRefreshTool
//
//  Created by lixinyu on 16/5/21.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import "XYPullRefreshView.h"

#define XYPullDownRefreshControlHeight   60
#define XYDefautlAnimDuration 0.25

typedef NS_ENUM(NSInteger,XYPullRefreshStatus) {
    Normal        = 0, // 箭头朝下, 下拉刷新
    PullToRefresh = 1, // 箭头朝上, 释放刷新
    Refreshing    = 2, // 正在刷新
};

@interface XYPullRefreshView ()
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIImageView *loadView;
@property (nonatomic, strong) UILabel     *messageLabel;
@property (nonatomic, strong) UIScrollView *superScrollView;
@property (nonatomic, assign) XYPullRefreshStatus  currentStatus;//状态
@end

@implementation XYPullRefreshView
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentOffset" ];
}

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect newFrame = CGRectMake(0, -XYPullDownRefreshControlHeight, [UIScreen mainScreen].bounds.size.width, XYPullDownRefreshControlHeight);
    if ([super initWithFrame:newFrame]) {
        [self prepareUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ([super initWithCoder:aDecoder]) {
        [self prepareUI];
    }
    return self;
}

- (void)prepareUI {
    self.currentStatus = Normal;
    [self addSubview:self.loadView];
    [self addSubview:self.arrowView];
    [self addSubview:self.messageLabel];
    self.loadView.hidden = YES;
    CGFloat centerX = self.bounds.size.width*0.5;
    CGFloat centerY = self.bounds.size.height*0.5;
    self.loadView.frame = CGRectMake(centerX-30, centerY-16, 32, 32);
    self.arrowView.frame = self.loadView.frame;
    self.messageLabel.frame = CGRectMake(centerX+10, centerY-20, 100, 40);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView*)newSuperview;
        [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    // 拖拽才需要判断 Normal <==> PullToRefresh
    // dragging = 表示手在拖拽, false 松手了
    if (self.superScrollView.isDragging) {
        if (self.currentStatus == PullToRefresh && self.superScrollView.contentOffset.y > -(self.superScrollView.contentInset.top+XYPullDownRefreshControlHeight)) {
            self.currentStatus = Normal;
        } else if (self.currentStatus == Normal && self.superScrollView.contentOffset.y < - (self.superScrollView.contentInset.top+XYPullDownRefreshControlHeight)){
            self.currentStatus = PullToRefresh;
        }
    } else if (self.currentStatus == PullToRefresh) {
        self.currentStatus = Refreshing;
    }
}
#pragma mark - action
- (void)startRefreshing  {
    //切换状态
    self.currentStatus = Refreshing;
}

- (void)endRefreshing {
    self.currentStatus = Normal;
    [UIView animateWithDuration:XYDefautlAnimDuration animations:^{
        UIEdgeInsets edgeInset = self.superScrollView.contentInset;
        edgeInset.top -= XYPullDownRefreshControlHeight;
        self.superScrollView.contentInset = edgeInset;
    }];
}


- (void)hiddenPullView {
    self.hidden = YES;
    [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    self.superScrollView = nil;
    UIEdgeInsets edgeInset = self.superScrollView.contentInset;
    edgeInset.top += XYPullDownRefreshControlHeight;
    self.superScrollView.contentInset = edgeInset;
}

- (BOOL)isRefreshing {
    return (self.currentStatus == Refreshing);
}
#pragma mark - Setter & getter
- (void)setCurrentStatus:(XYPullRefreshStatus)currentStatus {
    _currentStatus = currentStatus;
    __weak typeof(self) weakSelf = self;
    if (currentStatus == Normal) {
        self.loadView.hidden = YES;
        self.arrowView.hidden = NO;
        self.messageLabel.text = @"下拉刷新";
        [UIView animateWithDuration:XYDefautlAnimDuration animations:^{
            weakSelf.arrowView.transform = CGAffineTransformIdentity;
        }];
    } else if (currentStatus == PullToRefresh) {
        // 箭头旋转, 文字 释放刷新
        self.messageLabel.text = @"释放刷新";
        [UIView animateWithDuration:XYDefautlAnimDuration animations:^{
            weakSelf.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    } else if (currentStatus == Refreshing) {
        self.messageLabel.text = @"正在刷新...";
        self.loadView.hidden = NO;
        self.arrowView.hidden = YES;
        //添加动画
        CABasicAnimation *rotationanim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotationanim.toValue = @(M_PI*2);
        rotationanim.repeatCount = MAXFLOAT;
        rotationanim.duration = 0.5;
        rotationanim.removedOnCompletion = NO;
        // 给动画加forKey: 防止动画重复添加
        [self.loadView.layer addAnimation:rotationanim forKey:@"rotationAnim"];
        [UIView animateWithDuration:XYDefautlAnimDuration animations:^{
            UIEdgeInsets edgeInset = weakSelf.superScrollView.contentInset;
            edgeInset.top += XYPullDownRefreshControlHeight;
            weakSelf.superScrollView.contentInset = edgeInset;
        }];
        if ([self.delegate respondsToSelector:@selector(pullRefreshViewStartLoad:)]) {
            [self.delegate pullRefreshViewStartLoad:self];
        }
    }
}

- (UIImageView *)arrowView {
    if (_arrowView == nil) {
        _arrowView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pull_refresh"]];
    }
    return _arrowView;
}

- (UIImageView *)loadView {
    if (_loadView == nil) {
        _loadView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading"]];
    }
    return _loadView;
}

- (UILabel *)messageLabel {
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.textColor = [UIColor darkGrayColor];
        _messageLabel.text = @"下拉刷新";
    }
    return _messageLabel;
}
@end
