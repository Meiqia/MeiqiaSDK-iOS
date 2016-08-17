//
//  MQPreAdviseFormListViewController.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQPreChatFormListViewController.h"
#import "MQPreChatFormViewModel.h"
#import "MQBundleUtil.h"
#import "NSArray+MQFunctional.h"
#import "UIView+MQLayout.h"
#import "MQPreChatSubmitViewController.h"
#import "MQAssetUtil.h"

@interface MQPreChatFormListViewController ()

@property (nonatomic, strong) MQPreChatFormViewModel *viewModel;
@property (nonatomic, copy) void(^completeBlock)(NSDictionary *userInfo);
@property (nonatomic, copy) void(^cancelBlock)(void);

@end

@implementation MQPreChatFormListViewController

+ (MQPreChatFormListViewController *)usePreChatFormIfNeededOnViewController:(UIViewController *)controller compeletion:(void(^)(NSDictionary *userInfo))block cancle:(void(^)(void))cancelBlock {
    
    MQPreChatFormListViewController *preChatViewController = [MQPreChatFormListViewController new];
    preChatViewController.completeBlock = block;
    preChatViewController.cancelBlock = cancelBlock;
    
    [preChatViewController.viewModel requestPreChatServeyDataIfNeed:^(MQPreChatData *data, NSError *error) {
        if (data && (data.form.formItems.count + data.menu.menuItems.count) > 0) {
            UINavigationController *nav;
            if ([data.menu.status isEqualToString:@"close"] || data.menu.menuItems.count == 0) {
                MQPreChatSubmitViewController *submitViewController = [MQPreChatSubmitViewController new];
                submitViewController.formData = data;
                submitViewController.completeBlock = block;
                submitViewController.cancelBlock = cancelBlock;
                nav = [[UINavigationController alloc] initWithRootViewController:submitViewController];
            } else {
                nav = [[UINavigationController alloc] initWithRootViewController:preChatViewController];
            }
            
            nav.navigationBar.barTintColor = controller.navigationController.navigationBar.barTintColor;
            nav.navigationBar.tintColor = controller.navigationController.navigationBar.tintColor;
            [controller presentViewController:nav animated:YES completion:nil];
        } else {
            block(nil);
        }
    }];
    
    return preChatViewController;
}

- (instancetype)init {
    if (self = [super initWithStyle:(UITableViewStyleGrouped)]) {
        self.viewModel = [MQPreChatFormViewModel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithImage:[MQAssetUtil backArrow] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    self.title = [MQBundleUtil localizedStringForKey:@"pre_chat_list_title"];
}

- (void)dismiss {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.viewWidth, 40)];
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = self.viewModel.formData.menu.title;
    titleLabel.textColor = [UIColor colorWithHexString:silver];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel sizeToFit];
    [headerView addSubview:titleLabel];
    [titleLabel align:(ViewAlignmentMiddleLeft) relativeToPoint:CGPointMake(10, CGRectGetMidY(headerView.bounds))];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.formData.menu.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithHexString:ebonyClay];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [self.viewModel.formData.menu.menuItems[indexPath.row] desc];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self gotoFormViewControllerWithSelectedMenuIndexPath:indexPath animated:YES];
}

- (void)gotoFormViewControllerWithSelectedMenuIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    MQPreChatSubmitViewController *submitViewController = [MQPreChatSubmitViewController new];
    MQPreChatMenuItem *selectedMenu = self.viewModel.formData.menu.menuItems[indexPath.row];
    submitViewController.formData = self.viewModel.formData;
    submitViewController.completeBlock = self.completeBlock;
    if (indexPath) {
        submitViewController.selectedMenuItem = selectedMenu;
    }
    
    if (self.viewModel.formData.form.formItems.count == 0 || [self.viewModel.formData.form.status isEqualToString:@"close"]) {
        [self dismissViewControllerAnimated:YES completion:^{            
            if (self.completeBlock) {
                NSString *target = selectedMenu.target;
                NSString *targetType = selectedMenu.targetKind;
                self.completeBlock(@{@"target":target, @"targetType":targetType, @"menu":selectedMenu.desc});
            }
        }];
    } else {
        [self.navigationController pushViewController:submitViewController animated:animated];
    }
}
@end
