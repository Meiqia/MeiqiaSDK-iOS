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
#import "MQPreChatTopView.h"

@interface MQPreChatFormListViewController ()

@property (nonatomic, strong) MQPreChatFormViewModel *viewModel;
@property (nonatomic, copy) void(^completeBlock)(NSDictionary *userInfo);
@property (nonatomic, copy) void(^cancelBlock)(void);

@property (nonatomic, strong) UIView *cacheHeaderView;

@end

@implementation MQPreChatFormListViewController

+ (MQPreChatFormListViewController *)usePreChatFormIfNeededOnViewController:(UIViewController *)controller compeletion:(void(^)(NSDictionary *userInfo))block cancle:(void(^)(void))cancelBlock {
    
    MQPreChatFormListViewController *preChatViewController = [MQPreChatFormListViewController new];
    preChatViewController.completeBlock = block;
    preChatViewController.cancelBlock = cancelBlock;
    
    __weak typeof(controller) weakController = controller;
    [preChatViewController.viewModel requestPreChatServeyDataIfNeed:^(MQPreChatData *data, NSError *error) {
        if (data && (data.form.formItems.count + data.menu.menuItems.count) > 0) {
            UINavigationController *nav;
            if ([data.menu.status isEqualToString:@"close"] || data.menu.menuItems.count == 0) {
                if (data.form.formItems.count > 0 && ![data.form.status isEqualToString:@"close"]) {
                    if (data.form.formItems.count == 1) {
                        MQPreChatFormItem *item = data.form.formItems.firstObject;
                        if ([item isKindOfClass: MQPreChatFormItem.class] && [item.displayName isEqual: @"验证码"]) {
                            // 单独只有一个验证码时直接跳过询前表单步骤
                            if (block) {
                                block(nil);
                            }
                        } else {
                            MQPreChatSubmitViewController *submitViewController = [MQPreChatSubmitViewController new];
                            submitViewController.formData = data;
                            submitViewController.completeBlock = block;
                            submitViewController.cancelBlock = cancelBlock;
                            nav = [[UINavigationController alloc] initWithRootViewController:submitViewController];
                        }
                    } else {
                        MQPreChatSubmitViewController *submitViewController = [MQPreChatSubmitViewController new];
                        submitViewController.formData = data;
                        submitViewController.completeBlock = block;
                        submitViewController.cancelBlock = cancelBlock;
                        nav = [[UINavigationController alloc] initWithRootViewController:submitViewController];
                    }
                } else {
                    if (block) {
                        block(nil);
                    }
                }
            } else {
                nav = [[UINavigationController alloc] initWithRootViewController:preChatViewController];
            }
            
            nav.navigationBar.barTintColor = weakController.navigationController.navigationBar.barTintColor;
            nav.navigationBar.tintColor = weakController.navigationController.navigationBar.tintColor;
            if (nav) {
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [weakController presentViewController:nav animated:YES completion:nil];
            } else {
                if (block) {
                    block(nil);
                }
            }
        } else {
            if (block) {
                block(nil);
            }
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

- (CGFloat)getHeaderMaxWidth {
    return self.tableView.viewWidth - 2 * kMQPreChatHeaderHorizontalSpacing;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.cacheHeaderView.viewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return self.cacheHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.formData.menu.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor mq_colorWithHexString:ebonyClay];
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
        MQPreChatFormItem *item = self.viewModel.formData.form.formItems.count > 0 ? self.viewModel.formData.form.formItems.firstObject : nil;
        if ((self.viewModel.formData.form.formItems.count == 1 && [item isKindOfClass: MQPreChatFormItem.class] && [item.displayName isEqual:@"验证码"])) {
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
}

-(UIView *)cacheHeaderView {
    if (!_cacheHeaderView) {
        MQPreChatTopView *topView;
        CGFloat topViewHeight = 0;

        if (self.viewModel.formData.content.length > 0) {
            topView = [[MQPreChatTopView alloc] initWithHTMLText:self.viewModel.formData.content maxWidth:[self getHeaderMaxWidth]];
            topViewHeight = [topView getTopViewHeight];
            topView.frame = CGRectMake(kMQPreChatHeaderHorizontalSpacing, 0, [self getHeaderMaxWidth], topViewHeight);
        }
        
        CGSize textSize = CGSizeMake([self getHeaderMaxWidth], MAXFLOAT);
        CGRect textRect = [self.viewModel.formData.menu.title boundingRectWithSize:textSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]}
                                                     context:nil];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMQPreChatHeaderHorizontalSpacing, topViewHeight + kMQPreChatHeaderBottom, [self getHeaderMaxWidth], textRect.size.height)];
        titleLabel.text = self.viewModel.formData.menu.title;
        titleLabel.textColor = [UIColor mq_colorWithHexString:ebonyClay];
        titleLabel.font = [UIFont systemFontOfSize:14];
        
        _cacheHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.viewWidth, CGRectGetMaxY(titleLabel.frame) + kMQPreChatHeaderBottom)];
        [_cacheHeaderView addSubview:topView];
        [_cacheHeaderView addSubview:titleLabel];
    }
    return _cacheHeaderView;
}

@end
