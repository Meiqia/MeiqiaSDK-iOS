//
//  MQMessage.h
//  MeiQiaSDK
//
//  Created by dingnan on 15/10/23.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQAgent.h"

typedef enum : NSUInteger {
    MQMessageActionMessage                   = 0,//普通消息 (message)
    MQMessageActionInitConversation          = 1,//初始化对话 (init_conv)
    MQMessageActionAgentDidCloseConversation = 2,//客服结束对话 (end_conv_agent)
    MQMessageActionEndConversationTimeout    = 3,//对话超时，系统自动结束对话 (end_conv_timeout)
    MQMessageActionRedirect                  = 4,//顾客被转接 (agent_redirect)
    MQMessageActionAgentInputting            = 5 //客服正在输入 (agent_inputting)
} MQMessageAction;

typedef enum : NSUInteger {
    MQMessageContentTypeText                 = 0,//文字
    MQMessageContentTypeImage                = 1,//图片
    MQMessageContentTypeVoice                = 2 //语音
} MQMessageContentType;

typedef enum : NSUInteger {
    MQMessageFromTypeClient                  = 0,//来自 顾客
    MQMessageFromTypeAgent                   = 1,//来自 客服
    MQMessageFromTypeSystem                  = 2 //来自 系统
} MQMessageFromType;

typedef enum : NSUInteger {
    MQMessageTypeMessage                     = 0,//普通消息
    MQMessageTypeWelcome                     = 1,//欢迎消息
    MQMessageTypeEnding                      = 2,//结束语
    MQMessageTypeRemark                      = 3,//评价
    MQMessageTypeReply                       = 4 //留言
} MQMessageType;

typedef enum : NSUInteger {
    MQMessageSendStatusSuccess               = 0,//发送成功
    MQMessageSendStatusFailed                = 1,//发送失败
    MQMessageSendStatusSending               = 2 //发送中
} MQMessageSendStatus;

@interface MQMessage : NSObject <NSCopying>

/** 消息id */
@property (nonatomic, copy  ) NSString             *messageId;

/** 消息内容 */
@property (nonatomic, copy  ) NSString             *content;

/** 消息的状态 */
@property (nonatomic, assign) MQMessageAction      action;

/** 内容类型 */
@property (nonatomic, assign) MQMessageContentType contentType;

/** 顾客id */
@property (nonatomic, copy  ) NSString             *trackId;

/** 客服id */
@property (nonatomic, copy  ) NSString             *agentId;

/** 客服 */
@property (nonatomic, strong) MQAgent              *agent;

/** 消息发送人头像 */
@property (nonatomic, copy  ) NSString             *messageAvatar;

/** 消息发送人名字 */
@property (nonatomic, copy  ) NSString             *messageUserName;

/** 消息创建时间, UTC格式 */
@property (nonatomic, copy  ) NSDate               *createdOn;

/** 来自顾客还是客服 */
@property (nonatomic, assign) MQMessageFromType    fromType;

/** 消息类型 */
@property (nonatomic, assign) MQMessageType        type;

/** 消息状态 */
@property (nonatomic, assign) MQMessageSendStatus  sendStatus;

/** 消息对应的对话id */
@property (nonatomic, copy  ) NSString             *conversationId;

/** 消息是否已读 */
@property (nonatomic, assign) BOOL                 isRead;

@end
