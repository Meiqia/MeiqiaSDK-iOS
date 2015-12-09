//
//  MQConversation.h
//  MeiQiaSDK
//
//  Created by dingnan on 15/10/23.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQConversation : NSObject

/** 对话id */
@property (nonatomic, copy  ) NSString       *conversationId;

/** 客服id */
@property (nonatomic, copy  ) NSString       *agentId;

/** 客服消息数量 */
@property (nonatomic, assign) NSInteger      agentMsgNum;

/** 第一次被分配的客服id */
@property (nonatomic, copy  ) NSString       *assignee;

/** 顾客首次发送消息的时间。如果没有消息,值为0 */
@property (nonatomic, assign) NSTimeInterval clientFirstSendTime;

/** 顾客消息数量 */
@property (nonatomic, assign) NSInteger      clientMsgNum;

/** 顾客和客服的消息数量（不包括系统产生的消息） */
@property (nonatomic, assign) NSInteger      msgNum;

/** 最后消息内容 */
@property (nonatomic, copy  ) NSString       *lastMsgContent;

/** 最后消息的发送时间。如果没有消息，值为0 */
@property (nonatomic, assign) NSTimeInterval lastMsgCreatedOn;

/** 结束对话的时间。如果对话还没有结束 */
@property (nonatomic, assign) NSTimeInterval endedOn;

/** 企业id */
@property (nonatomic, copy  ) NSString       *enterpriseId;

@end
