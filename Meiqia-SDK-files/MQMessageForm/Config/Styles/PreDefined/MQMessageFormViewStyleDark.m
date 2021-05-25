//
//  MQMessageFormViewStyleDark.m
//  Meiqia-SDK-Demo
//
//  Created by bingoogol on 16/5/24.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQMessageFormViewStyleDark.h"

@implementation MQMessageFormViewStyleDark

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor =  [UIColor mq_colorWithHexString:midnightBlue];
        self.navTitleColor = [UIColor mq_colorWithHexString:gallery];
        self.navBarTintColor = [UIColor mq_colorWithHexString:clouds];
    }
    return self;
}

@end
