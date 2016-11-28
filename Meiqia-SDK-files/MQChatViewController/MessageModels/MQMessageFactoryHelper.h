//
//  MQMessageFactoryHelper.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/11/17.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQBaseMessage.h"
#import <MeiQiaSDK/MQMessage.h>

@protocol MQMessageFactory <NSObject>

- (MQBaseMessage *)createMessage:(MQMessage *)plainMessage;

@end


@interface MQMessageFactoryHelper : NSObject

+ (id<MQMessageFactory>)factoryWithMessageAction:(MQMessageAction)action contentType:(MQMessageContentType)contenType;

@end
