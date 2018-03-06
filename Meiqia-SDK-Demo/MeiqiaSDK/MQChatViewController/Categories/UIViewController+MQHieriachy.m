//
//  UIViewController+MQHieriachy.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/7/15.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "UIViewController+MQHieriachy.h"

@implementation UIViewController(MQHieriachy)

+ (UIViewController *)topMostViewController
{
    UIViewController *topController = [self topWindow].rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

+ (UIWindow *)topWindow
{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]] &&
            window.windowLevel == UIWindowLevelNormal &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            return window;
    }
    
    return [UIApplication sharedApplication].keyWindow;
}


@end
