//
//  ADCycleScrollView.h
//  GoldenRoad
//
//  Created by msl on 15/11/5.
//  Copyright © 2015年 Haodi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ADCycleScrollViewDelegate;
@protocol ADCycleScrollViewDatasource;

@interface ADCycleScrollView : UIView

/**
 *  动画 移动 时间
 */
@property (nonatomic, assign)NSTimeInterval animationDution;

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIColor *currentPageIndicatorTintColor;
@property (nonatomic, strong)UIColor *pageIndicatorTintColor;

@property (nonatomic,weak,setter = setDataource:) id<ADCycleScrollViewDatasource> datasource;
@property (nonatomic,weak,setter = setDelegate:) id<ADCycleScrollViewDelegate> delegate;

- (void)reloadData;

@end


@protocol ADCycleScrollViewDelegate <NSObject>

@optional
- (void)didClickPage:(ADCycleScrollView *)csView atIndex:(NSInteger)index;

@end

@protocol ADCycleScrollViewDatasource <NSObject>

@required
- (NSInteger)numberOfPages;
- (UIView *)pageAtIndex:(NSInteger)index;

@end