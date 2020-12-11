//
//  MQWithDrawMessage.h
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/27.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQWithDrawMessage : MQBaseMessage

/** 消息是否撤回 */
@property (nonatomic, assign) BOOL isMessageWithDraw;

/** 内容 */
@property (nonatomic, copy) NSString *content;

@end

NS_ASSUME_NONNULL_END
