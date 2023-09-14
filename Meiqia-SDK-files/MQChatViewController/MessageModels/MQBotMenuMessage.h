//
//  MQBotMenuMessage.h
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 16/4/27.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQBaseMessage.h"

typedef enum : NSUInteger {
    MQBotMenuMessageNormal = 0,        //包含tip，和replay的提示语
    MQBotMenuMessageNoTip = 1 // 不包含提示语的
} MQBotMenuTipType;

@interface MQBotMenuMessage : MQBaseMessage

/** 消息content */
@property (nonatomic, copy) NSString *content;

/** 富文本消息 */
@property (nonatomic, copy) NSString *richContent;

/** 消息 menu */
@property (nonatomic, copy) NSArray *menu;

/** 消息 menu */
@property (nonatomic, assign) MQBotMenuTipType tipType;

/**
 * 初始化message
 */
- (instancetype)initWithContent:(NSString *)content menu:(NSArray *)menu;


@end
