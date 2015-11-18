# ADCycleScrollView
ADCycleScrollView for banner 用于首页 广告 轮播图，支持 滑动，点击效果！
##使用环境
iOS 6 以上系统
##使用代码片段
```
#pragma mark - XLCycleScrollViewDatasource

- (NSInteger)numberOfPages{
    return  2; 
}

- (UIView *)pageAtIndex:(NSInteger)index{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, _clcleScrolleview.height)];
    imageView.image = [UIImage imageNamed:@"home_banner_1.png"];
    if ([_imageArray count]>0) {
        NSString *urls = _imageArray[index];
        [imageView sd_setImageWithURL:[NSURL URLWithString:urls] placeholderImage:[UIImage imageNamed:@"home_banner_1.png"]];
    }else{
    }
    return imageView;
}
```

```
[_clcleScrolleview reloadData]

```
##意见反馈
反馈邮箱: <ihaodi@icloud.com>