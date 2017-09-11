//
//  MQMessageFormCategoryViewController.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/10/10.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQMessageFormCategoryViewController.h"
#import "UIView+MQLayout.h"
#import "UIColor+MQHex.h"
#import "MQChatViewStyle.h"
#import <MeiQiaSDK/MQTicket.h>
#import "MQServiceToViewInterface.h"

@interface MQMessageFormCategoryViewController()

@property (nonatomic, strong) NSArray *categories;

@end

@implementation MQMessageFormCategoryViewController

- (void)showIfNeededOn:(UIViewController *)controller {
    [MQServiceToViewInterface getTicketCategoryComplete:^(NSArray *categories) {
        if ([categories count] > 0) {
            self.categories = categories;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
            [controller presentViewController:nav animated:YES completion:nil];
        }
    }];
}

- (void)viewDidLoad {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemCancel) target:self action:@selector(dismiss)];
    self.tableView.tableFooterView = [UIView new];
    self.title = @"选择留言分类";
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
        
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithHexString:ebonyClay];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [self.categories[indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.categorySelected) {
        self.categorySelected([[self.categories[indexPath.row] id] stringValue]);
    }
    [self dismiss];
}

@end
