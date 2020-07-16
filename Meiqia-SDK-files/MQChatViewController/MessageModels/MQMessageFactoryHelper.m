//
//  MQMessageFactoryHelper.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/11/17.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQMessageFactoryHelper.h"
#import "MQEventMessageFactory.h"
#import "MQVisialMessageFactory.h"
#import "MQBotMessageFactory.h"

@implementation MQMessageFactoryHelper

+ (id<MQMessageFactory>)factoryWithMessageAction:(MQMessageAction)action contentType:(MQMessageContentType)contenType fromType:(MQMessageFromType)fromType {
    if (action == MQMessageActionMessage || action == MQMessageActionTicketReply || action == MQMessageActionAgentSendCard) {
        if (contenType == MQMessageContentTypeBot || (contenType == MQMessageContentTypeHybrid && fromType == MQMessageFromTypeBot)) {
            return [MQBotMessageFactory new];
        } else {
            return [MQVisialMessageFactory new];
        }
    } else {
        return [MQEventMessageFactory new];
    }
}

@end
