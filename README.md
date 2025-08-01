---
layout: docs_show
title: 移动应用 SDK for iOS
permalink: /docs/meiqia-ios-sdk/
edition: m2016
---

#MeiQiaSDK [![](https://travis-ci.org/Meiqia/MeiqiaSDK-iOS.svg?branch=master)]() [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods compatible](https://img.shields.io/cocoapods/v/Meiqia.svg)](#cocoapods) [![GitHub release](https://img.shields.io/github/release/meiqia/MeiqiaSDK-iOS.svg)](https://github.com/Meiqia/MeiqiaSDK-iOS/releases)

> 在您阅读此文档之前，我们假定您已经具备了基础的 iOS 应用开发经验，并能够理解相关基础概念。

> 请您首先把文档全部仔细阅读完毕,再进行您的开发, 如还有疑问，欢迎加入 美洽 SDK 开发 QQ 群：515344099

> *请注意，如果你是旧版 SDK 更换到新版 SDK，我们的推送数据格式统一成了 JSON 格式，具体请参见[消息推送](#三说好的推送呢)

* [一 导入美洽SDK](#一、导入美洽SDK)
* [二 开始你的集成之旅](#二开始你的集成之旅)
* [三 说好的推送呢](#三说好的推送呢)
* [四 SDK工作流程](#四SDK工作流程)
* [五 接口介绍](#五接口介绍)
* [六 美洽 API 接口介绍](#六美洽API接口介绍)
* [七 SDK中嵌入美洽SDK](#七sdk中嵌入美洽sdk)
* [八 留言表单](#八留言表单)
* [九 名词解释](#九名词解释)
* [十 常见问题](#十常见问题)
* [十一 更新日志](#十一更新日志)

>进行您的开发之前,请您一定下载我们的[官方Demo](https://github.com/Meiqia/MeiqiaSDK-iOS),参考我们的使用方法.

>'墙裂'建议开发者使用最新的版本。

- 请查看[Meiqia在Github上的网页](https://github.com/Meiqia/MeiqiaSDK-iOS/releases) ，确认最新的版本号。
- Demo开发者功能 ->点击查看当前SDK版本号
- 查看SDK中MQManager.h类中 **#define MQSDKVersion **
- pod search Meiqia(此方法由于本地pod缓存,导致获取不到最新的)

# 一、导入美洽SDK

 **推荐你使用CocoaPods导入我们的SDK,原因如下:**

- 后期 sdk更新会很方便.
- 手动更新你需要删除旧库,下载新库,再重新配置等很麻烦,且由于删除旧库时未删除干净,再迁入新库时会导致很多莫名其妙的问题. 
- CocoaPods的安装使用很简单,简书上的教程一大堆.
- Swift项目已经完美支持CocoPods

##1.1  CocoaPods 导入

在 Podfile 中加入：

```
pod 'Meiqia', '~> 3.9.26'
```
接着安装美洽 pod 即可：

```
$ pod install
```

## 1.2 手动导入美洽SDK
###1.2.1 导入到OC 项目
打开下载到本地的文件, 找到Meiqia-SDK-files文件夹下的 `MeiQiaSDK.framework` 、 `MQChatViewController` 、 `MeiqiaSDKViewInterface` 、`Notification`和 `MQMessageForm`,将这五个文件夹拷贝到新创建的工程路径下面，然后在工程目录结构中，右键选择 *Add Files to “工程名”* 。或者直接拖入 Xcode 工程目录结构中。

###1.2.2  导入到Swift 项目

* 按照上面的方法引入美洽 SDK 的文件。
* 在 Bridging Header 头文件中，‘#import <MeiQiaSDK/MQManager.h>’、'#import "MQChatViewManager.h"'。注：[如何添加 Bridging Header](http://bencoding.com/2015/04/15/adding-a-swift-bridge-header-manually/)。

###1.2.3 引入依赖库

美洽 SDK 的实现，依赖了一些系统框架，在开发应用时，要在工程里加入这些框架。开发者首先点击工程右边的工程名,然后在工程名右边依次选择 *TARGETS* -> *BuiLd Phases* -> *Link Binary With Libraries*，展开 *LinkBinary With Libraries* 后点击展开后下面的 *+* 来添加下面的依赖项:

- libsqlite3.tbd
- libicucore.tbd
- AVFoundation.framework
- CoreTelephony.framework
- SystemConfiguration.framework
- MobileCoreServices.framework
- QuickLook.framework

# 二 开始你的集成之旅
>如果导入sdk到你的工程没有问题,接下来只需5步就ok了,能满足一般的需求.

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#pragma mark  集成第一步: 初始化,  参数:appkey  ,尽可能早的初始化appkey.
    [MQManager initWithAppkey:@"" completion:^(NSString *clientId, NSError *error) {
        if (!error) {
            // 这里可以开启SDK的群发功能, 注意需要在SDK初始化成功以后调用
            // [[MQNotificationManager sharedManager] openMQGroupNotificationServer];
            NSLog(@"美洽 SDK：初始化成功");
        } else {
            NSLog(@"error:%@",error);
        }
    }];
  /*你自己的代码*/
    return YES;
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    #pragma mark  集成第二步: 进入前台 打开meiqia服务
    [MQManager openMeiqiaService];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    #pragma mark  集成第三步: 进入后台 关闭美洽服务
    [MQManager closeMeiqiaService];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    #pragma mark  集成第四步: 上传设备deviceToken
    [MQManager registerDeviceToken:deviceToken];
}

#pragma mark  集成第五步: 跳转到聊天界面(button的点击方法)
- (void)pushToMeiqiaVC:(UIButton *)button {
#pragma mark 总之, 要自定义UI层  请参考 MQChatViewStyle.h类中的相关的方法 ,要修改逻辑相关的 请参考MQChatViewManager.h中相关的方法
    
#pragma mark  最简单的集成方法: 全部使用meiqia的,  不做任何自定义UI.
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager setoutgoingDefaultAvatarImage:[UIImage imageNamed:@"meiqia-icon"]];
    [chatViewManager pushMQChatViewControllerInViewController:self];
#pragma mark  觉得返回按钮系统的太丑 想自定义 采用下面的方法
//    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
//    MQChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    [aStyle setNavBarTintColor:[UIColor redColor]];
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
//    [bt setImage:[UIImage imageNamed:@"meiqia-icon"] forState:UIControlStateNormal];
//    [aStyle setNavBarRightButton:bt];
//    [chatViewManager pushMQChatViewControllerInViewController:self];
#pragma mark 客户自定义信息
//    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
////    [chatViewManager setClientInfo:@{@"name":@"123测试",@"gender":@"man11",@"age":@"100"} override:YES];
//    [chatViewManager setClientInfo:@{@"name":@"123测试",@"gender":@"man11",@"age":@"100"}];
//    [chatViewManager pushMQChatViewControllerInViewController:self];

#pragma mark 预发送消息
//    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
//    [chatViewManager setPreSendMessages: @[@"我想咨询的订单号：【1705045496811】"]];
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
}

```

>请保证自己的集成代码和上述代码一致,请保证自己的集成代码和上述代码一致,请保证自己的集成代码和上述代码一致,重要的事情说三遍!!!

# 三 说好的推送呢

当前仅支持一种推送方案，当APP切换到后台时,美洽服务端发送消息至开发者的服务端，开发者再通过极光等第三方推送推送消息到 App，可见 [SDK 工作流程](#SDK-工作流程) 。

设置服务器地址，请使用美洽管理员帐号登录 [美洽](http://www.meiqia.com)，在「设置」 -\> 「SDK」中设置。

![设置推送地址](https://github.com/Meiqia/MeiqiaSDK-iOS/blob/master/resources/img/1667446550675.jpg)

### 推送消息数据结构

当有消息需要推送时，美洽服务器会向开发者设置的服务器地址发送推送消息，方法类型为 *POST*，数据格式为 *JSON* 。

发送的请求格式介绍：

request.header.authorization 为数据签名。

request.body 为消息数据，数据结构为：

|Key|说明|
|---|---|
|id|消息 id|
|messageId|当前对话的会话 id|
|content|消息内容|
|messageTime|发送时间|
|fromName|发送人姓名|
|deviceToken|发送对象设备的 deviceToken，格式为字符串|
|clientId|发送对象的顾客 id|
|customizedId|开发者传的自定义 id|
|contentType|消息内容类型 - text/photo/audio|
|deviceOS|设备系统|
|customizedData|开发者上传的自定义的属性|
|type|消息类型 - mesage 普通消息 / welcome 欢迎消息 / ending 结束消息 / remark 评价消息 / 留言消息|

开发者可以根据请求中的签名，对推送消息进行数据验证，美洽提供了 `Java、Python、Ruby、JavaScript、PHP` 5种语言的计算签名的代码，具体请移步 [美洽 SDK 3.0 推送的数据结构签名算法](https://github.com/Meiqia/MeiqiaSDK-Push-Signature-Example)。

#至此,集成结束.


# 四  SDK 工作流程

美洽 SDK 的工作流程如下图所示。

![SDK工作流程图](https://github.com/Meiqia/MeiqiaSDK-iOS/blob/master/resources/img/SDK-FlowChart1202335.png)


**注意：**
* 如果开发者对美洽的开源界面进行了定制，最好 Fork 一份 github 上的代码。这以后美洽对开源界面进行了更新，开发者只需 merge 美洽的代码，就可以免去定制后更新的麻烦。



# 五 接口介绍

##初始化sdk
所有操作都必须在初始化 SDK ，并且美洽服务端返回可用的 clientId 后才能正常执行。

开发者在美洽工作台注册 App 后，可获取到一个可用的 AppKey。在 `AppDelegate.m` 的系统回调 `didFinishLaunchingWithOptions` 中调用初始化 SDK 接口：

```objc
[MQManager initWithAppkey:@"开发者注册的App的AppKey" completion:^(NSString *clientId, NSError *error) {
}];
```

如果您不知道 *AppKey* ，请使用美洽管理员帐号登录 [美洽](http://www.meiqia.com)，在「设置」 -> 「SDK」 菜单中查看。如下图：

![美洽 AppKey 查看界面图片](https://github.com/Meiqia/MeiqiaSDK-iOS/blob/master/resources/img/1667446646061.jpg)


## 添加自定义信息

功能效果展示：
![美洽工作台顾客自定义信息图片](https://github.com/Meiqia/MeiqiaSDK-iOS/blob/master/resources/img/1667446854328.jpg)

为了让客服能更准确帮助用户，开发者可上传不同用户的属性信息。示例如下：

```objc
//创建自定义信息
NSDictionary* clientCustomizedAttrs = @{
@"name"        : @"Kobe Bryant",
@"avatar"      : @"http://meiqia.com/avatar.png",
@"身高"         : @"1.98m",
@"体重"         : @"93.0kg",
@"效力球队"      : @"洛杉矶湖人队",
@"场上位置"      : @"得分后卫",
@"球衣号码"      : @"24号"
};

/**
 *  设置顾客的自定义信息
 *
 *  @param clientInfo 顾客的自定义信息
    @param override 是否强制更新，如果不设置此值为 YES，设置只有第一次有效。
 */
[chatViewManager setClientInfo:clientCustomizedAttrs override:YES];
或者
[MQManager setClientInfo:clientCustomizedAttrs completion:^(BOOL success) {
}];
```

以下字段是美洽定义好的，开发者可通过上方提到的接口，直接对下方的字段进行设置：

|Key|说明|
|---|---|
|name|真实姓名|
|gender|性别|
|age|年龄|
|tel|电话|
|weixin|微信|
|weibo|微博|
|address|地址|
|email|邮件|
|weibo|微博|
|avatar|头像 URL|
|comment|备注|

## SDK群发功能

美洽工作台设置群发任务，通过 SDK 渠道给目标顾客群发一条消息，引导顾客进入对话。

开启群发功能

```objc
  [[MQNotificationManager sharedManager] openMQGroupNotificationServer];
```

群发功能的目标顾客需要有对应的顾客信息，所以需要先配置顾客对应的[自定义信息](#添加自定义信息)

**注意**
* 该选项需要在SDK初始化成功以后调用。
* 该选项需要配置对应的顾客信息

自定义点击群发消息的响应事件

```objc
    // 开启自定义响应事件
  [MQNotificationManager sharedManager].handleNotification = YES;
```
在需要处理响应的地方，监听通知 MQ_CLICK_GROUP_NOTIFICATION

**注意**
* 开启自定义响应事件以后，需要自己通过监听通知来处理响应事件，否则点击群发消息以后会没有反应。

## 指定分配客服和客服组

美洽默认会按照管理员设置的分配方式智能分配客服，但如果需要让来自 App 的顾客指定分配给某个客服或者某组客服，需要在上线前添加以下代码：

如果您使用美洽提供的 UI ，可对 UI 进行如下配置，进行指定分配：

```objc
MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
[chatViewManager setScheduledAgentId:agentToken];
```

如果您自定义 UI，可直接使用如下美洽 SDK 逻辑接口：

```objc
//分配到指定客服，或指定组里面的客服，指定客服优先级高，并可选择分配失败后的转接规则
[MQManager setScheduledAgentWithAgentId:agentId agentGroupId:agentGroupId scheduleRule:rule];
```

**注意**
* 该选项需要在用户上线前设置。
* 客服组 ID 和客服 ID 可以通过管理员帐号在后台的「设置」中查看。

![查看ID](https://github.com/Meiqia/MeiqiaSDK-iOS/blob/master/resources/img/1667446915131.jpg)


## 调出视图

你只需要在用户需要客服服务的时候，调出美洽 UI。如下所示：

```objc
//当用户需要使用客服服务时，创建并退出视图
MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
[chatViewManager pushMQChatViewControllerInViewController:self];
```

**注意**，此时使用美洽 初始化SDK后的顾客进行上线。如果开发者需要指定顾客上线，可参考:

[设置登录客服的开发者自定义 id](#设置登录客服的开发者自定义-id)

[设置登录客服的顾客 id](#设置登录客服的顾客-id)

`MQServiceToViewInterface` 文件是开源聊天界面调用美洽 SDK 接口的中间层，目的是剥离开源界面中的美洽业务逻辑。这样就能让该聊天界面用于非美洽项目中，开发者只需要实现 `MQServiceToViewInterface` 中的方法，即可将自己项目的业务逻辑和该聊天界面对接。

## 开启同步服务端消息设置

如果开启消息同步，在聊天界面中下拉刷新，将会获取服务端的历史消息；

如果关闭消息同步，则是获取本机数据库中的历史消息；

由于顾客可能在多设备聊天，关闭消息同步后获取的历史消息，将可能少于服务端的历史消息。

```objc
MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
//开启同步消息
[chatViewManager enableSyncServerMessage:true];
[chatViewManager pushMQChatViewControllerInViewController:self];
```


### 指定分配客服和客服组设置

上文已有介绍，请参考 [指定分配客服和客服组](#指定分配客服和客服组)。


### 设置登录客服的开发者自定义 id

设置开发者自定义 id 后，将会以该自定义 id 对应的顾客上线。

**注意**，如果美洽服务端没有找到该自定义 id 对应的顾客，则美洽将会自动关联该 id 与 SDK 当前的顾客。

```objc
MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
[chatViewManager setLoginCustomizedId:customizedId];
[chatViewManager pushMQChatViewControllerInViewController:self];
```

使用该接口，可让美洽绑定开发者的用户系统和美洽的顾客系统。

**注意**，如果开发者的自定义 id 是自增长，美洽建议开发者服务端保存美洽顾客 id，登陆时 [设置登录客服的顾客 id](#设置登录客服的顾客-id)，否则非常容易受到中间人攻击。


### 设置登录客服的顾客 id

设置美洽顾客的 id 后，该id对应的顾客将会上线。

```objc
MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
[chatViewManager setLoginMQClientId:clientId];
[chatViewManager pushMQChatViewControllerInViewController:self];
```

**注意**，如果美洽服务端没有找到该顾客 id 对应的顾客，则会返回`该顾客不存在`的错误。

开发者需要获取 clientId，可使用接口`[MQManager getCurrentClientId]`。



### 真机调试时,语言没有切换为中文

为了能正常识别App的系统语言，开发者的 App 的 info.plist 中需要有添加 Localizations 配置。如果需要支持英文、简体中文、繁体中文，info.plist 的 Souce Code 中需要有如下配置：

```
<key>CFBundleLocalizations</key>
<array>
    <string>zh_CN</string>
    <string>zh_TW</string>
    <string>en</string>
</array>
```
开源聊天界面的更多配置，可参见 [MQChatViewManager.h](https://github.com/Meiqia/MQChatViewController/blob/master/MQChatViewControllerDemo/MQChatViewController/Config/MQChatViewManager.h) 文件。

# 六 美洽 API 接口介绍

**本节主要介绍部分重要的接口。在`MeiqiaSDK.framework`的`MQManager.h`中，所有接口都有详细注释。**

开发者可使用美洽提供的 API，自行定制聊天界面。使用以下接口前，别忘了 [初始化 SDK](#初始化-sdk)。


## 接口描述

### 初始化SDK

美洽建议开发者在 `AppDelegate.m` 的系统回调 `didFinishLaunchingWithOptions` 中，调用初始化 SDK 接口。这是因为第一次初始化美洽 SDK，SDK 会向美洽服务端发送一个初始化顾客的请求，SDK 其他接口都必须是在初始化 SDK 成功后进行，所以 App 应尽早初始化 SDK 。

```objc
//建议在AppDelegate.m系统回调didFinishLaunchingWithOptions中增加
[MQManager initWithAppkey:@"开发者注册的App的AppKey" completion:^(NSString *clientId, NSError *error) {
}];
```

### 注册设备的 deviceToken

美洽需要获取每个设备的 deviceToken，才能在 App 进入后台以后，推送消息给开发者的服务端。消息数据中有 deviceToken 字段，开发者获取到后，可通知 APNS 推送给该设备。

在 AppDelegate.m中的系统回调 `didRegisterForRemoteNotificationsWithDeviceToken` 中，调用上传 deviceToken 接口：

```objc
[MQManager registerDeviceToken:deviceToken];
```

### 关闭美洽推送

详细介绍请见 [消息推送](#三说好的推送呢)。


### 指定分配客服和客服组接口

该接口上文已有介绍，请见 [指定分配客服和客服组](#指定分配客服和客服组)。


### 让当前的顾客上线。

初始化 SDK 成功后，SDK 中有一个可使用的顾客 id，调用该接口即可让其上线，如下代码：

```objc
[MQManager setCurrentClientOnlineWithCompletion:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
//可根据result来判断是否上线成功
} receiveMessageDelegate:self];
```


### 根据美洽的顾客 id，登陆美洽客服系统，并上线该顾客。

开发者可通过 [获取当前顾客 id](#获取当前顾客-id) 接口，取得顾客 id ，保存到开发者的服务端，以此来绑定美洽顾客和开发者用户系统。
如果开发者保存了美洽的顾客 id，可调用如下接口让其上线。调用此接口后，当前可用的顾客即为开发者传的顾客 id。

```objc
[MQManager setClientOnlineWithClientId:clientId completion:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
//可根据result来判断是否上线成功
} receiveMessageDelegate:self];
```


### 根据开发者自定义的 id，登陆美洽客服系统，并上线该顾客。

如果开发者不愿保存美洽顾客 id，来绑定自己的用户系统，也将用户 id当做参数，进行顾客的上线，美洽将会为开发者绑定一个顾客，下次开发者直接调用如下接口，就能让这个绑定的顾客上线。

调用此接口后，当前可用的顾客即为该自定义 id 对应的顾客 id。

**特别注意：**传给美洽的自定义 id 不能为自增长的，否则非常容易受到中间人攻击，此情况的开发者建议保存美洽顾客 id。

```objc
[MQManager setClientOnlineWithCustomizedId:customizedId completion:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
//可根据result来判断是否上线成功
} receiveMessageDelegate:self];
```

### 监听顾客上线成功后的广播

开发者可监听顾客上线成功的广播，在上线成功后，可上传该顾客的自定义信息等操作。广播的名字为 `MQ_CLIENT_ONLINE_SUCCESS_NOTIFICATION`，定义在 [MQDefinition.h](https://github.com/Meiqia/MeiqiaSDK-iOS/blob/master/Meiqia-SDK-Demo/MeiQiaSDK.framework/Headers/MQDefinition.h) 中。

### 获取当前顾客 id

开发者可通过此接口接口，取得顾客 id，保存到开发者的服务端，以此来绑定美洽顾客和开发者用户系统。

```objc
NSString *clientId = [MQManager getCurrentClientId];
```


### 创建一个新的顾客

如果开发者想初始化一个新的顾客，可调用此接口。

该顾客没有任何历史记录及用户信息。

开发者可选择将该 id 保存并与 App 的用户绑定。

```objc
[MQManager createClient:^(BOOL success, NSString *clientId) {
//开发者可保存该clientId
}];
```


### 设置顾客离线

```objc
NSString *clientId = [MQManager setClientOffline];
```

如果没有设置顾客离线，开发者设置的代理将收到即时消息，并收到新消息产生的广播。开发者可以监听此 notification，用于显示小红点未读标记。

如果设置了顾客离线，则客服发送的消息将会发送给开发者的服务端。

`美洽建议`，顾客退出聊天界面时，不设置顾客离线，这样开发者仍能监听到收到消息的广播，以便提醒顾客有新消息。


### 监听收到消息的广播

开发者可在合适的地方，监听收到消息的广播，用于提醒顾客有新消息。广播的名字为 `MQ_RECEIVED_NEW_MESSAGES_NOTIFICATION`，定义在 [MQDefinition.h](https://github.com/Meiqia/MeiqiaSDK-iOS/blob/master/Meiqia-SDK-Demo/MeiQiaSDK.framework/Headers/MQDefinition.h) 中。

开发者可获取广播中的userInfo，来获取收到的消息数组，数组中是美洽消息 [MQMessage](https://github.com/Meiqia/MeiqiaSDK-iOS/blob/master/Meiqia-SDK-Demo/MeiQiaSDK.framework/Headers/MQMessage.h) 实体，例如：`[notification.userInfo objectForKey:@"messages"]`

**注意**，如果顾客退出聊天界面，开发者没有调用设置顾客离线接口的话，以后该顾客收到新消息，仍能收到`有新消息的广播`。

``` 
### 在合适的地方监听有新消息的广播
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMQMessages:) name:MQ_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil];

### 监听收到美洽聊天消息的广播
- (void)didReceiveNewMQMessages:(NSNotification *)notification {
//广播中的消息数组
NSArray *messages = [notification.userInfo objectForKey:@"messages"];
NSLog(@"监听到了收到客服消息的广播");
}

```

### 获取当前正在接待的客服信息

开发者可用此接口获取当前正在接待顾客的客服信息：

```
MQAgent *agent = [MQManager getCurrentAgent];
```


### 添加自定义信息

添加自定义信息操作和上述相同，跳至 [添加自定义信息](#添加自定义信息)。


### 从服务端获取更多消息

开发者可用此接口获取服务端的历史消息：

```objc
[MQManager getServerHistoryMessagesWithUTCMsgDate:firstMessageDate messagesNumber:messageNumber success:^(NSArray<MQMessage *> *messagesArray) {
//显示获取到的消息等逻辑
} failure:^(NSError *error) {
//进行错误处理
}];
```

**注意**，服务端的历史消息是该顾客在**所有平台上**产生的消息，包括网页端、Android SDK、iOS SDK、微博、微信，可在聊天界面的下拉刷新处调用。


### 从本地数据库获取历史消息

由于使用 [从服务端获取更多消息](#从服务端获取更多消息)接口，会产生数据流量，开发者也可使用此接口来获取 iOS SDK 本地的历史消息。

```objc
[MQManager getDatabaseHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:messageNumber result:^(NSArray<MQMessage *> *messagesArray) {
//显示获取到的消息等逻辑
}];
```

**注意**，由于没有同步服务端的消息，所以本地数据库的历史消息有可能少于服务端的消息。

### 接收即时消息

开发者可能注意到了，使用上面提到的3个顾客上线接口，都有一个参数是`设置接收消息的代理`，开发者可在此设置接收消息的代理，由代理来接收消息。

设置代理后，实现 `MQManagerDelegate` 中的 `didReceiveMQMessage:` 方法，即可通过这个代理函数接收消息。


### 发送消息

开发者调用此接口来发送**文字消息**：

```objc
[MQManager sendTextMessageWithContent:content completion:^(MQMessage *sendedMessage) {
//消息发送成功后的处理
}];
```

开发者调用此接口来发送**图片消息**：

```objc
[MQManager sendImageMessageWithImage:image completion:^(MQMessage *sendedMessage) {
//消息发送成功后的处理
}];
```

开发者调用此接口来发送**语音消息**：

```objc
[MQManager sendAudioMessage:audioData completion:^(MQMessage *sendedMessage, NSError *error) {
//消息发送成功后的处理
}];
```
开发者调用此接口来发送**视频消息**：

```objc
[MQManager sendVideoMessage:filePath completion:^(MQMessage *sendedMessage, NSError *error) {
//消息发送成功后的处理
}];
```
开发者调用此接口来发送**商品卡片消息**：

```objc
+ (MQMessage *)sendProductCardMessageWithPictureUrl:(NSString *)pictureUrl
                                         title:(NSString *)title
                                         descripation:(NSString *)descripation
                                         productUrl:(NSString *)productUrl
                                         salesCount:(long)salesCount
                               completion:(void (^)(MQMessage *sendedMessage, NSError *error)) {
//消息发送成功后的处理
}];
```

**注意**，调用发送消息接口后，回调中会返回一个消息实体，开发者可根据此消息的状态，来判断该条消息是发送成功还是发送失败。

### 自定义点击商品卡片的响应

```objc
    // 自定义商品卡片响应事件
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager didTapProductCard:^(NSString *productUrl) {
        NSLog(@"商品卡片的响应链接：%@",productUrl);
    }];
```

### 获取未读消息数

开发者使用此接口来统一获取所有的未读消息，用户可以在需要显示未读消息数是调用此接口，此接口会自动判断并合并本地和服务器上的未读消息，当用户进入聊天界面后，未读消息将会清零。
`[MQManager getUnreadMessagesWithCompletion:completion]`

### 获取自定义 id 未读消息

开发者使用此接口来统一获取自定义 id 所有的未读消息
`[MQManager getUnreadMessagesWithCustomizedId:customizedId completion:completion]`

###录音和播放录音

录音和播放录音分别包含 3 种可配置的模式：
- 暂停其他音频
- 和其他音频同时播放
- 降低其他音频声音

用户可以根据情况选择，在 `MQChatViewManager.h` 中直接配置以下两个属性：

`@property (nonatomic, assign) MQPlayMode playMode;`

`@property (nonatomic, assign) MQRecordMode recordMode;`

如果宿主应用本身也有声音播放，比如游戏，为了不影响背景音乐播放，可以设置 `@property (nonatomic, assign) BOOL keepAudioSessionActive;` 为 `YES` 这样就不会再完成播放和录音之后关闭 AudioSession，从而不会影响背景音乐。

**注意，游戏中，要将声音播放的 category 设置为 play and record，否则会导致录音之后无法播放声音。**


### 预发送消息

在 `MQChatViewManager.h` 中， 通过设置 `@property (nonatomic, strong) NSArray *preSendMessages;` 来让客户显示聊天窗口的时候，自动向客服发送消息，支持文字和图片。

### 监听聊天界面显示和消失

* `MQ_NOTIFICATION_CHAT_BEGIN` 在聊天界面出现的时候发送
* `MQ_NOTIFICATION_CHAT_END` 在聊天界面消失时发送


### 用户排队

监听消息:
当用户被客服接入时，会受到 `MQ_NOTIFICATION_QUEUEING_END` 通知。


# 七  SDK 中嵌入美洽 SDK
如果你的开发项目也是 SDK，那么在了解常规 App 嵌入美洽 SDK 的基础上，还需要注意其他事项。

与 App 嵌入美洽 SDK 的步骤相同，需要 导入美洽 SDK -\> 引入依赖库 -\> 初始化 SDK -\> 使用美洽 SDK。

如果开发者使用了美洽提供的聊天界面，还需要公开素材包：

开发者点击工程右边的工程名,然后在工程名右边依次选择 *TARGETS* -\> *BuiLd Phases* -\> *Copy Files* ，展开 *Copy Files* 后点击展开后下面的 *+* 来添加美洽素材包 `MQChatViewAsset.bundle`。

在之后发布你的 SDK 时，将 `MQChatViewAsset.bundle` 一起打包即可。



# 八 留言表单

目前是两种模式：

1. 完全对话模式：
    * 无机器人时：如果当前客服不在线，直接聊天界面输入就是留言，客服上线后能够直接回复，如果客服在线，则进入正常客服对话模式。
    * 有机器人时：如果当前客服不在线，直接聊天界面输入的话，还是由机器人回答，顾客点击留言就会跳转到表单。

2. 单一表单模式：
不管客服是否在线都会进入表单，顾客提交后，不会有聊天界面。这种主要用于一些 App 只需要用户反馈，不需要直接回复的形式。

### 设置留言表单引导文案

配置了该引导文案后将不会读取工作台配置的引导文案。
最佳实践：尽量不要在 SDK 中配置引导文案，而是通过工作台配置引导文案，方便在节假日的时候统一配置各端的引导文案，避免重新打包发布 App。

```objc
MQMessageFormViewManager *messageFormViewManager = [[MQMessageFormViewManager alloc] init];
[messageFormViewManager setLeaveMessageIntro:@"我们的在线时间是周一至周五 08:30 ~ 19:30, 如果你有任何需要，请给我们留言，我们会第一时间回复你"];
[messageFormViewManager pushMQMessageFormViewControllerInViewController:self];
```

### 设置留言表单的自定义输入信息

开发者可以通过工作台配置留言表单的自定义输入信息。请使用美洽管理员帐号登录 [美洽](http://www.meiqia.com)，在「设置」 -\> 「留言」 -\> 「留言设置」中设置。

![留言设置地址](https://github.com/Meiqia/MeiqiaSDK-iOS/blob/master/resources/img/1667447060217.jpg)


# 九 名词解释

### 开发者的推送消息服务器

目前美洽是把 SDK 的 `离线消息` 通过 webhook 形式发送给 - 开发者提供的 URL。

接收美洽 SDK 离线消息的服务器即为 `开发者的推送消息服务器`。


### 客服 id

美洽企业每一位注册客服均有一个唯一 id。通过此 id 开发者可用 SDK 接口指定分配对话给该客服。


### 客服组 id

美洽工作台支持为不同的客服分组，每一个组都有一个唯一id。通过此 id 开发者可用 SDK 接口指定分配对话给该客服组。


### 美洽顾客 id

美洽 SDK 在上线后（或称为分配对话后），均有一个唯一 id。

开发者可保存此 id，在其他设备上进行上线操作。这样此 id 的顾客信息和历史对话，都会同步到其他设备。


### 开发者自定义 id

即开发者自己定义的 id，例如开发者账号系统下的 user_id。

开发者可用此 id 进行上线，上线成功后，此 id 会绑定一个 `美洽顾客 id`。开发者在其他设备用自己的 id 上线后，可以同步之前的数据。

**注意**，如果开发者自己的 id 过于简单（例如自增长的数字），安全起见，建议开发者保存 `美洽顾客 id`，来进行上线操作。


# 十 常见问题
- [更新SDK](#更新SDK)
- [iOS 11下 SDK 的聊天界面底部输入框出现绿色条状,且无法输入](#ios11下sdk的聊天界面底部输入框出现绿色条状,且无法输入)
- [SDK 初始化失败](#sdk-初始化失败)
- [没有显示 导航栏栏/UINavgationBar](#没有显示-导航栏栏uinavgationbar)
- [Xcode Warning: was built for newer iOS version (7.0) than being linked (6.0)](#xcode-warning-was-built-for-newer-ios-version-70-than-being-linked-60)
- [美洽静态库的文件大小太大](#美洽静态库的文件大小太大)
- [使用 TabBarController 后，输入框高度出现异常](#使用-tabbarcontroller-后inputbar-高度出现异常)
- [键盘弹起后输入框和键盘之间有偏移](#键盘弹起后输入框和键盘之间有偏移)
- [如何得到客服 id 或客服分组 id](#如何得到客服id或客服分组id)
- [如何在聊天界面之外监听新消息的通知](#如何在聊天界面之外监听新消息的通知)
- [指定分配客服/客服组失效](#指定分配客服/客服组失效)
- [第三方库冲突](#第三方库冲突)
- [工作台顾客信息显示应用的名称不正确](#工作台顾客信息显示应用的名称不正确)
- [编译中出现 undefined symbols](#编译中出现-undefined-symbols)

## 更新SDK
### 1.pod集成的用户
  
  直接在工程中修改 podfile里面 meiqia 的版本号为最新的版本号,然后 终端 cd到项目工程目录下,执行 **pod update Meiqia**即可完成SDK的更新.
  
### 2.手动集成的客户比较麻烦,我们这边探索的办法为:

1通过**show In finder** 删除自己项目工程中的Meiqia的四个文件

**`MeiQiaSDK.framework` 、 `MQChatViewController`  `MeiqiaSDKViewInterface` 和 `MQMessageForm`**

2 cleanXcode, 

3 从github上下载新版Demo,然后找到
**`MeiQiaSDK.framework` 、 `MQChatViewController`  `MeiqiaSDKViewInterface` 和 `MQMessageForm`**,复制粘贴到 项目工程中 **show in  finder**之前存放SDK 4个文件的地方

4 然后通过 **add files to** ,将复制的sdk下的四个文件夹 添加到工程中的原来放置这4个文件的地方

## iOS 11下 SDK 的聊天界面底部输入框出现绿色条状,且无法输入
请升级到最新版本, 已完成iOS 11的适配. 
**温馨提示: 遇到iOS 有重大更新的时候,请提前进入技术支持群,询问SDK是否要更新.**
## SDK 初始化失败

### 1. 美洽的 AppKey 版本不正确
当前SDK是为美洽 3.0 提供服务，如果你使用的 AppKey 是美洽 2.0 「经典版」的，请使用美洽 2.0 「经典版」SDK

传送门：

* [新版注册入口](https://app.meiqia.com/signup)
* [经典版注册入口](http://meiqia.com/signup)

### 2. 没有配置 NSExceptionDomains
如果没有配置`NSExceptionDomains`，美洽SDK会返回`MQErrorCodePlistConfigurationError`，并且在控制台中打印：`!!!美洽 SDK Error：请开发者在 App 的 info.plist 中增加 NSExceptionDomains，具体操作方法请见「https://github.com/Meiqia/MeiqiaSDK-iOS#info.plist设置」`。如果出现上诉情况，请 [配置NSExceptionDomains](#infoplist设置)

**注意**，如果发现添加配置后，仍然打印配置错误，请开发者检查是否错误地将配置加进了项目 Tests 的 info.plist 中去。

### 3. 网络异常
如果上诉情况均不存在，请检查引入美洽SDK的设备的网络是否通畅

## 没有显示 导航栏/UINavgationBar
美洽开源的聊天界面用的是系统的 `UINavgationController`，所以没有显示导航栏的原因有3种可能：

* 如果使用的是`Push`方式弹出视图，那么可能是传入 `viewController` 没有基于 `UINavigationController`。
* 如果使用的是`Push`方式弹出视图，那么可能是 `UINavgationBar` 被隐藏或者是透明的。
* App中使用了 `Category`，对 `UINavgationBar` 做了修改，造成无法显示。

其中1、2种情况，除了修改代码，还可以直接使用 `present` 方式弹出视图解决。

## Xcode Warning: was built for newer iOS version (7.0) than being linked (6.0)

如果开发者的 App 最低支持系统是 7.0 以下，将会出现这种 warning。

`ld: warning: object file (/Meiqia-SDK-Demo/MQChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/libopencore-amrnb.a(wrapper.o)) was built for newer iOS version (7.0) than being linked (6.0)`

原因是美洽将 SDK 中使用的开源库 [opencore-amr](http://sourceforge.net/projects/opencore-amr/) 针对支持Bitcode而重新编译了一次，但这并不影响SDK在iOS 6中的使用。如果你介意，并且不会使用 Bitcode，可以将美洽SDK中使用 `opencore-amr` 替换为老版本：[传送门](https://github.com/molon/MLAudioRecorder/tree/master/MLRecorder/MLAudioRecorder/amr_en_de/lib)

## 美洽静态库的文件大小太大
因为美洽静态库包含5个平台（armv7、arm64、i386、x86_64）+ Bitcode。但这并不代表会严重影响编译后的宿主 App 大小，实际上，这只会增加宿主 App 100kb 左右大小。

## 键盘弹起后输入框和键盘之间有偏移
请检查是否使用了第三方开源库[IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager)，该开源库会和判断输入框的逻辑冲突。

解决办法：（感谢 [RandyTechnology](https://github.com/RandyTechnology) 向我们提供该问题的原因和解决方案）

* 在MQChatViewController的viewWillAppear里加入 `[[IQKeyboardManager sharedManager] setEnable:NO];`，作用是在当前页面禁止IQKeyboardManager
* 在MQChatViewController的viewWillDisappear里加入 `[[IQKeyboardManager sharedManager] setEnable:YES];`，作用是在离开当前页面之前重新启用IQKeyboardManager

## 使用 TabBarController 后，inputBar 高度出现异常

使用了 TabBarController 的 App，视图结构都各相不同，并且可能存在自定义 TabBar 的情况，所以美洽 SDK 无法判断并准确调整，需要开发者自行修改 App 或 SDK 代码。自 iOS 7 系统后，大多数情况下只需修改 TabBar 的 `hidden` 和 `translucent` 属性便可以正常使用。

## 如何得到客服ID或客服分组ID

请查看 [指定分配客服和客服组](#指定分配客服和客服组) 中的配图。

## 如何在聊天界面之外监听新消息的通知

请查看 [如何监听监听收到消息的广播](#监听收到消息的广播)。

## 指定分配客服/客服组失效

请查看指定的客服的服务顾客的上限是否被设置成了0，或服务顾客的数量是否已经超过服务上限。查看位置为：`工作台 - 设置 - 客服与分组 - 点击某客服`

## 第三方库冲突

由于「聊天界面」的项目中用到了几个开源库，如果开发者使用相同的库，会产生命名空间冲突的问题。遇到此类问题，开发者可以选择删除「聊天界面 - Vendors」中的相应第三方代码。

**注意**，美洽对几个第三方库进行了自定义修改，如果开发者删除了美洽中的 Vendors，聊天界面将会缺少我们自定义的效果，详细请移步 Github [美洽开源聊天界面](https://github.com/Meiqia/MQChatViewController#vendors---用到的第三方开源库)。

## 工作台顾客信息显示应用的名称不正确

如果工作台的某对话中的顾客信息 - 访问信息中的「应用」显示的是 App 的 Bundle Name 或显示的是「SDK 无法获取 App 的名字」，则可能是您的 App 的 info.plist 中没有设置 CFBundleDisplayName 这个 Property，导致 SDK 获取不到 App 的名字。

## 编译中出现 undefined symbols

请开发者检查 App Target - Build Settings - Search Path - Framework Search Path 或 Library Search Path 当中是否没有美洽的项目。

## Xcode14上的一些变动需知晓

* Bitcode 废除
* iOS v3.8.5 - v3.9.0 真机只支持arm64

Vendors - 用到的第三方开源库
---
以下是该 Library 用到的第三方开源代码，如果开发者的项目中用到了相同的库，需要删除一份，避免类名冲突：

第三方开源库 | Tag 版本 | 说明
----- | ----- | -----
VoiceConvert |  N/A | AMR 和 WAV 语音格式的互转；没找到出处，哪位童鞋找到来源后，请更新下文档~
[MLAudioRecorder](https://github.com/molon/MLAudioRecorder) | master | 边录边转码，播放网络音频 Button (本地缓存)，实时语音。**注意**，由于该开源项目中的 [lame.framework](https://github.com/molon/MLAudioRecorder/tree/master/MLRecorder/MLAudioRecorder/mp3_en_de/lame.framework) 不支持 `bitCode` ，所以我们去掉了该项目中有关 MP3 的文件；
[GrowingTextView](https://github.com/HansPinckaers/GrowingTextView) | 1.1 | 随文字改变高度的的 textView，用于本项目中的聊天输入框；
[TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) |  | 支持多种效果的 Lable，用于本项目中的聊天气泡的文字 Label；
[CustomIOSAlertView](https://github.com/wimagguc/ios-custom-alertview) | 自定义 | 自定义的 AlertView，用于显示本项目的评价弹出框；**注意**，我们队该开源项目进行了修改，增加了按钮之间的分隔线条、判断当前是否已经有 AlertView 在显示、以及键盘弹出时界面 frame 计算，该修改版本可以见 [CustomIOSAlertView](https://github.com/ijinmao/ios-custom-alertview)；
[AGEmojiKeyboard](https://github.com/ayushgoel/AGEmojiKeyboard)|0.2.0|表情键盘，布局进行自定义，源码可以在工程中查看；

# 十一 更新日志
**v3.9.26  2025 年 8 月 01 日**
* 修复 部分消息异常加载导致崩溃的问题

**v3.9.25  2025 年 7 月 22 日**
* 修复 iOS 18 无法跳转链接的问题
* 修复 部分消息显示异常问题

**v3.9.24  2025 年 6 月 30 日**
* 修复 输入法覆盖内容问题
* 优化 iOS 最低支持版本改为 12

**v3.9.23  2025 年 5 月 20 日**
* 修复 输入框安全区域显示问题

**v3.9.22  2025 年 4 月 2 日**
* 删除无用的log

**v3.9.21  2024 年 12 月 31 日**
* 修复文件下载异常问题

**v3.9.20  2024 年 11 月 28 日**
* 修复偶现进入对话页崩溃问题
* 修复发送商品卡显示异常问题

**v3.9.19  2024 年 11 月 14 日**
* 新增已分配客服情况下是否需要重新分配
* 新增域名动态替换

**v3.9.18  2024 年 10 月 14 日**
* 询前表单新增分配规则
* 机器人转人工获取自定义文案
* 修复消息时间显示异常问题

**v3.9.17  2024 年 5 月 8 日**
* 修复视频消息显示已过期问题

**v3.9.16  2024 年 4 月 19 日**
* 优化询前表单不弹出问题
* 新增隐私清单

**v3.9.15  2024 年 3 月 26 日**
* 优化排队时不能发送消息问题

**v3.9.14  2024 年 2 月 4 日**
* 优化网络判断逻辑

**v3.9.13  2024 年 2 月 2 日**
* 支持工作台控制发送图片消息按钮显示开关

**v3.9.12  2024 年 1 月 24 日**
* 优化顾客信息更新逻辑

**v3.9.11  2024 年 1 月 17 日**
* 修复屏蔽IP的用户首次登录崩溃问题
* 修复 UIGraphicsBeginImageContextWithOptions 传 0 崩溃问题

**v3.9.10  2023 年 12 月 18 日**
* 新增支持根据工作台开关，判断是否允许加载历史对话

**v3.9.9  2023 年 12 月 8 日**
* 新增子渠道配置支持
* 优化机器人消息排版不一致问题

**v3.9.8  2023 年 11 月 22 日**
* 优化消息发送后不显示

**v3.9.7  2023 年 11 月 8 日**
* 优化询前表单显示

**v3.9.6  2023 年 10 月 31 日**
* 新增点击富文本中图片放大
* 添加多语言日语、泰语、越南语、葡萄牙语、印地语、西班牙语、俄语、韩语

**v3.9.5  2023 年 10 月 12 日**
* 新增获取自定义 id 未读消息

**v3.9.4  2023 年 9 月 13 日**
* 优化底部功能按钮的自定义适配
* 优化机器人消息富文本图片显示的问题
* 优化首条消息重复的问题
* 优化关联消息显示的问题

**v3.9.3  2023 年 6 月 6 日**
* 修复iOS 16内存暴涨崩溃问题
* 优化富文本图片显示复用的问题
* 支持客服评价按钮显示工作台可配置

**v3.9.2  2023 年 3 月 24 日**

**v3.9.1  2023 年 3 月 24 日**
* 支持armv7
* 支持讯前表单标题显示富文本
* 支持撤回消息提示语工作台可配置
* 优化预览图片模糊问题
* 修复视频第一帧图片显示失败的问题
* 修复多语言应用内不能实时切换的问题

**v3.9.0  2023 年 2 月 9 日**
* 优化留言界面留言标题展示样式
* 处理 v3.8.6 - v3.8.9 在 Xcode 14版本以下的Xcode运行demo报 'undefined symbols for architecture arm64' 的问题

**v3.8.9  2023 年 1 月 9 日**
* 修复开启无消息访客过滤，发送消息失败并且不能进入排队的问题

**v3.8.8  2023 年 1 月 6 日**
* 优化机器人相关问题的UI样式

**v3.8.6 v3.8.7  2022 年 12 月 7 日**
* 留言功能支持可开启与关闭
* 富文本超链接支持打电话

**v3.8.5  2022 年 10 月 8 日**
* 设配iphone14样式
* 修复开启无消息访客过滤，没有显示团队名称的问题
* 修复包含emoji的Text类型消息，高度不适应的问题


**v3.8.4  2022 年 8 月 1 日**
* 修复socketManager的崩溃问题

**v3.8.3  2022 年 7 月 21 日**
* 优化机器人的头像和名称显示
* 支持自定义点击商品卡片的响应事件
* 支持自定义点击群发消息的响应事件

**v3.8.2  2022 年 6 月 23 日**
* 新增SDK群发功能
* 优化排队功能

**v3.8.1  2022 年 5 月 19 日**
* 修复关闭机器人反馈消息开关，不展示相关问题的bug

**v3.8.0  2022 年 5 月 7 日**
* 支持应用内的多语言切换
* 支持机器人反馈消息开关的控制
* 添加机器人转人工失败的留言提示

**v3.7.9  2022 年 1 月 20 日**
* 支持工单发送视频
* 支持营销机器人的引导操作按钮

**v3.7.8  2021 年 11 月 24 日**
* 新增消息操作功能按钮

**v3.7.7  2021 年 11 月 9 日**
* 修复发送商品卡片成功以后，退出聊天页面再进入聊天页面会出现重复的发送失败的商品卡片

**v3.7.6  2021 年 10 月 12 日**
* 适配iOS 15
* 过滤文本消息中的html标签
* 添加相册是否可以裁剪的配置
* 添加转人工触发事件

**v3.7.5  2021 年 9 月 8 日**
* 新增马来语、印尼语的多语言配置
* 优化机器人关键词转人工的提示语
* 优化消息已读回执功能

**v3.7.4  2021 年 9 月 3 日**
* 添加网络状态提示的UI
* 添加发送商品卡片的功能

**v3.7.3  2021 年 8 月 17 日**
* 优化排队的UI样式
* 优化顾客设备信息的上传逻辑
* 优化消息已读状态更新的逻辑
* 添加iPhone 12设备判断

**v3.7.2  2021 年 8 月 5 日**
* 优化socket断开链接后,同步消息失败的问题
* 修复留言与转人工tip没有适配对应多语言的问题

**v3.7.1  2021 年 5 月 25 日**
* 美洽内部引用库的重命名
* 工单分类询问表单是否展示

**v3.7.0  2021 年 5 月 14 日**
* 优化socket异常信息为nil的处理

**v3.6.9  2021 年 4 月 28 日**
* 更新会话分割样式
* 修复多语言配置繁体中文显示错误问题
* 修复 TTTAttributedLabel Xcode 12.5 报错的问题

**v3.6.8  2021 年 3 月 24 日**
* 修复会话分割线错乱
* 修复新会话收不到客服欢迎语
* 添加新消息已读和已接收回执

**v3.6.7  2021 年 1 月 18 日**
* 修复更新顾客头像失败的问题
* 修复机器人消息富文本大图片显示不全问题
* 优化部分类名的命名

**v3.6.6  2020 年 12 月 11 日**
* 更新留言表单功能

**v3.6.5  2020 年 11 月 12 日**
* 新增发送视频消息功能
* 新增会话分割线，区分不同的会话
* 优化conversation的id取值范围，防止值越界
* 优化键盘弹出崩溃的问题
* 优化聊天列表下拉刷新顶部遮挡问题

**v3.6.4  2020 年 9 月 24 日**

* 适配 iOS 14的 UI
* 修复一些已知bug

**v3.6.3  2020 年 8 月 21 日**

* 优化无消息访客过滤状态下的消息发送逻辑
* 优化讯前表单的展示逻辑
* 修复一些已知bug

**v3.6.2  略**

**v3.6.1  2020 年 8 月 7 日**

* 优化数据库
* 修复一些bug

**v3.6.0  2020 年 7 月 16 日**

* 新增敏感词汇过滤功能
* 新增红包/优惠券类消息
* 修复其他三方机器人hybrid类型消息解析不出来问题
* 修复一些bug

**v3.5.2  2020 年 6 月 12 日**

* 新增消息撤回功能
* 新增线索卡片功能
* 新增富文本和HTML在cell直接显示功能
* 增加队列等待提醒
* 修复一些bug

**v3.5.0  略**

**v3.4.9  2018 年 12 月 3 日**

* 新增创建工单时关联上一个对话
* 新增SDK中增加请求来源
* 修复一些bug

**v3.4.8  2018 年 10 月 26 日**

* 添加推送刷新的api
* 机型判断,添加XR XS XSMAX系列
* 降低警告的个数
* 修复部分类名大小写不统一

**v3.4.7  2018 年 7 月 5 日**

* 修复转接类型信息错误
* 修复下拉获取历史记录的偏移
* 优化打开相机或相册时的交互体验


**v3.4.6  2018 年 6 月 8 日**

* 修复评价弹窗在x上被键盘部分遮挡
* 国际化文本补充
* 内存优化
* 修复若干bug

**v3.4.5/3.4.4  2018 年 3 月 6 日**

* 优化socket性能
* 添加预发送消息的功能,方便客服在工作台实时了解访客输入的内容
* 修复表情键盘等若干bug


**v3.4.3  2017 年 10 月 30 日**
* iPhoneX适配
* 修复开启访客无消息过滤后 产生的bug
* 修复企业欢迎消息关闭时 出现空消息的bug

**v3.4.2  2017 年 9 月 12 日**
* iOS 11适配
* 修复若干bug
* 聊天界面输入框预留字国际化处理
*  socket主动重连


**v3.3.9  2017 年 8 月 4 日**
* 添加无消息访客过滤功能
* 修复使用私有api导致appstore上线被拒问题
* 添加iPhone5SE来源

**v3.3.8  2017 年 4 月 10 日**
* 修复如果在对话没有结束，连接正常的情况下，重新指定客服或者客服组没有效果的问题

**v3.3.6  2017 年 3 月 3 日**
* 优化UI

**v3.3.5  2017 年 2 月 9 日**
* 重写下拉控件,优化动画
* 修复对话结束后,对客服评价没有记录

**v3.3.4.1 2016 年 12 月 13 日**
* 移除 ATS 配置检查

**v3.3.4 2016 年 12 月 7 日**

* 修复发送图片，语音失败。

**V3.3.3 2016 年 12 月 2 日**

* 修复进入后台之后，ticket 回复不能马上收到。
* 其他小问题.

**v3.3.2 2016 年 10 月 19 日** 

* 增加留言表单中工单类型选择。
* 多企业支持切换。
* 增加工单相关接口。
* 修复问题:
    - 偶发的文字截断 
    - 用户设置上传之后立刻获取无法获取到。
    - 留言表单返回按钮的图片没有自动获取聊天界面用户设置的自定义图片。
    - 导航栏右侧按钮，如果是自定义按钮，在分配机器人是没有显示转接人工，并且转接客服之后消失。
    - 增加 socket 连接无法连接时的消息轮询机制，确保消息不丢失。

**v3.3.1 2016 年 09 月 18 日** 

* 增加机器人回复的图文聊天气泡
* 合并机器人回复图文气泡和评价按钮
* 修复已知问题

**v3.3.0 2016 年 08 月 19 日**

* 增加工单支持
* 增加询前表单
* 增加机器人图文消息支持
* 增加表情键盘
* **移除 iOS 6 支持**
* demo 工程处理了 iOS 10 中图片和相机申请权限的崩溃
* 修复已知问题

**v3.2.4 2016 年 08 月 1 日**

* 增加机器人未识别手动转人工

**v3.2.3 2016 年 07 月 22 日**

* 增加机器人自定义回复文案

**v3.2.2 2016 年 07 月 5 日**

* 增加图文消息显示的支持
* 修复部分问题
* 优化界面

**v3.2.1 2016 年 06 月 20 日**

* 支持排队功能
* 更新聊天输入界面
* 增加接收文件预览功能
* 修复问题

**v3.2.0 2016 年 05 月 30 日**

* 增加机器人客服
* 增加留言表单

**v3.1.9 2016 年 05 月 13 日**

* 聊天界面增加可交互转场动画
* 发送消息失败后，会提示客服下线
* 聊天界面优化
* 用户正在输入的提示请求，加一个发送限制
* 替换现有的图片全屏浏览组件
* 修改数据库结构，不再以版本号建库
* SDK 修改黑名单文案提示
* 聊天界面不定时在收到消息的时候会崩溃
* 增加导航栏标题文字字体的接口
* 修改导航栏左键接口

**v3.1.8 2016 年 04 月 22 日**

* 增加文件接收功能。
* 增加黑名单功能支持。
* 新增音频控制的接口。
* 新增界面主题，通过修改 chatViewStyle 的对应方法来定制聊天界面。
* 新增消息预发送的接口。
* 升级获取未读消息的接口。
* 修复聊天界面通过 push 显示的时候，没有调用 viewDidApear，viewWillApear，viewDidDisapper， viewWillDisappear。
* 修复在某些情况下聊天界面下方会出现黑条的问题。
* 修复在没有分配到客服的时候，不自动显示历史消息的问题。
* 修复客服不在线时，客服不在线提示没有自动滚动出现。
* 修复第二次进入聊天界面时，没有滚动到最下方的问题。
* 修复查看图片在横屏时无法正常显示的问题。
* 修复音频文件导致的调试断点问题。

**v3.1.7 2016 年 03 月 29 日**

* 解决单语言的项目获取不到 App 的基本信息的问题。
* 修复聊天界面从相册返回的时候界面上移的问题。
* 增加获取未读消息的接口。
* 修复在支持横屏的应用点击发送照片崩溃的问题。
* 修复断线重连的时候，如果客服状态改变了，客户端没有更新的问题。
* 修复客服转接后，客户名称没有正确更新。
* 修复图片，文字聊天气泡在旋转过后没有正确重绘。

**v3.1.6 2016 年 03 月 11 日**

* 解决横屏状态下，发送消息后没有滚动到底部的问题。
* 增加输入文字的缓存。

**v3.1.5 2016 年 03 月 09 日**

* 修改开源界面获取 Bundle 的方式，以支持 CocoaPods。
* 增加客服在线/隐身/离线状态

**v3.1.4 2016 年 03 月 02 日**

* 开源界面增加上传顾客自定义信息的接口，感谢 [dayuch](https://github.com/dayuch) 提交的 PR 。
* 更换提交客服评价后的表现形式。
* 增加录音模糊界面的开关接口。
* 更换新的发送/接收消息的提示音。

**v3.1.3 2016 年 02 月 25 日**

* 支持 Cocoapods. 感谢 [ttgb](https://github.com/ttgb) 的支持。
* 增加显示客服留言回复的功能。
* 修复使用自定义 id 上线后，第二次上线前获取不到数据库本地消息的问题。

**v3.1.2 2016 年 02 月 22 日**

* 修改第三方开源项目的类名，避免开发者和自己的项目冲突。

**v3.1.1 2016 年 02 月 17 日**

* 修复上传头像后，出现缺省头像的问题。
* 修复后端加密数据出错导致的 Crash 问题。
* 更新开源界面，方便开发者自定义导航栏的元素。

**v3.1.0 2016 年 01 月28 日**

* 增加客服评价功能。
* 修复 iOS 7 中打开系统相册后 Crash 的问题

**v3.0.9 2016 年 01 月 14 日**

* 聊天界面输入框的文字是多行时，保持输入框两侧按钮的位置在键盘上方。
* 重置 message 实体类中的 agentId 的值

**v3.0.8 2016 年 01 月 13 日**

* 增加「顾客上线」的接口描述。
* 增加「顾客上线成功」的广播。
* 对话没有结束情况下，如果客服隐身，仍然可以重新分配到该对话。
* 增加对服务端实体类型的容错。
* 顾客未上线，不进行下载顾客头像。
* 优化收到消息后，聊天界面滚动到底部的体验。

**v3.0.7 2016 年 01 月 11 日**

* 修复「断网重连，没有同步消息」的问题
* 修复使用新的自定义 id 上线，没有上报设备信息的问题
* 修复飞行模式下，发送失败的消息界面卡顿的问题

**v3.0.6 2016 年 01 月 06 日**

* 修复由于导航栏不透明导致的输入框下方有黑边问题。
* 增加指定分配客服、客服组接口的转接规则，即若指定分配的客服不在线时，如何转接。

**v3.0.5 2016 年 01 月 05 日**

* 重命名「开启/关闭美洽推送服务」为「开启/关闭美洽服务」，确保没有歧义
* 修改顾客自定义信息，以支持获取所有开发者上传的自定义信息

**v3.0.4 2015 年 12 月 31 日**

* 修复一些手机发送照片卡顿的问题。
* 复新建 client 情况下没有重新上传 deviceToken 的问题。

**v3.0.2 2015 年 12 月 30 日**

* 处理接口参数为 nil 的情况。
* 增加删除数据库 message 接口 removeMessageInDatabaseWithId 的结果回调。
* 修复上传自定义头像图片，聊天界面没有更新的问题。
* 上传 deviceToken 为字符串的形式。
