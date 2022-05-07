//
//  MQEnterprise.h
//  MeiQiaSDK
//
//  Created by Injoy on 15/10/27.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQPreChatData.h"

typedef enum : NSUInteger {
    MQTicketConfigContactFieldTypeText               = 0, //文字
    MQTicketConfigContactFieldTypeNumber             = 1, //数字
    MQTicketConfigContactFieldTypeTime               = 2, //日期
    MQTicketConfigContactFieldTypeSingleChoice       = 3, //单选
    MQTicketConfigContactFieldTypeMultipleChoice     = 4, //多选
} MQTicketConfigContactFieldType;

/**留言工单字段模型*/
@interface MQTicketConfigContactField : MQModel

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, assign) bool required;

@property (nonatomic, assign) MQTicketConfigContactFieldType type;

@property (nonatomic, strong) NSArray<NSString *> *metainfo; // 多选，单选类型中的选项内容

@end

/**企业工作台 工单配置信息*/

@interface MQTicketConfigInfo : MQModel

@property (nonatomic, copy) NSString *contactRule;

@property (nonatomic, copy) NSString *intro;

@property (nonatomic, copy) NSString *category; // 工单分类询问开关

// 留言输入框的内容类型：1、“content”，输入框的text直接显示为defaultTemplateContent，让用户自己修改； 2、“placeholder”，输入框的placeholder显示为content_placeholder，内容用户自己输入
@property (nonatomic, copy) NSString *content_fill_type;

@property (nonatomic, copy) NSString *defaultTemplateContent;

@property (nonatomic, copy) NSString *content_title; // 留言输入框的title，

@property (nonatomic, copy) NSString *content_placeholder; // 留言输入框的placeholder，

@property (nonatomic, strong) NSArray<MQTicketConfigContactField *> *custom_fields;

@end

@interface MQEnterpriseConfig : NSObject

/**企业工作台 配置信息*/

@property (nonatomic, copy) NSString *evaluationPromtText;///客服邀请评价显示的文案

@property (nonatomic, assign) bool showSwitch; //

@property (nonatomic, assign) BOOL enableBotFeedback; // 机器人的回答评价反馈功能是否开启

@property (nonatomic, assign) BOOL isScheduleAfterClientSendMessage; //就字面意思是 访客发送消息后才分配客服,即无消息访客过滤开关

@property (nonatomic, copy) NSString *avatar; //企业客服头像

@property (nonatomic, copy) NSString *public_nickname; //

@property (nonatomic, copy) NSString *enterpriseIntro; //

@property (nonatomic, assign) bool  queueStatus; //排队是否开启,true为开启

@property (nonatomic, copy) NSString *queueIntro; //排队文案

@property (nonatomic, copy) NSString *queueTicketIntro; //排队引导留言的文案

@property (nonatomic, readonly, assign) bool videoMsgStatus; //是否可以发送video类型消息

@property (nonatomic, strong) MQPreChatData *preChatData; //讯前表单数据模型

@property (nonatomic, strong) MQTicketConfigInfo *ticketConfigInfo; //工单留言数据模型

@end


@interface MQEnterprise : NSObject

/** 企业id */
@property (nonatomic, copy) NSString *enterpriseId;

/** 企业简称 */
@property (nonatomic, copy) NSString *name;

/** 企业全名 */
@property (nonatomic, copy) NSString *fullname;

/** 企业负责人的邮箱 */
@property (nonatomic, copy) NSString *contactEmail;

/** 企业负责人的电话 */
@property (nonatomic, copy) NSString *contactTelephone;

/** 企业负责人的姓名 */
@property (nonatomic, copy) NSString *contactName;

/** 企业联系电话 */
@property (nonatomic, copy) NSString *telephone;

/** 网址 */
@property (nonatomic, copy) NSString *website;

/** 行业 */
@property (nonatomic, copy) NSString *industry;

/** 企业地址 */
@property (nonatomic, copy) NSString *location;

/** 邮寄地址 */
@property (nonatomic, copy) NSString *mailingAddress;
/**企业工作台 配置信息*/
@property (nonatomic, strong) MQEnterpriseConfig *configInfo;

- (void)parseEnterpriseConfigData:(NSDictionary *)json;

- (NSString *)toEnterpriseConfigJsonString;

@end
