//
//  MQEnterprise.h
//  MeiQiaSDK
//
//  Created by Injoy on 15/10/27.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQPreChatData.h"

@interface MQEnterpriseConfig : NSObject

/**企业工作台 配置信息*/

@property (nonatomic, copy) NSString *evaluationPromtText;///客服邀请评价显示的文案

@property (nonatomic, assign) bool showSwitch; //

@property (nonatomic, assign) BOOL isScheduleAfterClientSendMessage; //就字面意思是 访客发送消息后才分配客服,即无消息访客过滤开关

@property (nonatomic, copy) NSString *avatar; //企业客服头像

@property (nonatomic, copy) NSString *public_nickname; //

@property (nonatomic, copy) NSString *enterpriseIntro; //

@property (nonatomic, copy) NSString *intro;

@property (nonatomic, strong) NSArray *ticketContactFields;

@property (nonatomic, copy) NSString *ticketContactFillInRule;

@property (nonatomic, strong) MQPreChatData *preChatData; //讯前表单数据模型

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
