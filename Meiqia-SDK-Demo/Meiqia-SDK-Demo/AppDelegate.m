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
#import <CoreTelephony/CTCellularData.h>

@interface AppDelegate ()

@property (nonatomic, assign) BOOL mqRegisterState;
@property (nonatomic, strong) CTCellularData *cellularData;

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
//    [self networkPermissionMonitoring];
    [self initMeiqiaSDK];
    
    return YES;
}

#pragma mark  集成第一步: 初始化,  参数:appkey
- (void)initMeiqiaSDK {
    __weak typeof(self) weakSelf = self;
    [MQManager initWithAppkey:@"" completion:^(NSString *clientId, NSError *error) {
        if (!error) {
            weakSelf.mqRegisterState = YES;
            // 这里可以开启SDK的群发功能, 注意需要在SDK初始化成功以后调用
            //[[MQNotificationManager sharedManager] openMQGroupNotificationServer];
        } else {
            weakSelf.mqRegisterState = NO;
            NSLog(@"美洽 SDK：初始化失败:%@",error);
        }
    }];
    
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

// 处理第一次安装app，还没授权网络权限，sdk初始化失败问题
- (void)networkPermissionMonitoring {
    self.cellularData = [[CTCellularData alloc] init];
    __weak typeof(self) weakSelf = self;
    self.cellularData.cellularDataRestrictionDidUpdateNotifier=^(CTCellularDataRestrictedState state) {
        switch(state){
            case kCTCellularDataRestricted:
            case kCTCellularDataNotRestricted:
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf && !strongSelf.mqRegisterState) {
                        strongSelf.mqRegisterState = YES;
                        [strongSelf initMeiqiaSDK];
                    }
                });
            }
                break;
            default:
                break;
        }
    };
}

@end
