//
//  ViewController.m
//  MQEcoboostSDK-test
//
//  Created by ijinmao on 15/11/11.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "ViewController.h"
#import "MQChatViewManager.h"
#import "MQChatDeviceUtil.h"
#import "DevelopViewController.h"
#import <MeiQiaSDK/MQManager.h>

static CGFloat const kMQButtonVerticalSpacing   = 16.0;
static CGFloat const kMQButtonHeight            = 42.0;
static CGFloat const kMQButtonToBottomSpacing   = 128.0;

@interface ViewController ()

@property (nonatomic, strong) NSNumber *unreadMessagesCount;

@end

@implementation ViewController {
    UIImageView *appIconImageView;
    UIButton *basicFunctionBtn;
    UIButton *devFunctionBtn;
    CGRect deviceFrame;
    CGFloat buttonWidth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    deviceFrame = [MQChatDeviceUtil getDeviceFrameRect:self];
    buttonWidth = deviceFrame.size.width / 2;
    self.navigationItem.title = @"美洽 SDK";

    [self initAppIcon];
    [self initFunctionButtons];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateIndicator) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)updateIndicator {
    if ([DevelopViewController shouldShowUnreadMessageCount]) {
        [MQServiceToViewInterface getUnreadMessagesWithCompletion:^(NSArray *messages, NSError *error) {
            self.unreadMessagesCount = @(messages.count);
            
            if (self.unreadMessagesCount.intValue > 0) {
                [self showIndicatorWithNumber:self.unreadMessagesCount onView:basicFunctionBtn];
            } else {
                [self removeIndecatorForView:basicFunctionBtn];
            }
        }];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initAppIcon {
    CGFloat imageWidth = deviceFrame.size.width / 4;
    appIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"meiqia-icon"]];
    appIconImageView.frame = CGRectMake(deviceFrame.size.width/2 - imageWidth/2, deviceFrame.size.height / 4, imageWidth, imageWidth);
    appIconImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:appIconImageView];
}

- (void)initFunctionButtons {
    devFunctionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    devFunctionBtn.frame = CGRectMake(deviceFrame.size.width/2 - buttonWidth/2, deviceFrame.size.height - kMQButtonToBottomSpacing, buttonWidth, kMQButtonHeight);
    devFunctionBtn.backgroundColor = [UIColor colorWithRed:23 / 255.0 green:199 / 255.0 blue:209 / 255.0 alpha:1];
    [devFunctionBtn setTitle:@"开发者功能" forState:UIControlStateNormal];
    [devFunctionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:devFunctionBtn];
    
    basicFunctionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    basicFunctionBtn.frame = CGRectMake(devFunctionBtn.frame.origin.x, devFunctionBtn.frame.origin.y - kMQButtonVerticalSpacing - kMQButtonHeight, buttonWidth, kMQButtonHeight);
    basicFunctionBtn.backgroundColor = devFunctionBtn.backgroundColor;
    [basicFunctionBtn setTitle:@"在线客服" forState:UIControlStateNormal];
    [basicFunctionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:basicFunctionBtn];
    
    [devFunctionBtn addTarget:self action:@selector(didTapDevFunctionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [basicFunctionBtn addTarget:self action:@selector(didTapBasicFunctionBtn:) forControlEvents:UIControlEventTouchUpInside];
    
}

static int indicator_tag = 10;
- (void)showIndicatorWithNumber:(NSNumber *)number onView:(UIView *)view {
    UILabel *indicator = [[UILabel alloc] initWithFrame:CGRectMake(view.bounds.size.width - 10, -10, 20, 20)];
    indicator.tag = indicator_tag;
    indicator.backgroundColor = [UIColor redColor];
    indicator.layer.cornerRadius = 10;
    indicator.font = [UIFont systemFontOfSize:9];
    indicator.textAlignment = NSTextAlignmentCenter;
    indicator.layer.masksToBounds = YES;
    indicator.text = number.stringValue;
    indicator.textColor = [UIColor whiteColor];
    [view addSubview:indicator];
}

- (void)removeIndecatorForView:(UIView *)view {
    UIView *v = [view viewWithTag:indicator_tag];
    if (v) {
        [v removeFromSuperview];
    }
}

#pragma 最基本功能
- (void)didTapBasicFunctionBtn:(UIButton *)button {
    //基本功能 - 在线客服
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager.chatViewStyle setEnableOutgoingAvatar:false];
    [chatViewManager pushMQChatViewControllerInViewController:self];
//    [chatViewManager presentMQChatViewControllerInViewController:self];
    [self removeIndecatorForView:basicFunctionBtn];
}

#pragma 开发者的高级功能，其中有调用美洽SDK的API接口
- (void)didTapDevFunctionBtn:(UIButton *)button {
    //开发者功能
    DevelopViewController *viewController = [[DevelopViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}



@end
