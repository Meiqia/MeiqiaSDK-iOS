//
//  MQVisialMessageFactory.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/11/17.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQMessageFactoryHelper.h"

@interface MQVisialMessageFactory : NSObject <MQMessageFactory>

- (MQBaseMessage *)createMessage:(MQMessage *)plainMessage;

@end
