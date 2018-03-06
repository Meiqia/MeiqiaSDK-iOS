//
//  MQEventMessage.h
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 15/11/9.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQBaseMessage.h"

typedef enum : NSUInteger {
    MQChatEventTypeInitConversation          = 0,   //初始化对话 (init_conv)
    MQChatEventTypeAgentDidCloseConversation = 1,   //客服结束对话 (end_conv_agent)
    MQChatEventTypeEndConversationTimeout    = 2,   //对话超时，系统自动结束对话 (end_conv_timeout)
    MQChatEventTypeRedirect                  = 3,   //顾客被转接 (agent_redirect)
    MQChatEventTypeAgentInputting            = 4,   //客服正在输入 (agent_inputting)
    MQChatEventTypeInviteEvaluation          = 5,    //收到客服邀请评价 (invite_evaluation)
    MQChatEventTypeClientEvaluation          = 6,    //顾客评价的结果
    MQChatEventTypeAgentUpdate               = 7,    //客服的状态发生改变
    MQChatEventTypeQueueingRemoved           = 8,    //顾客从等待客服队列中移除
    MQChatEventTypeQueueingAdd               = 9,    //顾客被添加到客服等待队列
    MQChatEventTypeBackList                  = 10,   // 被添加到黑名单
    MQChatEventTypeBotRedirectHuman          = 11,   //机器人转人工
} MQChatEventType;

@interface MQEventMessage : MQBaseMessage

/** 事件content */
@property (nonatomic, copy  ) NSString *content;

/** 事件类型 */
@property (nonatomic, assign) MQChatEventType eventType;

@property (nonatomic, strong, readonly) NSString *tipString;

/**
 * 初始化message
 */
- (instancetype)initWithEventContent:(NSString *)eventContent
                           eventType:(MQChatEventType)eventType;

@end
