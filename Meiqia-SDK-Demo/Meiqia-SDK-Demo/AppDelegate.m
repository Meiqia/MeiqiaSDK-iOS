//
//  AppDelegate.m
//  MQEcoboostSDK-test
//
//  Created by ijinmao on 15/11/11.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "AppDelegate.h"
#import <MeiQiaSDK/MQManager.h>
#import "MQServiceToViewInterface.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //推送注册
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert
                                                | UIUserNotificationTypeBadge
                                                | UIUserNotificationTypeSound
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
#else
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
#endif

#pragma mark  集成第一步: 初始化,  参数:appkey
    [MQManager initWithAppkey:@"" completion:^(NSString *clientId, NSError *error) {

        if (!error) {
            // 这里可以开启SDK的群发功能, 注意需要在SDK初始化成功以后调用
            //[[MQNotificationManager sharedManager] openMQGroupNotificationServer];
            NSLog(@"美洽 SDK：初始化成功");
        } else {
            NSLog(@"error:%@",error);
        }

    }];
    
    return YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    #pragma mark  集成第二步: 进入前台 打开meiqia服务
    [MQManager openMeiqiaService];
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    #pragma mark  集成第三步: 进入后台 关闭美洽服务
    [MQManager closeMeiqiaService];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    #pragma mark  集成第四步: 上传设备deviceToken
    [MQManager registerDeviceToken:deviceToken];
    
    /*  swift 项目这样处理
     let devicetokenStr = (NSData.init(data: deviceToken).description as NSString).trimmingCharacters(in: NSCharacterSet(charactersIn: "<>") as CharacterSet).replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
     MQManager.registerDeviceTokenString(devicetokenStr)
     */
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


@end
