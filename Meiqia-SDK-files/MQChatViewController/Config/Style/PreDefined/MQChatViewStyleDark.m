//
//  MQChatViewStyleDark.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/3/30.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQChatViewStyleDark.h"

@implementation MQChatViewStyleDark

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor =  [UIColor mq_colorWithHexString:midnightBlue];
        self.navTitleColor = [UIColor mq_colorWithHexString:gallery];
        self.navBarTintColor = [UIColor mq_colorWithHexString:clouds];
        
        self.incomingBubbleColor = [UIColor mq_colorWithHexString:clouds];
        self.incomingMsgTextColor = [UIColor mq_colorWithHexString:wetAsphalt];
        
        self.outgoingBubbleColor = [UIColor mq_colorWithHexString:silver];
        self.outgoingMsgTextColor = [UIColor mq_colorWithHexString:wetAsphalt];
        
        self.pullRefreshColor = [UIColor mq_colorWithHexString:midnightBlue];
        
        self.backgroundColor = [UIColor mq_colorWithHexString:midnightBlue];
        
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

@end
