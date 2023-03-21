//
//  MQBotGuideMessage.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/1/12.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import "MQBotGuideMessage.h"

@implementation MQBotGuideMessage

- (instancetype)initWithContentArray:(NSArray *)array {
    if (self = [super init]) {
        self.guideContents = array;
    }
    return self;
}

@end
