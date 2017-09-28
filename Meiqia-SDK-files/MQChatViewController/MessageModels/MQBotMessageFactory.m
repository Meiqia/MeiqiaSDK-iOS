//
//  MQBotMessageFactory.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/24.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQBotMessageFactory.h"
#import "MQBotRichTextMessage.h"
#import "MQTextMessage.h"
#import <MeiQiaSDK/MQManager.h>
#import "MQBotAnswerMessage.h"
#import "MQBotMenuMessage.h"

@implementation MQBotMessageFactory

- (MQBaseMessage *)createMessage:(MQMessage *)plainMessage {
    NSArray *normalTypes = @[@"evaluate", @"reply", @"redirect", @"queueing", @"manual_redirect"];
    
    NSString *subType = [plainMessage.accessoryData objectForKey:@"sub_type"] ?: @"";
    MQBaseMessage *message = nil;
    if ([[plainMessage.accessoryData objectForKey:@"content_robot"] count] > 0) {
        if ([normalTypes containsObject:subType]) {
            message = [self getNormalBotAnswerMessage:plainMessage.accessoryData subType:subType];
        } else if ([subType isEqualToString:@"menu"]) {
            message = [self getMenuBotMessage:plainMessage.accessoryData];
        } else if ([subType isEqualToString:@"message"]) {
            message = [self getTextMessage:plainMessage.accessoryData];
        }
    }
    
    message.messageId = plainMessage.messageId;
    message.date = plainMessage.createdOn;
    message.userName = plainMessage.messageUserName;
    message.userAvatarPath = plainMessage.messageAvatar;
    message.fromType = MQChatMessageIncoming;
    
    return message;
}

- (BOOL)isThisAnswerContainsMenu:(NSArray *)contentRobot {
    BOOL contains = NO;
    if ([contentRobot isKindOfClass:[NSArray class]]) {
        if (contentRobot.count > 1) {
            if ([contentRobot[1][@"type"] isEqualToString:@"related"]) {
                contains = YES;
            }
        }
    }
    
    return contains;
}

- (MQBaseMessage *)getNormalBotAnswerMessage:(NSDictionary *)data subType:(NSString *)subType {
    NSString *content = @"";
    MQBotMenuMessage *embedMenuMessage;
    NSLog(@"====收到的信息的内容为===%@",data);
    if ([subType isEqualToString:@"queueing"]) {
        content = @"暂无空闲客服，您已进入排队等待。";
        subType = @"redirect";
    } else {
        ///目前的相关问题回答消息不考虑图文消息
        if ([self isThisAnswerContainsMenu:data[@"content_robot"]]) {
            embedMenuMessage = [self getEmbedMenuBotMessage:data[@"content_robot"][1]];
            content = [[data objectForKey:@"content_robot"] firstObject][@"text"];
            content = [MQManager convertToUnicodeWithEmojiAlias:content];
        }
        
        MQBaseMessage *message = [self tryToGetRichTextMessage:data];
        //xlp 显示富文本 修改
//        if (message && embedMenuMessage == nil) {
        if (message  != nil) {

            MQBotRichTextMessage * botRichTextMessage = (MQBotRichTextMessage *)message;
            //如果是富文本cell，直接返回
            if (embedMenuMessage) {
                botRichTextMessage.menu = embedMenuMessage;
            }
            return botRichTextMessage;
        } else {
            content = [[data objectForKey:@"content_robot"] firstObject][@"text"];
            content = [MQManager convertToUnicodeWithEmojiAlias:content];
        }
    }
    BOOL isEvaluated = [data objectForKey:@"is_evaluated"] ? [[data objectForKey:@"is_evaluated"] boolValue] : false;
    MQBotAnswerMessage *botMessage = [[MQBotAnswerMessage alloc] initWithContent:content subType:subType isEvaluated:isEvaluated];
    if (embedMenuMessage) {
        botMessage.menu = embedMenuMessage;
    }
    return botMessage;
}

- (MQBaseMessage *)getMenuBotMessage:(NSDictionary *)data {
    NSString *content = @"";
    NSMutableArray *menu = [NSMutableArray new];
    NSArray *contentRobot = [data objectForKey:@"content_robot"] ?: [NSArray new];
    for (NSInteger i=0; i < [contentRobot count]; i++) {
        NSDictionary *subContent = [contentRobot objectAtIndex:i];
        if (i == 0 && [[subContent objectForKey:@"type"] isEqualToString:@"text"]) {
            content = [subContent objectForKey:@"text"];
        } else if ([[subContent objectForKey:@"type"] isEqualToString:@"menu"]) {
            NSArray *items = [subContent objectForKey:@"items"];
            for (NSDictionary *item in items) {
                NSString *menuTitle = [item objectForKey:@"text"];
                menuTitle = [MQManager convertToUnicodeWithEmojiAlias:menuTitle];
                [menu addObject:menuTitle];
            }
        }
    }
    content = [MQManager convertToUnicodeWithEmojiAlias:content];
    MQBotMenuMessage *botMessage = [[MQBotMenuMessage alloc] initWithContent:content menu:menu];
    return botMessage;
}

- (MQBotMenuMessage *)getEmbedMenuBotMessage:(NSDictionary *)data {
    NSArray *items = data[@"items"];
    NSMutableArray *menu = [NSMutableArray new];
    if ([items isKindOfClass:[NSArray class]]) {
        [items enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                NSString *title = item[@"text"];
                if (title) {
                    [menu addObject:title];
                }
            }
        }];
    }
    
    NSString *content = data[@"text_before"] ?: @"";
    content = [MQManager convertToUnicodeWithEmojiAlias:content];
    
    return [[MQBotMenuMessage alloc] initWithContent:content menu:menu];
}

- (MQBaseMessage *)getTextMessage:(NSDictionary *)data {
    MQBaseMessage *message = [self tryToGetRichTextMessage:data];
    if (message) {
        //如果是富文本cell，直接返回
        return message;
    } else {
        NSString *content = [[data objectForKey:@"content_robot"] firstObject][@"text"];
        content = [MQManager convertToUnicodeWithEmojiAlias:content];
        MQTextMessage *textMessage = [[MQTextMessage alloc] initWithContent:content];
        return textMessage;
    }
}

- (MQBaseMessage *)tryToGetRichTextMessage:(NSDictionary *)data {
    id content = [[data objectForKey:@"content_robot"] firstObject][@"rich_text"];
    if (content) {
        MQBotRichTextMessage *botRichTextMessage;
        if ([content isKindOfClass:[NSDictionary class]]) {
            botRichTextMessage = [[MQBotRichTextMessage alloc]initWithDictionary:content];
        } else {
            botRichTextMessage = [[MQBotRichTextMessage alloc]initWithDictionary:@{@"content":content}];
        }
        botRichTextMessage.thumbnail = data[@"thumbnail"];
        botRichTextMessage.summary = data[@"thumbnail"];
        botRichTextMessage.questionId = data[@"question_id"];
        
        botRichTextMessage.subType = data[@"sub_type"];
        
        BOOL isEvaluated = [data objectForKey:@"is_evaluated"] ? [[data objectForKey:@"is_evaluated"] boolValue] : false;

        botRichTextMessage.isEvaluated = isEvaluated;
        return botRichTextMessage;
    } else {
        return nil;
    }
}
@end
