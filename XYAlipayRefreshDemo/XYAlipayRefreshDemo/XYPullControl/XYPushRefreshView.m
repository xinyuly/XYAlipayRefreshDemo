//
//  XYPushRefreshView.m
//  XYRefreshTool
//
//  Created by lixinyu on 16/5/21.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//
#import "XYPushRefreshView.h"


#define XYDefautlAnimDuration 0.25
typedef NS_ENUM(NSInteger,XYPushRefreshStatus) {
    XYPushRefreshStatusNormal        = 0,
    XYPushRefreshStatusPushToRefresh = 1,
    XYPushRefreshStatusRefreshing    = 2,
};

@interface XYPushRefreshView ()
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIImageView *loadView;
@property (nonatomic, strong) UILabel     *messageLabel;
@property (nonatomic, strong) UIScrollView *superScrollView;
@property (nonatomic, assign) XYPushRefreshStatus  currentStatus;
@end

@implementation XYPushRefreshView
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentOffset" ];
    [self removeObserver:self forKeyPath:@"contentSize" ];
    self.superScrollView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
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
    self.currentStatus = XYPushRefreshStatusNormal;
    [self addSubview:self.loadView];
    [self addSubview:self.arrowView];
    [self addSubview:self.messageLabel];
    self.loadView.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat centerX = self.bounds.size.width*0.5;
    CGFloat centerY = XYPushDownRefreshControlHeight*0.5;
    self.loadView.frame = CGRectMake(centerX-30, centerY-16, 32, 32);
    self.arrowView.frame = self.loadView.frame;
    self.messageLabel.frame = CGRectMake(centerX+10, centerY-20, 100, 40);

}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView*)newSuperview;
        [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self.superScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (self.superScrollView.isDragging) {
            CGPoint offset = [[change objectForKey:@"new"] CGPointValue];
            offset.y = offset.y + self.superScrollView.bounds.size.height;
            CGFloat height = self.superScrollView.contentSize.height+XYPushDownRefreshControlHeight;
            if (self.currentStatus == XYPushRefreshStatusPushToRefresh &&  offset.y > height && offset.y < height +30) {
                self.currentStatus = XYPushRefreshStatusNormal;
            } else if (self.currentStatus == XYPushRefreshStatusNormal && offset.y >(height +30)){
                self.currentStatus = XYPushRefreshStatusPushToRefresh;
            }
        } else if (self.currentStatus == XYPushRefreshStatusPushToRefresh) {
            self.currentStatus = XYPushRefreshStatusRefreshing;
        }     
    } else if ([keyPath isEqualToString:@"contentSize"]) {
        if (CGRectIsNull(self.superScrollView.bounds)) {
            return;
        }
        CGFloat y=MAX(self.superScrollView.bounds.size.height, self.superScrollView.contentSize.height);
        CGRect currentRect=CGRectMake(0,y , self.superScrollView.bounds.size.width, XYPushDownRefreshControlHeight);
        self.frame = currentRect;
        [self layoutIfNeeded];
    }
}

#pragma mark - action
- (void)startRefreshing  {
    //切换状态
    self.currentStatus = XYPushRefreshStatusRefreshing;
}

- (void)endRefreshing {
    self.currentStatus = XYPushRefreshStatusNormal;
    [UIView animateWithDuration:XYDefautlAnimDuration animations:^{
        UIEdgeInsets edgeInset = self.superScrollView.contentInset;
        edgeInset.bottom -= (XYPushDownRefreshControlHeight+50);
        self.superScrollView.contentInset = edgeInset;
    }];
}

- (void)hiddenPushView {
    self.hidden = YES;
    [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    self.superScrollView = nil;
    UIEdgeInsets edgeInset = self.superScrollView.contentInset;
    edgeInset.bottom += XYPushDownRefreshControlHeight;
    self.superScrollView.contentInset = edgeInset;
}

- (BOOL)isRefreshing {
    return (self.currentStatus == XYPushRefreshStatusRefreshing);
}
#pragma mark - Setter & getter
- (void)setCurrentStatus:(XYPushRefreshStatus)currentStatus {
    _currentStatus = currentStatus;
    __weak typeof(self) weakSelf = self;
    if (currentStatus == XYPushRefreshStatusNormal) {
        self.loadView.hidden = YES;
        self.arrowView.hidden = NO;
        self.messageLabel.text = @"上拉刷新";
        [UIView animateWithDuration:XYDefautlAnimDuration animations:^{
            weakSelf.arrowView.transform = CGAffineTransformIdentity;
        }];
    } else if (currentStatus == XYPushRefreshStatusPushToRefresh) {
        // 箭头旋转, 文字 释放刷新
        self.messageLabel.text = @"释放刷新";
        [UIView animateWithDuration:XYDefautlAnimDuration animations:^{
            weakSelf.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    } else if (currentStatus == XYPushRefreshStatusRefreshing) {
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
            edgeInset.bottom += (XYPushDownRefreshControlHeight +50);
            weakSelf.superScrollView.contentInset = edgeInset;
        }];
        if ([self.delegate respondsToSelector:@selector(pushRefreshViewStartLoad:)]) {
            [self.delegate pushRefreshViewStartLoad:self];
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
        _messageLabel.text = @"上拉刷新";
    }
    return _messageLabel;
}
@end
