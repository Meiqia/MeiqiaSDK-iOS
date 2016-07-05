//
//  MQPreAdviseFormListViewController.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompleteBlock)(void);

@class MQChatViewConfig;
@interface MQPreChatFormListViewController : UITableViewController

@property (nonatomic, copy) void(^CompleteBlock)(void);

@property (nonatomic, strong) id formData;

- (MQPreChatFormListViewController *)appendPreChatWithConfig:(MQChatViewConfig *)config on:(UIView*)view completion:(CompleteBlock)block;

@end
