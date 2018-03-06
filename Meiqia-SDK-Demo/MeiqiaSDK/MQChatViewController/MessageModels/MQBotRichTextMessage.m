//
//  MQBotRickTextMessage.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/8.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQBotRichTextMessage.h"

@implementation MQBotRichTextMessage
- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.summary = dictionary[@"summary"] ?: @"";
        self.thumbnail = dictionary[@"thumbnail"] ?: @"";
        self.content = dictionary[@"content"] ?: @"";
    }
    return self;
}

@end
