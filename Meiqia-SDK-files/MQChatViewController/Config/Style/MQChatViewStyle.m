//
//  MQChatViewStyle.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/3/29.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQChatViewStyleBase.h"
#import "MQChatViewStyleContentDefault.h"

@implementation MQChatViewStyleBase

+ (instancetype)createStyle:(MQChatViewStyle)style {
    switch (style) {
        case MQChatViewStyleDefault:
            return [MQChatViewStyleContentDefault new];
        default:
            return [MQChatViewStyleContentDefault new];
    }
}

@end
