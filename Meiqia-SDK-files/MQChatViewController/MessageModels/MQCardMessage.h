//
//  MQCardMessage.h
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/25.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQCardMessage : MQBaseMessage

@property (nonatomic, strong) NSArray *cardData;

@end

NS_ASSUME_NONNULL_END
