//
//  MQBotMenuMessage.h
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 16/4/27.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQBaseMessage.h"

@interface MQBotMenuMessage : MQBaseMessage

/** 消息content */
@property (nonatomic, copy) NSString *content;

/** 消息 menu */
@property (nonatomic, copy) NSArray *menu;

/**
 * 初始化message
 */
- (instancetype)initWithContent:(NSString *)content menu:(NSArray *)menu;


@end
