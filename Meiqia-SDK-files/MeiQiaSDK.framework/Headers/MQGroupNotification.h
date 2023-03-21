//
//  MQGroupNotification.h
//  MeiQiaSDK
//
//  Created by shunxingzhang on 2022/6/15.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQGroupNotification : NSObject

/** 发送人的头像 */
@property (nonatomic, copy) NSString *avatar;

/** 发送人的名称 */
@property (nonatomic, copy) NSString *name;

/** 发送人的内容 */
@property (nonatomic, copy) NSString *content;

/** 发送人的客服id */
@property (nonatomic, copy) NSString *agentId;

/** 群发消息的群发id */
@property (nonatomic, assign) long pushId;

/** 群发消息的消息id */
@property (nonatomic, assign) long messageId;

- (instancetype)initWithDictory:(NSDictionary *)dic;

- (NSDictionary *)fromMapping;

@end

