//
//  MQPageView.h
//  123
//
//  Created by shunxingzhang on 2022/12/26.
//  Copyright © 2022 shunxingzhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQPageDataModel.h"
#import "MQPageScrollItemView.h"
#import "MQPageScrollMenuView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MQPageViewSelectedBlock)(NSString *content);

static CGFloat const kMQPageLineHeight = 1.0;
static CGFloat const kMQPageScrollMenuViewHeight = 30.0;
static CGFloat const kMQPageBottomButtonHeight = 30.0;

@interface MQPageView : UIView

/**
 * 生成 PageController
 *
 * @param frame react
 * @param list 数据源
 * @param size 每页显示的最多条数，超过就翻页
 * @param block 点击item内容的回调
 */
- (instancetype)initWithFrame:(CGRect)frame
                      dataArr:(NSArray<MQPageDataModel *> *)list
                    pageMaxSize:(int)size
                    block:(MQPageViewSelectedBlock)block;

- (void)updateViewFrameWith:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
