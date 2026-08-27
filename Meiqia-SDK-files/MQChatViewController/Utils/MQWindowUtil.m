//
//  MQWindowUtil.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/15.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQWindowUtil.h"

static __weak UIWindow *MQPreferredWindow;

@implementation MQWindowUtil

+ (void)presentActionSheetWithTitle:(NSString *)title
                       actionTitles:(NSArray<NSString *> *)actionTitles
                        cancelTitle:(NSString *)cancelTitle
                         sourceView:(UIView *)sourceView
                            handler:(void (^)(NSInteger index))handler {
    UIViewController *controller = [self topControllerForView:sourceView];
    if (!controller) {
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                message:nil
                                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    [actionTitles enumerateObjectsUsingBlock:^(NSString *actionTitle, NSUInteger index, BOOL *stop) {
        [alertController addAction:[UIAlertAction actionWithTitle:actionTitle
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
            if (handler) {
                handler(index);
            }
        }]];
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil]];

    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover) {
        popover.sourceView = sourceView ?: controller.view;
        popover.sourceRect = sourceView ? sourceView.bounds : controller.view.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (void)presentAlertWithTitle:(NSString *)title
                       message:(NSString *)message
                   cancelTitle:(NSString *)cancelTitle
                  confirmTitle:(NSString *)confirmTitle
                       handler:(void (^)(BOOL confirmed))handler {
    [self presentAlertWithTitle:title
                       message:message
                   cancelTitle:cancelTitle
                  confirmTitle:confirmTitle
                    sourceView:nil
                       handler:handler];
}

+ (void)presentAlertWithTitle:(NSString *)title
                       message:(NSString *)message
                   cancelTitle:(NSString *)cancelTitle
                  confirmTitle:(NSString *)confirmTitle
                    sourceView:(UIView *)sourceView
                       handler:(void (^)(BOOL confirmed))handler {
    UIViewController *controller = [self topControllerForView:sourceView];
    if (!controller) {
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                message:message
                                                                         preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
        if (handler) {
            handler(NO);
        }
    }]];
    if (confirmTitle.length > 0) {
        [alertController addAction:[UIAlertAction actionWithTitle:confirmTitle
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
            if (handler) {
                handler(YES);
            }
        }]];
    }
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (BOOL)isNormalAppWindow:(UIWindow *)window {
    return [window isKindOfClass:[UIWindow class]] &&
           !window.hidden &&
           window.windowLevel == UIWindowLevelNormal;
}

+ (UIViewController *)visibleControllerFromController:(UIViewController *)controller {
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)controller;
        return [self visibleControllerFromController:navigationController.visibleViewController];
    }

    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)controller;
        return [self visibleControllerFromController:tabBarController.selectedViewController];
    }

    if (controller.presentedViewController) {
        return [self visibleControllerFromController:controller.presentedViewController];
    }

    return controller;
}

+ (NSArray<UIWindow *> *)candidateWindows {
    NSMutableArray<UIWindow *> *windows = [NSMutableArray array];
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.activationState != UISceneActivationStateForegroundActive) {
                continue;
            }
            [windows addObjectsFromArray:windowScene.windows];
        }
    }

    if (windows.count == 0) {
        [windows addObjectsFromArray:[UIApplication sharedApplication].windows];
    }

    return windows;
}

+ (UIWindow *)currentWindow {
    NSArray<UIWindow *> *windows = [self candidateWindows];

    if (MQPreferredWindow && [windows containsObject:MQPreferredWindow] && [self isNormalAppWindow:MQPreferredWindow]) {
        return MQPreferredWindow;
    }

    for (UIWindow *window in [windows reverseObjectEnumerator]) {
        if (window.isKeyWindow && [self isNormalAppWindow:window]) {
            return window;
        }
    }

    for (UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([self isNormalAppWindow:window]) {
            return window;
        }
    }

    for (UIWindow *window in [windows reverseObjectEnumerator]) {
        if (window.isKeyWindow) {
            return window;
        }
    }

    return windows.lastObject;
}

+ (UIWindow *)currentWindowForView:(UIView *)view {
    UIWindow *window = view.window;
    if (window && [self isNormalAppWindow:window]) {
        MQPreferredWindow = window;
        return window;
    }
    return [self currentWindow];
}

+ (NSArray<UIWindow *> *)currentWindows {
    return [self candidateWindows];
}

+ (UIViewController *)topController {
    UIWindow *window = [self currentWindow];
    return [self visibleControllerFromController:window.rootViewController];
}

+ (UIViewController *)topControllerForView:(UIView *)view {
    UIWindow *window = [self currentWindowForView:view];
    return [self visibleControllerFromController:window.rootViewController];
}

+ (CGRect)statusBarFrame {
    if (@available(iOS 13.0, *)) {
        UIStatusBarManager *statusBarManager = [self currentWindow].windowScene.statusBarManager;
        return statusBarManager.statusBarFrame;
    }
    return [UIApplication sharedApplication].statusBarFrame;
}

@end
