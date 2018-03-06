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

+ (id<MQMessageFactory>)factoryWithMessageAction:(MQMessageAction)action contentType:(MQMessageContentType)contenType {
    if (action == MQMessageActionMessage || action == MQMessageActionTicketReply) {
        if (contenType == MQMessageContentTypeBot) {
            return [MQBotMessageFactory new];
        } else {
            return [MQVisialMessageFactory new];
        }
    } else {
        return [MQEventMessageFactory new];
    }
}

@end
