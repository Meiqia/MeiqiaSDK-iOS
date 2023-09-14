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
#import "MQBotGuideMessage.h"
#import <MeiQiaSDK/MQJSONHelper.h>
#import "MQBotHighMenuMessage.h"

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
            
            if ([plainMessage.accessoryData objectForKey:@"operator_msg"] && ![[plainMessage.accessoryData objectForKey:@"operator_msg"] isEqual:[NSNull null]] && [message isKindOfClass:[MQBotRichTextMessage class]]) {
                // 营销机器人的底部操做按钮
                MQBotRichTextMessage *botRichTextMessage = (MQBotRichTextMessage *)message;
                botRichTextMessage.tags = [self getMessageBottomTagModel:plainMessage];
                message = botRichTextMessage;
            }
        } else if ([subType isEqualToString:@"button"]) {
            // 营销机器人的引导按钮
            MQBotGuideMessage *guideMessage = [[MQBotGuideMessage alloc] initWithContentArray:[plainMessage.accessoryData objectForKey:@"tags"]];
            message = guideMessage;
        } else {
            MQTextMessage *textMessage = [[MQTextMessage alloc] initWithContent:@"当前 App 暂不支持该类型消息。"];
            message = textMessage;
        }
    }
    
    message.messageId = plainMessage.messageId;
    message.date = plainMessage.createdOn;
    message.userName = plainMessage.messageUserName;
    message.userAvatarPath = plainMessage.messageAvatar;
    message.fromType = MQChatMessageIncoming;
    message.conversionId = plainMessage.conversationId;
    // 处理托管机器人的
    if ([plainMessage.accessoryData objectForKey:@"display_avatar"]) {
        message.userAvatarPath = [plainMessage.accessoryData objectForKey:@"display_avatar"];
    }
    if ([plainMessage.accessoryData objectForKey:@"display_nickname"]) {
        message.userName = [plainMessage.accessoryData objectForKey:@"display_nickname"];
    }
    
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
//    NSLog(@"====收到的信息的内容为===%@",data);
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
    BOOL isSolved = [data objectForKey:@"is_useful"] ? [[data objectForKey:@"is_useful"] boolValue] : YES;

    if ([subType isEqualToString:@"reply"] && ![MQManager enableLeaveComment]) {
        subType = @"normal";
    }
    MQBotAnswerMessage *botMessage = [[MQBotAnswerMessage alloc] initWithContent:content subType:subType isEvaluated:isEvaluated];
    botMessage.solved = isSolved;
    if (embedMenuMessage) {
        botMessage.menu = embedMenuMessage;
    }
    return botMessage;
}

- (MQBaseMessage *)getMenuBotMessage:(NSDictionary *)data {
    NSString *content = @"";
    NSString *richContent = @"";
    NSMutableArray *menu = [NSMutableArray new];
    
    NSMutableArray *highMenu = [[NSMutableArray alloc] init];
    NSInteger highMenuPageSize = 0;
    BOOL needTip = YES;
    
    NSArray *contentRobot = [data objectForKey:@"content_robot"] ?: [NSArray new];
    for (NSInteger i=0; i < [contentRobot count]; i++) {
        NSDictionary *subContent = [contentRobot objectAtIndex:i];
        if ([subContent objectForKey:@"rich_text"]) {
            // 强制转为富文本
            richContent = [subContent objectForKey:@"rich_text"];
        }
        if (i == 0 && [[subContent objectForKey:@"type"] isEqualToString:@"text"]) {
            content = [subContent objectForKey:@"text"];
        } else if ([[subContent objectForKey:@"type"] isEqualToString:@"related"]) {
            content = [subContent objectForKey:@"text_before"];
            if ([subContent objectForKey:@"items"]) {
                NSArray *dataArr = [subContent objectForKey:@"items"];
                for (NSDictionary *dic in dataArr) {
                    [menu addObject:dic[@"text"]];
                }
            }
            needTip = NO;
        } else if ([[subContent objectForKey:@"type"] isEqualToString:@"menu"]) {
            if ([subContent objectForKey:@"c_type"]) {
                if ([subContent objectForKey:@"page_size"]) {
                    highMenuPageSize = [[subContent objectForKey:@"page_size"] integerValue];
                }
                if ([subContent objectForKey:@"data"] && ![[subContent objectForKey:@"data"] isEqual:[NSNull null]]) {
                    NSArray *dataArr = [subContent objectForKey:@"data"];
                    if ([subContent objectForKey:@"c_type"]) {
                        NSString *c_type = [subContent objectForKey:@"c_type"];
                        if ([c_type isEqualToString:@"base"]) {
                            MQPageDataModel *model = [[MQPageDataModel alloc] init];
                            model.titleStr = @"";
                            model.contentArr = [[NSArray alloc] initWithArray:dataArr];
                            [highMenu addObject:model];
                        } else if ([c_type isEqualToString:@"advanced"]) {
                            for (NSDictionary *dic in dataArr) {
                                NSArray *contentArr = [dic objectForKey:@"items"];
                                MQPageDataModel *model = [[MQPageDataModel alloc] init];
                                model.titleStr = [dic objectForKey:@"category"];
                                model.contentArr = [[NSArray alloc] initWithArray:contentArr];
                                [highMenu addObject:model];
                            }
                        }
                    }
                }
            } else {
                NSArray *items = [subContent objectForKey:@"items"];
                for (NSDictionary *item in items) {
                    NSString *menuTitle = [item objectForKey:@"text"];
                    menuTitle = [MQManager convertToUnicodeWithEmojiAlias:menuTitle];
                    [menu addObject:menuTitle];
                }
            }
        }
    }
    
    content = [MQManager convertToUnicodeWithEmojiAlias:content];
    if (highMenu.count > 0) {
        // 新版高级相关问题
        MQBotHighMenuMessage *botMessage = [[MQBotHighMenuMessage alloc] initWithMenuData:highMenu contentText:content pageSize:highMenuPageSize];
        botMessage.richContent = richContent;
        return botMessage;
    } else {
        if (richContent.length > 0) {
            MQBotRichTextMessage *botMessage = [[MQBotRichTextMessage alloc]initWithDictionary:@{@"content": richContent}];
            return botMessage;
        }else {
            MQBotMenuMessage *botMessage = [[MQBotMenuMessage alloc] initWithContent:content menu:menu];
            botMessage.tipType = needTip ? MQBotMenuMessageNormal : MQBotMenuMessageNoTip;
            botMessage.richContent = richContent;
            return botMessage;
        }
    }
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
        BOOL isSolved = [data objectForKey:@"is_useful"] ? [[data objectForKey:@"is_useful"] boolValue] : YES;

        botRichTextMessage.isEvaluated = isEvaluated;
        botRichTextMessage.solved = isSolved;
        return botRichTextMessage;
    } else {
        return nil;
    }
}

- (NSArray *)getMessageBottomTagModel:(MQMessage *)message
{
    if (message.accessoryData && [message.accessoryData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDic = [NSDictionary dictionaryWithDictionary:message.accessoryData];
        if ([dataDic objectForKey:@"operator_msg"] && ![[dataDic objectForKey:@"operator_msg"] isEqual:[NSNull null]]) {
            NSArray *tagArr = [dataDic objectForKey:@"operator_msg"];
            NSMutableArray *resultArr = [NSMutableArray array];
            for (NSDictionary * dic in tagArr) {
                [resultArr addObject:[[MQMessageBottomTagModel alloc] initWithDictionary:dic]];
            }
            if (resultArr.count > 0) {
                return resultArr;
            }
        }
    }
    return nil;
}

@end
