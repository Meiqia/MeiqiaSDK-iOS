//
//  MQBotAnswerMessage.m
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 16/4/27.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQBotAnswerMessage.h"

@implementation MQBotAnswerMessage

- (instancetype)initWithContent:(NSString *)content
                        subType:(NSString *)subType
                    isEvaluated:(BOOL)isEvaluated
{
    if (self = [super init]) {
        self.content = content;
        self.subType = subType;
        self.isEvaluated = isEvaluated;
    }
    return self;
}


@end
