//
//  MQPageScrollItemView.h
//  123
//
//  Created by shunxingzhang on 2022/12/27.
//  Copyright © 2022 shunxingzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static CGFloat const kMQPageItemLeftAndRightMargin = 0.0;
static CGFloat const kMQPageItemYMargin = 12.0;
static CGFloat const kMQPageItemContentHeight = 15.0;

@protocol MQPageScrollItemDelegate <NSObject>

- (void)selectedItemContent:(NSString *)content;

@end

@interface MQPageScrollItemView : UIView

@property (nonatomic, assign) int currentPageIndex;

@property (nonatomic, assign) int totalPage;

@property (nonatomic, weak) id <MQPageScrollItemDelegate> delegate;

- (instancetype)initPagescrollWithFrame:(CGRect)frame
                         itemViewTitles:(NSArray *)contents
                                 pageMaxSize:(int)size;

- (void)updateViewFrameWith:(CGFloat)maxWidth;

/**跳转到下一页*/
- (void)toNextPage;

/**跳转到上一页*/
- (void)toLastPage;

@end

NS_ASSUME_NONNULL_END
