//
//  MQChatViewStyleBlue.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/3/30.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQChatViewStyleBlue.h"

@implementation MQChatViewStyleBlue

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor =  [UIColor mq_colorWithHexString:belizeHole];
        self.navTitleColor = [UIColor mq_colorWithHexString:gallery];
        self.navBarTintColor = [UIColor mq_colorWithHexString:clouds];
        
        self.incomingBubbleColor = [UIColor mq_colorWithHexString:dodgerBlue];
        self.incomingMsgTextColor = [UIColor mq_colorWithHexString:gallery];
        
        self.outgoingBubbleColor = [UIColor mq_colorWithHexString:gallery];
        self.outgoingMsgTextColor = [UIColor mq_colorWithHexString:dodgerBlue];
        
        self.pullRefreshColor = [UIColor mq_colorWithHexString:belizeHole];
        
        self.backgroundColor = [UIColor whiteColor];
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

@end
