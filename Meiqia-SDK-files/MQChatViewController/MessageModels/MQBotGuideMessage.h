//
//  MQBotGuideMessage.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/1/12.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import "MQBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQBotGuideMessage : MQBaseMessage

/** 引导按钮内容的数组 */
@property (nonatomic, strong) NSArray *guideContents;

/**
 * 初始化message
 */
- (instancetype)initWithContentArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
