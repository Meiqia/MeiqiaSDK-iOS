//
//  MQTextMessage.m
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 15/10/30.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MQTextMessage.h"
#import "NSString+MQRegular.h"

@implementation MQTextMessage

- (instancetype)initWithContent:(NSString *)content {
    if (self = [super init]) {
        self.content = [content mq_textContent];
    }
    return self;
}

@end
