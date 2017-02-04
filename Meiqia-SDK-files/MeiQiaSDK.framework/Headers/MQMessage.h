//
//  MQMessage.h
//  MeiQiaSDK
//
//  Created by dingnan on 15/10/23.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQAgent.h"

#define QUEUEING_SYMBOL 999

typedef enum : NSUInteger {
    MQMessageActionMessage                      = 0,   //普通消息 (message)
    MQMessageActionInitConversation             = 1,   //初始化对话 (init_conv)
    MQMessageActionAgentDidCloseConversation    = 2,   //客服结束对话 (end_conv_agent)
    MQMessageActionEndConversationTimeout       = 3,   //对话超时，系统自动结束对话 (end_conv_timeout)
    MQMessageActionRedirect                     = 4,   //顾客被转接 (agent_redirect)
    MQMessageActionAgentInputting               = 5,   //客服正在输入 (agent_inputting)
    MQMessageActionInviteEvaluation             = 6,   //收到客服邀请评价 (invite_evaluation)
    MQMessageActionClientEvaluation             = 7,   //顾客评价的结果 (client_evaluation)
    MQMessageActionTicketReply                  = 8,   //客服留言回复的消息
    MQMessageActionAgentUpdate                  = 9,    //客服的状态发生了改变
    MQMessageActionListedInBlackList            = 10,  //被客户加入到黑名单
    MQMessageActionRemovedFromBlackList         = 11,  //被客户从黑名单中移除
    MQMessageActionQueueingAdd                  = 12,  //顾客被添加到等待客服队列
    MQMessageActionQueueingRemoved              = 13,  //顾客从等待队列中移除
} MQMessageAction;

typedef enum : NSUInteger {
    MQMessageContentTypeText                 = 0,//文字
    MQMessageContentTypeImage                = 1,//图片
    MQMessageContentTypeVoice                = 2, //语音
    MQMessageContentTypeFile                 = 3, //文件传输
    MQMessageContentTypeBot                  = 4,  //机器人消息
    MQMessageContentTypeRichText             = 5, //图文消息
} MQMessageContentType;

typedef enum : NSUInteger {
    MQMessageFromTypeClient                  = 0,//来自 顾客
    MQMessageFromTypeAgent                   = 1,//来自 客服
    MQMessageFromTypeSystem                  = 2,//来自 系统
    MQMessageFromTypeBot                     = 3 //来自 机器人
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

@interface MQMessage : MQModel <NSCopying>

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
@property (nonatomic, assign) bool                 isRead;

/*
 该消息对应的 enterprise id, 不一定有值，也不存数据库，仅用来判断该消息属于哪个企业，用来切换数据库, 如果这个地方没有值，查看 agent 对象里面的 enterpriseId 字段
 */
@property (nonatomic, copy) NSString *enterpriseId;

///** 消息的 sub_type */
//@property (nonatomic, copy)   NSString             *subType;
//
///** 机器人消息 */
//@property (nonatomic, copy)   NSArray              *contentRobot;

/** 不同的 message 类型会携带不同数据，也可能为空, 以JSON格式保存到数据库 */
/**
 机器人的 accessorData
 {
    sub_type, content_robot, question_id, is_evaluate
 }
 **/
@property (nonatomic, copy) id accessoryData;

+ (instancetype)createBlacklistMessageWithAction:(NSString *)action;

- (NSString *)stringFromContentType;

//- (id)initMessageWithData:(NSDictionary *)data;

@end
