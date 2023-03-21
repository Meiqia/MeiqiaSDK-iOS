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

@implementation MQMessageBottomTagModel

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        if ([dic objectForKey:@"name"] && ![[dic objectForKey:@"name"] isEqual:[NSNull null]]) {
            self.name = dic[@"name"];
        }
        if ([dic objectForKey:@"type"] && ![[dic objectForKey:@"type"] isEqual:[NSNull null]]) {
            NSString *type = dic[@"type"];
            if ([type isEqualToString:@"copy"]) {
                self.tagType = MQMessageBottomTagTypeCopy;
            } else if ([type isEqualToString:@"call"]) {
                self.tagType = MQMessageBottomTagTypeCall;
            } else if ([type isEqualToString:@"link"]) {
                self.tagType = MQMessageBottomTagTypeLink;
            }
        }
        if ([dic objectForKey:@"value"] && ![[dic objectForKey:@"value"] isEqual:[NSNull null]]) {
            self.value = dic[@"value"];
        }
    }
    return self;
}

@end
