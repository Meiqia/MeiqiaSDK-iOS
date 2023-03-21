//
//  MQBotGuideCellModel.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/1/12.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"
#import "MQTagListView.h"
#import "MQBotGuideMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQBotGuideCellModel : NSObject <MQCellModelProtocol>

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readonly, assign) CGFloat cellWidth;

/**
 * @brief 引导tag的tagList
 */
@property (nonatomic, readonly, strong) MQTagListView *cacheTagListView;

/**
 * @brief 引导tag的数据源
 */
@property (nonatomic, readonly, strong) NSArray *cacheTags;

/**
 *  根据MQMessage内容来生成cell model
 */
- (MQBotGuideCellModel *)initCellModelWithMessage:(MQBotGuideMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<MQCellModelDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
