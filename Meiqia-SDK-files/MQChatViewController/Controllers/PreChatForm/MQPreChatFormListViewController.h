//
//  MQPreAdviseFormListViewController.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MQChatViewConfig;
@interface MQPreChatFormListViewController : UITableViewController

@property (nonatomic, weak) MQChatViewConfig *config;


+ (MQPreChatFormListViewController *)usePreChatFormIfNeededOnViewController:(UIViewController *)controller compeletion:(void(^)(void))block;


@end
