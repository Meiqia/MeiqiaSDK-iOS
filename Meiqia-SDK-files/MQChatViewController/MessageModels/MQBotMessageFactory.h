//
//  MQBotMessageFactory.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/24.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MQMessage, MQBaseMessage;
@interface MQBotMessageFactory : NSObject

+ (MQBaseMessage *)createBotMessageWithMessage:(MQMessage *)originalMessage;

@end
