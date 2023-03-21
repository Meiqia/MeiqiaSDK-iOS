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

/**
 *  点击群发消息的回调处理是否需要自己处理  默认NO,跳转到客服页面发起会话
 */
@property (nonatomic, assign) BOOL handleNotification;

+ (MQNotificationManager *)sharedManager;

- (void)openMQGroupNotificationServer;

@end
