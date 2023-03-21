//
//  MQNotificationView.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/6/15.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat const kMQNotificationViewMargin = 20.0;
static CGFloat const kMQNotificationViewHeight = 80.0;
@interface MQNotificationView : UIView

-(void)configViewWithSenderName:(NSString *)name
                  senderAvatarUrl:(NSString *)avatar
                    sendContent:(NSString *)content;
        

@end
