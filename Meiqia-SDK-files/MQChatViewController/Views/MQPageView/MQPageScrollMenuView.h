//
//  MQPageScrollMenuView.h
//  123
//
//  Created by shunxingzhang on 2022/12/26.
//  Copyright © 2022 shunxingzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MQPageScrollMenuDelegate <NSObject>

- (void)selectedMenuIndex:(NSInteger)index;

@end

@interface MQPageScrollMenuView : UIView

@property (nonatomic, weak) id <MQPageScrollMenuDelegate> delegate;

- (instancetype)initPagescrollMenuViewWithFrame:(CGRect)frame
                                     titles:(NSArray *)titles
                               currentIndex:(NSInteger)currentIndex;

- (void)updateScrollContentIndex:(NSInteger)index indexPercent:(float)percent;

- (void)beginScrollContent;

- (void)endScrollContentIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
