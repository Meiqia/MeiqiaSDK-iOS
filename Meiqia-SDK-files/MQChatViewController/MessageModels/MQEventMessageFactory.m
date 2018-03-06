//
//  MQEventMessageFactory.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/11/17.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQEventMessageFactory.h"
#import "MQEventMessage.h"
#import "MQBundleUtil.h"

@implementation MQEventMessageFactory

- (MQBaseMessage *)createMessage:(MQMessage *)plainMessage {
    NSString *eventContent = @"";
    MQChatEventType eventType = MQChatEventTypeInitConversation;
    switch (plainMessage.action) {
        case MQMessageActionInitConversation:
        {
            eventContent = @"您进入了客服对话";
            eventType = MQChatEventTypeInitConversation;
            break;
        }
        case MQMessageActionAgentDidCloseConversation:
        {
            eventContent = @"客服结束了此条对话";
            eventType = MQChatEventTypeAgentDidCloseConversation;
            break;
        }
        case MQMessageActionEndConversationTimeout:
        {
            eventContent = @"对话超时，系统自动结束了对话";
            eventType = MQChatEventTypeEndConversationTimeout;
            break;
        }
        case MQMessageActionRedirect:
        {
            eventContent = @"您的对话被转接给了其他客服";
            eventType = MQChatEventTypeRedirect;
            break;
        }
        case MQMessageActionAgentInputting:
        {
            eventContent = @"客服正在输入...";
            eventType = MQChatEventTypeAgentInputting;
            break;
        }
        case MQMessageActionInviteEvaluation:
        {
            eventContent = @"客服邀请您评价刚才的服务";
            eventType = MQChatEventTypeInviteEvaluation;
            break;
        }
        case MQMessageActionClientEvaluation:
        {
            eventContent = @"顾客评价结果";
            eventType = MQChatEventTypeClientEvaluation;
            break;
        }
        case MQMessageActionAgentUpdate:
        {
            eventContent = @"客服状态发生改变";
            eventType = MQChatEventTypeAgentUpdate;
            break;
        }
        case MQMessageActionListedInBlackList:
        {
            eventContent = [MQBundleUtil localizedStringForKey:@"message_tips_online_failed_listed_in_black_list"];
            eventType = MQChatEventTypeAgentUpdate;
            break;
        }
        case MQMessageActionQueueingRemoved:
        {
            eventContent = @"queue remove";
            eventType = MQChatEventTypeQueueingRemoved;
            break;
        }
        case MQMessageActionQueueingAdd:
        {
            eventContent = @"queue add";
            eventType = MQChatEventTypeQueueingAdd;
            break;
        }
        default:
            break;
    }
    if (eventContent.length == 0) {
        return nil;
    }
    MQEventMessage *toMessage = [[MQEventMessage alloc] initWithEventContent:eventContent eventType:eventType];
    toMessage.messageId = plainMessage.messageId;
    toMessage.date = plainMessage.createdOn;
    toMessage.content = eventContent;
    toMessage.userName = plainMessage.agent.nickname;
    
    if (plainMessage.action == MQMessageActionListedInBlackList) {
        toMessage.eventType = MQChatEventTypeBackList;
    }
    
    return toMessage;
}

@end
