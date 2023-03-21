//
//  MQBotRickTextMessage.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/8.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQRichTextMessage.h"

@class MQBotMenuMessage;
@interface MQBotRichTextMessage : MQRichTextMessage

@property (nonatomic, strong) NSNumber *questionId;
@property (nonatomic, assign) BOOL isEvaluated;
/** 机器人消息评价，已解决或者未解决 */
@property (nonatomic, assign) BOOL solved;
@property (nonatomic, copy) NSString *subType;

@property (nonatomic, strong) MQBotMenuMessage *menu;

- (id)initWithDictionary:(NSDictionary *)dictionary ;

@end
