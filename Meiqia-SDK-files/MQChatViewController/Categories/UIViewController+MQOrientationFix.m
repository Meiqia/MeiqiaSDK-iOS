//
//  UIViewController_Orientation.m
//  GrubbyWorm
//
//  Created by ian luo on 16/3/14.
//  Copyright © 2016年 GAME-CHINA.ORG. All rights reserved.
//

#import "UIViewController+MQOrientationFix.h"

@implementation UIViewController(MQOrientationFix)

- (BOOL)shouldAutorotate {
    return [self supportsLandscape] && [self supportsPortait];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask supportedOrientation = 0;
    if ([self supportsLandscape]) {
        supportedOrientation |= UIInterfaceOrientationMaskLandscape;
    }
    
    if ([self supportsPortait]) {
        supportedOrientation |= UIInterfaceOrientationMaskPortrait;
        supportedOrientation |= UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
    return supportedOrientation;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [UIApplication sharedApplication].statusBarOrientation;
}

#pragma mark - private

- (NSArray *)supportedOrientations {
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UISupportedInterfaceOrientations"] ?: @[@"UIInterfaceOrientationPortrait"];
}

- (BOOL)supportsPortait {
    NSArray *supportedOrientation = [self supportedOrientations];
    BOOL support = NO;
    
    if ([supportedOrientation containsObject:@"UIInterfaceOrientationPortrait"] ||
        [supportedOrientation containsObject:@"UIInterfaceOrientationPortraitUpsideDown"]) {
        support = YES;
    }
    
    return support;
}

- (BOOL)supportsLandscape {
    NSArray *supportedOrientation = [self supportedOrientations];
    BOOL support = NO;
    
    if ([supportedOrientation containsObject:@"UIInterfaceOrientationLandscapeLeft"] ||
        [supportedOrientation containsObject:@"UIInterfaceOrientationLandscapeRight"]) {
        support = YES;
    }
    
    return support;
}

@end