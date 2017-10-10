//
//  MQDefinition.h
//  MeiQiaSDK
//
//  Created by dingnan on 15/10/27.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

#define stringify(arg) (@""#arg)
#define recordError(e) { [MQDataCache sharedCache].globalError = e; }

typedef NS_ENUM(NSUInteger, MQState) {
    MQStateUninitialized,
    MQStateInitialized,
    MQStateOffline, // not using
    MQStateUnallocatedAgent,
    MQStateAllocatingAgent,
    MQStateAllocatedAgent,
    MQStateBlacklisted,
    MQStateQueueing,
};
typedef void (^StateChangeBlock)(MQState oldState, MQState newState, NSDictionary *value, NSError *error);

/**
 *  美洽客服系统当前有新消息，开发者可实现该协议方法，通过此方法显示小红点未读标识
 */
#define MQ_RECEIVED_NEW_MESSAGES_NOTIFICATION @"MQ_RECEIVED_NEW_MESSAGES_NOTIFICATION"

/**
 *  收到该通知，即表示美洽的通信接口出错，通信连接断开
 */

#define MQ_COMMUNICATION_FAILED_NOTIFICATION @"MQ_COMMUNICATION_FAILED_NOTIFICATION"

/**
 *  收到该通知，即表示顾客成功上线美洽系统
 */
#define MQ_CLIENT_ONLINE_SUCCESS_NOTIFICATION @"MQ_CLIENT_ONLINE_SUCCESS_NOTIFICATION"

/**
 *  美洽的错误码
 */
#define MQRequesetErrorDomain @"com.meiqia.error.resquest.error"


/**
 当连接的状态改变时发送的通知
 */
#define MQ_NOTIFICATION_SOCKET_STATUS_CHANGE @"MQ_NOTIFICATION_SOCKET_STATUS_CHANGE"
#define SOCKET_STATUS_CONNECTED @"SOCKET_STATUS_CONNECTED"
#define SOCKET_STATUS_DISCONNECTED @"SOCKET_STATUS_DISCONNECTED"

/**
 聊天窗口出现
 */
#define MQ_NOTIFICATION_CHAT_BEGIN @"MQ_NOTIFICATION_CHAT_BEGIN"

/**
 聊天窗口消失
 */
#define MQ_NOTIFICATION_CHAT_END @"MQ_NOTIFICATION_CHAT_END"

/**
 当用户从排队队列被客服接入的时候出现
 */
#define MQ_NOTIFICATION_QUEUEING_END @"MQ_NOTIFICATION_QUEUEING_END"

/**
 美洽Error的code对应码
 */
typedef enum : NSInteger {
    MQErrorCodeParameterUnKnown             = -2000,    //未知错误
    MQErrorCodeParameterError               = -2001,    //参数错误
    MQErrorCodeCurrentClientNotFound        = -2003,    //当前没有顾客，请新建一个顾客后再上线
    MQErrorCodeClientNotExisted             = -2004,    //美洽服务端没有找到对应的client
    MQErrorCodeConversationNotFound         = -2005,    //美洽服务端没有找到该对话
    MQErrorCodePlistConfigurationError      = -2006,    //开发者App的info.plist没有增加NSExceptionDomains，请参考https://github.com/Meiqia/Meiqia-SDK-iOS-Demo#info.plist设置
    MQErrorCodeBlacklisted                  = -2007,    //被加入黑名单，发消息和分配对话都会失败
    MQErrorCodeSchedulerFail                = -2008,    // 分配对话失败
    MQErrorCodeUninitailized                = -2009,    // 未初始化操作
    MQErrorCodeInitializFailed              = -2010,    // 初始化失败
    MQErrorCodeBotFailToRedirectToHuman     = -3001,    // 机器人转人工失败
} MQErrorCode;

/**
 顾客上线的结果枚举类型
 */
typedef enum : NSUInteger {
    MQClientOnlineResultSuccess = 0,        //上线成功
    MQClientOnlineResultParameterError,     //上线参数错误
    MQClientOnlineResultNotScheduledAgent,   //没有可接待的客服
    MQClientOnlineResultBlacklisted,
} MQClientOnlineResult;

/**
 指定分配客服，该客服不在线后转接的逻辑
 */
typedef enum : NSUInteger {
    MQScheduleRulesRedirectNone         = 1,            //不转接给任何人
    MQScheduleRulesRedirectGroup        = 2,            //转接给组内的人
    MQScheduleRulesRedirectEnterprise   = 3             //转接给企业其他随机一个人
} MQScheduleRules;

/**
 顾客对客服的某次对话的评价
 */
typedef enum : NSUInteger {
    MQConversationEvaluationNegative    = 0,            //差评
    MQConversationEvaluationModerate    = 1,            //中评
    MQConversationEvaluationPositive    = 2             //好评
} MQConversationEvaluation;
