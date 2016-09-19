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

+ (MQBaseMessage *)createBotMessageWithMessage:(MQMessage *)originalMessage {
    NSArray *normalTypes = @[@"evaluate", @"reply", @"redirect", @"queueing", @"manual_redirect"];
    
    NSString *subType = [originalMessage.accessoryData objectForKey:@"sub_type"] ?: @"";
    
    if ([[originalMessage.accessoryData objectForKey:@"content_robot"] count] > 0) {
        if ([normalTypes containsObject:subType]) {
            return [self getNormalBotAnswerMessage:originalMessage.accessoryData subType:subType];
        } else if ([subType isEqualToString:@"menu"]) {
            return [self getMenuBotMessage:originalMessage.accessoryData];
        } else if ([subType isEqualToString:@"message"]) {
            return [self getTextMessage:originalMessage.accessoryData];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

+ (BOOL)isThisAnswerContainsMenu:(NSArray *)contentRobot {
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

+ (MQBaseMessage *)getNormalBotAnswerMessage:(NSDictionary *)data subType:(NSString *)subType {
    NSString *content = @"";
    MQBotMenuMessage *embedMenuMessage;
    
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
        if (message && embedMenuMessage == nil) {
            //如果是富文本cell，直接返回
            return message;
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

+ (MQBaseMessage *)getMenuBotMessage:(NSDictionary *)data {
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

+ (MQBotMenuMessage *)getEmbedMenuBotMessage:(NSDictionary *)data {
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

+ (MQBaseMessage *)getTextMessage:(NSDictionary *)data {
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

+ (MQBaseMessage *)tryToGetRichTextMessage:(NSDictionary *)data {
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
