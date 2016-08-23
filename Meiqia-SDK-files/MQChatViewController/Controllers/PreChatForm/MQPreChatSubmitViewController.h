//
//  MQAdviseFormSubmitViewController.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MeiqiaSDK/MeiqiaSDK.h>
#import "MQChatViewConfig.h"

@interface MQPreChatSubmitViewController : UITableViewController

@property (nonatomic, copy) void(^completeBlock)(NSDictionary *userInfo);
@property (nonatomic, copy) void(^cancelBlock)(void);

@property (nonatomic, strong) MQPreChatData *formData;
@property (nonatomic, strong) MQPreChatMenuItem *selectedMenuItem;

@end
