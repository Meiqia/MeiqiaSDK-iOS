//
//  MQMessageFormCategoryViewController.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/10/10.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQMessageFormCategoryViewController : UITableViewController

@property (nonatomic, copy) void(^categorySelected)(NSString *categoryId);

- (void)showIfNeededOn:(UIViewController *)controller;

@end
