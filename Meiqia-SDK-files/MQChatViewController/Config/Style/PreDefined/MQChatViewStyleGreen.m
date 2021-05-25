//
//  MQChatViewStyleGreen.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/3/30.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQChatViewStyleGreen.h"

@implementation MQChatViewStyleGreen

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor =  [UIColor mq_colorWithHexString:greenSea];
        self.navTitleColor = [UIColor mq_colorWithHexString:gallery];
        self.navBarTintColor = [UIColor mq_colorWithHexString:clouds];
        
        self.incomingBubbleColor = [UIColor mq_colorWithHexString:turquoise];
        self.incomingMsgTextColor = [UIColor mq_colorWithHexString:gallery];
        
        self.outgoingBubbleColor = [UIColor mq_colorWithHexString:gallery];
        self.outgoingMsgTextColor = [UIColor mq_colorWithHexString:turquoise];
        
        self.pullRefreshColor = [UIColor mq_colorWithHexString:turquoise];
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}


@end
