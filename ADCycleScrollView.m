//
//  ADCycleScrollView.m
//  GoldenRoad
//
//  Created by msl on 15/11/5.
//  Copyright © 2015年 Haodi. All rights reserved.
//

#import "ADCycleScrollView.h"

static NSTimeInterval animationDuration = 3.5f;

static CGFloat pageControlHeight = 30.0f;

@interface ADCycleScrollView ()<UIScrollViewDelegate>{
    NSInteger currentPage;
    NSInteger totalPages;
}

@property (nonatomic, strong)UIPageControl *pageControl;

@property (nonatomic, strong)NSMutableArray *contentViews;

@property (nonatomic, strong)NSMutableArray *totalViews;

@property (nonatomic, weak)NSTimer *timer;

@end

@implementation ADCycleScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES;
        [self initializeView];
        self.pageIndicatorTintColor = [UIColor whiteColor];
        self.currentPageIndicatorTintColor = [UIColor orangeColor];
        self.animationDution = animationDuration;
        self.contentViews = [NSMutableArray array];
        self.totalViews = [NSMutableArray array];
        
        currentPage = 0;
        totalPages = 0;
    }
    return self;
}


- (void)initializeView{
    _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds)* 3, CGRectGetHeight(self.bounds));
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds), 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.autoresizingMask = 0xFF;
    _scrollView.contentMode = UIViewContentModeCenter;
    _scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);

    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectZero];
    _pageControl.userInteractionEnabled = NO;
    
    [self addSubview:_scrollView];
    [self addSubview:_pageControl];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.origin.y = CGRectGetHeight(self.bounds) - pageControlHeight;
    rect.size.height = pageControlHeight;
    _pageControl.frame = rect;
}


- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor{
    _pageIndicatorTintColor = pageIndicatorTintColor;
    _pageControl.pageIndicatorTintColor =_pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor{
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    _pageControl.currentPageIndicatorTintColor =_currentPageIndicatorTintColor;
}

- (void)setAnimationDution:(NSTimeInterval)animationDution{
    _animationDution = animationDution;
    [_timer invalidate];
    _timer = nil;
    __weak typeof(self)weakSelf = self;
    _timer = [NSTimer scheduledTimerWithTimeInterval:_animationDution target:weakSelf selector:@selector(animationMove) userInfo:nil repeats:YES];
    [self pauseTimer];
}

- (void)animationMove{
    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
    [self.scrollView setContentOffset:newOffset animated:YES];
}

#pragma mark -dataSource
- (void)setDataource:(id<ADCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData{
    totalPages = [_datasource numberOfPages];
    currentPage  = totalPages<=currentPage?totalPages-1:currentPage;

    [self.totalViews removeAllObjects];
    for (int i= 0; i<totalPages; i++) {
        [self.totalViews addObject: [_datasource pageAtIndex:i]];
    }
    
    [self loadData];
    
    if(totalPages>1){
        [self resumeTimerAfterTimeInterval:animationDuration];
    }
    else{
        [self pauseTimer];
    }
}

- (void)loadData{
    _pageControl.numberOfPages = totalPages;
    _pageControl.currentPage = currentPage;
    
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self setScrollViewContentDataSource];

    [self getDisplayImagesWithCurpage:currentPage];
}

/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource
{
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:currentPage - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:currentPage + 1];

    [self.contentViews removeAllObjects];
    
    [self.contentViews addObject:self.totalViews[previousPageIndex]];
    [self.contentViews addObject:self.totalViews[currentPage]];
    [self.contentViews addObject:self.totalViews[rearPageIndex]];
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return totalPages - 1;
    } else if (currentPageIndex == totalPages) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

/**
 *  显示 左 中 右 三页
 */
- (void)getDisplayImagesWithCurpage:(NSInteger)page {
    NSInteger counter = 0;
    for (UIView *contentView in self.contentViews) {
        contentView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [contentView addGestureRecognizer:tapGesture];
        CGRect rightRect = contentView.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        
        contentView.frame = rightRect;
        [self.scrollView addSubview:contentView];
    }
    
    if(totalPages>1){
        _scrollView.scrollEnabled = YES;
        _pageControl.hidden = NO;
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }
    else{
        _scrollView.scrollEnabled = NO;
        _pageControl.hidden = YES;
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width*2, 0)];
    }
}

/**
 *  tap 手势点击
 */
- (void)contentViewTapAction:(id)sender{
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)]) {
        [_delegate didClickPage:self atIndex:currentPage];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self pauseTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    /**
     *  contentViews 为 2个的时候 出现 左右视图 显示问题
     */
    if (totalPages == 2) {
        int contentOffsetX = _scrollView.contentOffset.x;
        if (contentOffsetX < CGRectGetWidth(_scrollView.frame)) {
            UIView *view =  self.contentViews[0];
            view.frame = CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame));
        }
        else{
            UIView *view =  self.contentViews[0];
            view.frame = CGRectMake(CGRectGetWidth(view.frame)*2, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame));
        }
    }
    
    
    int contentOffsetX = _scrollView.contentOffset.x;
    if(contentOffsetX >= (2 * CGRectGetWidth(_scrollView.frame))) {
        currentPage = [self getValidNextPageIndexWithPageIndex:currentPage + 1];
//        NSLog(@"next，当前页:%ld",(long)currentPage);
        [self loadData];
    }
    if(contentOffsetX <= 0) {
        currentPage = [self getValidNextPageIndexWithPageIndex:currentPage - 1];
//        NSLog(@"previous，当前页:%ld",(long)currentPage);
        [self loadData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self resumeTimerAfterTimeInterval:_animationDution];
}

#pragma mark - timer oper
-(void)pauseTimer
{
    if (![_timer isValid]) {
        return ;
    }
    [_timer setFireDate:[NSDate distantFuture]];
}


-(void)resumeTimer
{
    if (![_timer isValid]) {
        return ;
    }
    [_timer setFireDate:[NSDate date]];
}

- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval
{
    if (![_timer isValid]) {
        return ;
    }
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}
@end
