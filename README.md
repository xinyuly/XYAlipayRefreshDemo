# XYAlipayRefreshDemo
Alipay 的新版，首页的UI和刷新控件的位置发生了变化。闲暇之余做了个类似的Demo

![image](https://github.com/xinyuly/XYAlipayRefreshDemo/blob/master/ali.png)


**实现方式：** UIScrollView + UITableView 。UITableView和一个topView作为UIScrollView的subView

**关键点：**

1.scrollView的Indicator的显示位置从tableView的位置开始显示

```
_scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(KTopViewHeight, 0, 0, 0);
```
2.设置tableView的scrollEnabled为NO,解决滑动冲突

```
_tableView.scrollEnabled = NO;
```

3.监听tableView的contentSize，实时改变scrollView的contentSize

```
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGRect tFrame = self.tableView.frame;
        tFrame.size.height = self.tableView.contentSize.height;
        self.tableView.frame = tFrame;
        self.scrollView.contentSize = CGSizeMake(0, self.tableView.contentSize.height+KTopViewHeight);
    }
}
```
4.在UIScrollView的代理里面实现topView和tableView的frame值

```
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
```
注：下拉刷新控件是本人自己写的。可以替换成任意需要的控件，例如：MJRefresh，在相应的位置修改即可
代码地址：https://github.com/xinyuly/XYAlipayRefreshDemo
刷新控件：https://github.com/xinyuly/XYRefreshTool
