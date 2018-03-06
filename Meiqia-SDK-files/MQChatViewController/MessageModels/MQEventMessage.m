//
//  MQEventMessage.m
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 15/11/9.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MQEventMessage.h"
#import "MQBundleUtil.h"

@interface MQEventMessage()

@property (nonatomic, strong) NSDictionary *tipStringMap;

@end

@implementation MQEventMessage

- (instancetype)initWithEventContent:(NSString *)eventContent
                           eventType:(MQChatEventType)eventType
{
    if (self = [super init]) {
        self.content    = eventContent;
        self.eventType  = eventType;
    }
    return self;
}

- (NSString *)tipString {
    return [self tipStringMap][@(self.eventType)];
}

- (NSDictionary *)tipStringMap {
    if (!_tipStringMap) {
        _tipStringMap = @{
                @(MQChatEventTypeAgentDidCloseConversation):@"",
                @(MQChatEventTypeEndConversationTimeout):@"",
                @(MQChatEventTypeRedirect):[NSString stringWithFormat:@"接下来由 %@ 为您服务", self.userName],
                @(MQChatEventTypeClientEvaluation):@"",
                @(MQChatEventTypeInviteEvaluation):@"",
                @(MQChatEventTypeAgentUpdate):@"",
                @(MQChatEventTypeQueueingRemoved):@"",
                @(MQChatEventTypeQueueingAdd):@"",
                @(MQChatEventTypeBotRedirectHuman):@"",
                @(MQChatEventTypeBackList):[MQBundleUtil localizedStringForKey:@"message_tips_online_failed_listed_in_black_list"],
                };
    }
    
    return _tipStringMap;
}

@end
