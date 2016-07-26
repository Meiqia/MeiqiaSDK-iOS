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

+ (MQPreChatFormListViewController *)usePreChatFormIfNeededOnViewController:(UIViewController *)controller compeletion:(void(^)(NSDictionary *userInfo))block cancle:(void(^)(void))cancelBlock;


@end
