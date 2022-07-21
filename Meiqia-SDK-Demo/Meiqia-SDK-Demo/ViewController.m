//
//  ViewController.m
//  Meiqia-SDK-Demo
//
//  Created by xulianpeng on 2017/12/18.
//  Copyright © 2017年 Meiqia. All rights reserved.
//

#import "ViewController.h"
#import "MQChatViewManager.h"
#import "MQChatDeviceUtil.h"
#import "DevelopViewController.h"
#import <MeiQiaSDK/MeiqiaSDK.h>
#import "NSArray+MQFunctional.h"
#import "MQBundleUtil.h"
#import "MQAssetUtil.h"
#import "MQImageUtil.h"
#import "MQToast.h"

#import "MQMessageFormInputModel.h"
#import "MQMessageFormViewManager.h"

#import <MeiQiaSDK/MQManager.h>
@interface ViewController ()
@property (nonatomic, strong) NSNumber *unreadMessagesCount;

@end
static CGFloat const kMQButtonVerticalSpacing   = 16.0;
static CGFloat const kMQButtonHeight            = 42.0;
static CGFloat const kMQButtonToBottomSpacing   = 128.0;
@implementation ViewController{
    UIImageView *appIconImageView;
    UIButton *basicFunctionBtn;
    UIButton *devFunctionBtn;
    CGRect deviceFrame;
    CGFloat buttonWidth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    deviceFrame = [MQChatDeviceUtil getDeviceFrameRect:self];
    buttonWidth = deviceFrame.size.width / 2;
    self.navigationItem.title = @"美洽 SDK";
    
    [self initAppIcon];
    [self initFunctionButtons];
}
#pragma mark  集成第五步: 跳转到聊天界面

- (void)pushToMeiqiaVC:(UIButton *)button {
#pragma mark 总之, 要自定义UI层  请参考 MQChatViewStyle.h类中的相关的方法 ,要修改逻辑相关的 请参考MQChatViewManager.h中相关的方法
    
#pragma mark  最简单的集成方法: 全部使用meiqia的,  不做任何自定义UI.
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager pushMQChatViewControllerInViewController:self];
//
#pragma mark  觉得返回按钮系统的太丑 想自定义 采用下面的方法
//    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
//    MQChatViewStyle *aStyle = [chatViewManager chatViewStyle];
////    [aStyle setNavBarTintColor:[UIColor blueColor]];
//    [aStyle setNavBackButtonImage:[UIImage imageNamed:@"meiqia-icon"]];
//    [chatViewManager pushMQChatViewControllerInViewController:self];
#pragma mark 觉得头像 方形不好看 ,设置为圆形.
//    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
//    MQChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    [aStyle setEnableRoundAvatar:YES];
//    [aStyle setEnableOutgoingAvatar:NO]; //不显示用户头像
//    [aStyle setEnableIncomingAvatar:NO]; //不显示客服头像
//    [chatViewManager pushMQChatViewControllerInViewController:self];
#pragma mark 导航栏 右按钮 想自定义 ,但是不到万不得已,不推荐使用这个,会造成meiqia功能的缺失,因为这个按钮 1 当你在工作台打开机器人开关后 显示转人工,点击转为人工客服. 2在人工客服时 还可以评价客服
//    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
//    MQChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
//    [bt setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//    [aStyle setNavBarRightButton:bt];
//    [chatViewManager pushMQChatViewControllerInViewController:self];
#pragma mark 客户自定义信息
//    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
//    [chatViewManager setClientInfo:@{@"name":@"美洽测试777",@"gender":@"woman22",@"age":@"400",@"address":@"北京昌平回龙观"} override:YES];
//    [chatViewManager setClientInfo:@{@"name":@"123测试123",@"gender":@"man11",@"age":@"100"}];
//    [chatViewManager setLoginCustomizedId:@"12313812381263786786123698"];
//    [chatViewManager pushMQChatViewControllerInViewController:self];

#pragma mark 预发送消息
//    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
//    //    [chatViewManager setPreSendMessages: @[@"我想咨询的订单号：【1705045496811】"]];
//    //     发送商品卡片
//    MQProductCardMessage *productCard = [[MQProductCardMessage alloc] initWithPictureUrl:@"https://file.pisen.com.cn/QJW3C1000WEB/Product/201701/16305409655404.jpg" title:@"商品的title" description:@"这件商品的描述内容，想怎么写就怎么写，哎呦，就是这么嗨！！！！" productUrl:@"https://meiqia.com" andSalesCount:100];
//    [chatViewManager setPreSendMessages: @[productCard]];
//    // 自定义商品卡片响应事件
//    [chatViewManager didTapProductCard:^(NSString *productUrl) {
//        NSLog(@"点击商品卡片的链接：%@",productUrl);
//    }];
//    [chatViewManager pushMQChatViewControllerInViewController:self];
    
#pragma mark 如果你想绑定自己的用户系统 ,当然推荐你使用 客户自定义信息来绑定用户的相关个人信息
#pragma mark 切记切记切记  一定要确保 customId 是唯一的,这样保证  customId和meiqia生成的用户ID是一对一的
//    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
//    NSString *customId = @"获取你们自己的用户ID 或 其他唯一标识的";
//    if (customId){
//        [chatViewManager setLoginCustomizedId:customId];
//    }else{
//   #pragma mark 切记切记切记 下面这一行是错误的写法 , 这样会导致 ID = "notadda" 和 meiqia多个用户绑定,最终导致 对话内容错乱 A客户能看到 B C D的客户的对话内容
//        //[chatViewManager setLoginCustomizedId:@"notadda"];
//    }
//    [chatViewManager pushMQChatViewControllerInViewController:self];
#pragma mark 留言模式 适用于 刚起步,人工客服成本没有,只能留言.
//    [self feedback];
}

- (void)feedback
{
    MQMessageFormViewManager *messageFormViewManager = [[MQMessageFormViewManager alloc] init];
    
    MQMessageFormViewStyle *style = [messageFormViewManager messageFormViewStyle];
    style.navBarColor = [UIColor whiteColor];
    [messageFormViewManager presentMQMessageFormViewControllerInViewController:self];
}
#pragma 开发者的高级功能 其中有调用美洽SDK的API接口
- (void)didTapDevFunctionBtn:(UIButton *)button {
    //开发者功能
    DevelopViewController *viewController = [[DevelopViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
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
    [basicFunctionBtn addTarget:self action:@selector(pushToMeiqiaVC:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
