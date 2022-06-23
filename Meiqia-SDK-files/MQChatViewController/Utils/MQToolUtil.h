//
//  MQToolUtil.h
//  Meiqia-SDK-Demo
//
//  Created by xulianpeng on 2017/10/26.
//  Copyright © 2017年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MQToolUtil : NSObject
+ (NSString*)kMQObtainDeviceVersion;
+ (BOOL)kMQObtainDeviceVersionIsIphoneX;
+ (CGFloat)kMQObtainNaviBarHeight;
+ (CGFloat)kMQObtainStatusBarHeight;
+ (CGFloat)kMQObtainNaviHeight;
+ (CGFloat)kMQScreenWidth;
+ (CGFloat)kMQScreenHeight;
@end
