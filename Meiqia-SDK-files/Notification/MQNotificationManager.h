//
//  MQNotificationManager.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/5/30.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 点击了群发送消息
 */
#define MQ_CLICK_GROUP_NOTIFICATION @"MQ_CLICK_GROUP_NOTIFICATION"

@interface MQNotificationManager : NSObject

+ (MQNotificationManager *)sharedManager;

- (void)openMQGroupNotificationServer;

- (void)showNotification;

@end
