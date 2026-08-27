//
//  MQWindowUtil.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/15.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MQWindowUtil : NSObject

+ (void)presentActionSheetWithTitle:(NSString *)title
                       actionTitles:(NSArray<NSString *> *)actionTitles
                        cancelTitle:(NSString *)cancelTitle
                         sourceView:(UIView *)sourceView
                            handler:(void (^)(NSInteger index))handler;
+ (void)presentAlertWithTitle:(NSString *)title
                       message:(NSString *)message
                   cancelTitle:(NSString *)cancelTitle
                  confirmTitle:(NSString *)confirmTitle
                       handler:(void (^)(BOOL confirmed))handler;
+ (void)presentAlertWithTitle:(NSString *)title
                       message:(NSString *)message
                   cancelTitle:(NSString *)cancelTitle
                  confirmTitle:(NSString *)confirmTitle
                    sourceView:(UIView *)sourceView
                       handler:(void (^)(BOOL confirmed))handler;
+ (UIWindow *)currentWindow;
+ (UIWindow *)currentWindowForView:(UIView *)view;
+ (NSArray<UIWindow *> *)currentWindows;
+ (UIViewController *)topController;
+ (UIViewController *)topControllerForView:(UIView *)view;
+ (CGRect)statusBarFrame;

@end
