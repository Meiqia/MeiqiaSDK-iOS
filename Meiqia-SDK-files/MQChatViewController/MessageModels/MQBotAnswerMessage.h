//
//  MQBotAnswerMessage.h
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 16/4/27.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQBaseMessage.h"

@class MQBotMenuMessage;
@interface MQBotAnswerMessage : MQBaseMessage

/** 消息content */
@property (nonatomic, copy) NSString *content;

/** 机器人消息的 sub type */
@property (nonatomic, copy) NSString *subType;

/** 机器人消息是否评价 */
@property (nonatomic, assign) BOOL isEvaluated;

/** 机器人消息评价，已解决或者未解决 */
@property (nonatomic, assign) BOOL solved;

@property (nonatomic, strong) MQBotMenuMessage *menu;


/**
 * 用文字初始化message
 */
- (instancetype)initWithContent:(NSString *)content
                        subType:(NSString *)subType
                    isEvaluated:(BOOL)isEvaluated;

@end
