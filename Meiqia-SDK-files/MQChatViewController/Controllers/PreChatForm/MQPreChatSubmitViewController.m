//
//  MQAdviseFormSubmitViewController.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQPreChatSubmitViewController.h"
#import "MQPreChatFormViewModel.h"
#import "UIView+MQLayout.h"
#import "NSArray+MQFunctional.h"
#import "MQPreChatCells.h"
#import "MQToast.h"
#import "MQAssetUtil.h"

#pragma mark -
#pragma mark -

#define HEIGHT_SECTION_HEADER 40

@interface MQPreChatSubmitViewController ()

@property (nonatomic, strong) MQPreChatFormViewModel *viewModel;

@end

@implementation MQPreChatSubmitViewController

- (instancetype)init {
    if (self = [super initWithStyle:(UITableViewStyleGrouped)]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.navigationController.viewControllers firstObject] == self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[MQAssetUtil backArrow] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    }
    
    self.title = @"请填写以下问题";
    
    self.viewModel = [MQPreChatFormViewModel new];
    self.viewModel.formData = self.formData;

    self.tableView.allowsMultipleSelection = YES;
    
    if (self.viewModel.formData.form.title.length > 0) {
        self.title = self.viewModel.formData.form.title;
    }
    
    [self.tableView registerClass:[MQPreChatMultiLineTextCell class] forCellReuseIdentifier:NSStringFromClass([MQPreChatMultiLineTextCell class])];
    [self.tableView registerClass:[MQPrechatSingleLineTextCell class] forCellReuseIdentifier:NSStringFromClass([MQPrechatSingleLineTextCell class])];
    [self.tableView registerClass:[MQPreChatSelectionCell class] forCellReuseIdentifier:NSStringFromClass([MQPreChatSelectionCell class])];
    [self.tableView registerClass:[MQPreChatCaptchaCell class] forCellReuseIdentifier:NSStringFromClass([MQPreChatCaptchaCell class])];
    [self.tableView registerClass:[MQPreChatSectionHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([MQPreChatSectionHeaderView class])];
    
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:(UIBarButtonItemStylePlain) target:self action:@selector(submitAction)];
    self.navigationItem.rightBarButtonItem = submit;
}

