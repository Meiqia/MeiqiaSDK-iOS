//
//  UIViewController+MQHieriachy.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/7/15.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "UIViewController+MQHieriachy.h"
#import "MQWindowUtil.h"

@implementation UIViewController(MQHieriachy)

+ (UIViewController *)mq_topMostViewController
{
    return [MQWindowUtil topController];
}

+ (UIWindow *)topWindow
{
    NSArray *windows = [MQWindowUtil currentWindows];
    for(UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]] &&
            window.windowLevel == UIWindowLevelNormal &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            return window;
    }
    
    return [MQWindowUtil currentWindow];
}


@end
