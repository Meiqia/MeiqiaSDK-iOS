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
#import <MeiQiaSDK/MeiQiaSDK.h>
#import "NSArray+MQFunctional.h"

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
    
//    [[UINavigationBar appearance] setTranslucent:YES];
    
//    self.navigationController.navigationBar.translucent = NO;
    
//    [[UINavigationBar appearance] setTranslucent:NO];
    
//    [self.navigationController setNavigationBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onlineSuccessed) name:MQ_CLIENT_ONLINE_SUCCESS_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadMessageCount) name:MQ_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil];
    
    id obj = @{@"1":[NSNull null]};
    [JSONHelper JSONStringWith:obj];
    NSLog(@">>> %@",obj[@"1"][@""]);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)onlineSuccessed {
//    [MQManager sendTextMessageWithContent:@"text" completion:nil];
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

- (void)updateUnreadMessageCount {
    [MQServiceToViewInterface getUnreadMessagesWithCompletion:^(NSArray *messages, NSError *error) {
        
        NSUInteger count = [[messages filter:^BOOL(MQMessage *message) {
            return message.fromType != MQMessageFromTypeClient;
        }] count];
        
        NSLog(@"unreade message count: %lu",(unsigned long)count);
    }];
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
    [chatViewManager.chatViewStyle setEnableRoundAvatar:YES];

    [chatViewManager setClientInfo:@{@"name":@"my name 2", @"tel":@1340000000011}];
    [chatViewManager pushMQChatViewControllerInViewController:self];
//    [chatViewManager setLoginCustomizedId:[NSUUID UUID].UUIDString];
//    [chatViewManager setLoginMQClientId:@"87b01b6c295211e688ed06904f27bcff"];
    [chatViewManager setScheduledAgentId:@"e6c87ec5966e357448145c80f8f5ba41"];
    [chatViewManager setScheduleLogicWithRule:MQChatScheduleRulesRedirectNone];
    [chatViewManager.chatViewStyle setEnableOutgoingAvatar:YES];
    
    [self removeIndecatorForView:basicFunctionBtn];
    
    [chatViewManager setRecordMode:MQRecordModeDuckOther];
    [chatViewManager setPlayMode:MQPlayModeMixWithOther];
    
}

#pragma 开发者的高级功能，其中有调用美洽SDK的API接口
- (void)didTapDevFunctionBtn:(UIButton *)button {
    //开发者功能
    DevelopViewController *viewController = [[DevelopViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}



@end