- (void)dismiss {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    MQPreChatSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([MQPreChatSectionHeaderView class])];
    
    header.viewSize = CGSizeMake(tableView.viewWidth, HEIGHT_SECTION_HEADER);
    header.viewOrigin = CGPointZero;
    header.formItem = self.viewModel.formData.form.formItems[section];
    
    return header;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEIGHT_SECTION_HEADER;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1; //means hide it
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MQPreChatFormItem *formItem = (MQPreChatFormItem *)self.viewModel.formData.form.formItems[indexPath.section];
    
    UITableViewCell *cell;
    __weak typeof(self) wself = self;
    switch (formItem.type) {
        case MQPreChatFormItemInputTypeSingleLineText:
        {
            MQPrechatSingleLineTextCell *scell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(MQPrechatSingleLineTextCell.class) forIndexPath:indexPath];
            scell.textField.keyboardType = [self.viewModel keyboardtypeForType:formItem.filedName];
            //记录用户输入
            [scell setValueChangedAction:^(NSString *newString) {
                __strong typeof (wself) sself = wself;
                [sself.viewModel setValue:newString forFieldIndex:indexPath.section];
            }];
            scell.textField.text = [self.viewModel valueForFieldIndex:indexPath.section];
            cell = scell;
            break;
        }
        case MQPreCHatFormItemInputTypeMultipleLineText:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(MQPreChatMultiLineTextCell.class) forIndexPath:indexPath];
            break;
        case MQPreChatFormItemInputTypeSingleSelection:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(MQPreChatSelectionCell.class) forIndexPath:indexPath];
            cell.textLabel.text = formItem.choices[indexPath.row];
            [cell setSelected:([cell.textLabel.text isEqualToString:[self.viewModel valueForFieldIndex:indexPath.section]]) animated:NO];
            break;
        case MQPreChatFormItemInputTypeMultipleSelection:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(MQPreChatSelectionCell.class) forIndexPath:indexPath];
            cell.textLabel.text = formItem.choices[indexPath.row];
            
            if ([[self.viewModel valueForFieldIndex:indexPath.section] respondsToSelector:@selector(containsObject:)]) {
                [cell setSelected:[[self.viewModel valueForFieldIndex:indexPath.section] containsObject:cell.textLabel.text] animated:NO];
            }
            break;
        case MQPreChatFormItemInputTypeCaptcha:{
            MQPreChatCaptchaCell *ccell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(MQPreChatCaptchaCell.class) forIndexPath:indexPath];
            ccell.textField.text = [self.viewModel valueForFieldIndex:indexPath.section];
            //刷新验证码
            ccell.loadCaptchaAction = ^(UIButton *button){
                __strong typeof (wself) sself = wself;
                [sself.viewModel requestCaptchaComplete:^(UIImage *image) {
                    [button setImage:image forState:(UIControlStateNormal)];
                }];
            };
            
            //记录用户输入
            [ccell setValueChangedAction:^(NSString *newString) {
                __strong typeof (wself) sself = wself;
                [sself.viewModel setValue:newString forFieldIndex:indexPath.section];
            }];
            
            //cell 第一次出现后自动加载图片
            if ([self.viewModel.captchaToken length] == 0) {
                [self.viewModel requestCaptchaComplete:^(UIImage *image) {
                    [ccell.refreshCapchaButton setImage:image forState:UIControlStateNormal];
                }];
            }
            
            cell = ccell;
        }
            break;
    }
    
    
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.tableView endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.viewModel.formData.form.formItems[section] choices] count] ?: 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView endEditing:YES];
    
    MQPreChatFormItem *formItem = (MQPreChatFormItem *)self.viewModel.formData.form.formItems[indexPath.section];
    
    if (formItem.type == MQPreChatFormItemInputTypeSingleSelection) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:(UITableViewScrollPositionNone)];
        [self.viewModel setValue:formItem.choices[indexPath.row] forFieldIndex:indexPath.section];
    }else if (formItem.type == MQPreChatFormItemInputTypeMultipleSelection) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:(UITableViewScrollPositionNone)];
        
        NSArray *selectedRowsInCurrentSection = [[[tableView indexPathsForSelectedRows] filter:^BOOL(NSIndexPath *i) {
            return i.section == indexPath.section;
        }] map:^id(NSIndexPath *i) {
            return formItem.choices[i.row];
        }];
        [self.viewModel setValue:selectedRowsInCurrentSection forFieldIndex:indexPath.section];
    }
    
    if (formItem.type != MQPreChatFormItemInputTypeMultipleSelection) {
        for (int i = 0; i < [[formItem choices] count]; i++) {
            if (i != indexPath.row) {
                [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section] animated:NO];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView endEditing:YES];
    
    NSArray *selectedRowsInCurrentSection = [[[tableView indexPathsForSelectedRows] filter:^BOOL(NSIndexPath *i) {
        return i.section == indexPath.section;
    }] map:^id(NSIndexPath *i) {
        return @(i.row);
    }];
    [self.viewModel setValue:selectedRowsInCurrentSection.count > 0 ? selectedRowsInCurrentSection : nil forFieldIndex:indexPath.section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.formData.form.formItems.count;
}

- (void)submitAction {
    __weak typeof(self) wself = self;
    
    [self showLoadingIndicator];
    NSArray *unsatisfiedSectionIndexs = [self.viewModel submitFormCompletion:^(id response, NSError *e) {
        __strong typeof (wself) sself = wself;
        [sself hideLoadingIndicator];
        if (e == nil) {
            [sself dismissViewControllerAnimated:YES completion:^{
                if (sself.completeBlock) {
                    sself.completeBlock([sself createUserInfo]);
                }
            }];
        } else {
            if (e.code != 1) {
                [self resetCaptchaCellIfExists];
            }
            
            [MQToast showToast:e.domain duration:2 window:[[UIApplication sharedApplication].windows lastObject]];
        }
    }];
    
    for (int i = 0; i < self.viewModel.formData.form.formItems.count; i ++) {
        MQPreChatSectionHeaderView *header = (MQPreChatSectionHeaderView *)[self.tableView headerViewForSection:i];
        [header setStatus:![unsatisfiedSectionIndexs containsObject:@(i)]];
    }
}

static UIBarButtonItem *rightBarButtonItemCache = nil;

- (void)showLoadingIndicator {
    [self.view endEditing:true];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    rightBarButtonItemCache = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:indicator];
    [indicator startAnimating];
}

- (void)hideLoadingIndicator {
    self.navigationItem.rightBarButtonItem = rightBarButtonItemCache;
}

- (void)resetCaptchaCellIfExists {
    if (self.viewModel.formData.isUseCapcha) {
        [self.viewModel requestCaptchaComplete:^(UIImage *image) {
            MQPreChatCaptchaCell *captchaCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.viewModel.formData.form.formItems.count - 1]];
            if ([captchaCell isKindOfClass:[MQPreChatCaptchaCell class]]) {
                captchaCell.textField.text = @"";
                [self.viewModel setValue:nil forFieldIndex:self.viewModel.formData.form.formItems.count - 1];
                [captchaCell.refreshCapchaButton setImage:image forState:UIControlStateNormal];
            }
        }];
    }
}

//
- (NSDictionary *)createUserInfo {
    if (self.selectedMenuItem) {
        NSString *target = self.selectedMenuItem.target;
        NSString *targetType = self.selectedMenuItem.targetKind;
        
        return @{@"target":target, @"targetType":targetType, @"menu":[self.selectedMenuItem desc]};
    } else {
        return nil;
    }
}


@end
