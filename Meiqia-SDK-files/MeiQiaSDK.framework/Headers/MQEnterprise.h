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

///客服邀请评价显示的文案
@property (nonatomic, copy) NSString *evaluationPromtText;

@property (nonatomic, assign) BOOL showSwitch;

@property (nonatomic, copy) NSString *intro;

@property (nonatomic, strong) NSArray *ticketContactFields;

@property (nonatomic, copy) NSString *ticketContactFillInRule;

@property (nonatomic, strong) MQPreChatData *preChatData;

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

@property (nonatomic, strong) MQEnterpriseConfig *configInfo;

- (void)parseEnterpriseConfigData:(NSDictionary *)json;

- (NSString *)toEnterpriseConfigJsonString;

@end
