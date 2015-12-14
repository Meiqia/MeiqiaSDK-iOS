# 美洽移动应用 SDK 3.0 for iOS 开发文档

> 在您阅读此文档之前，我们假定您已经具备了基础的 iOS 应用开发经验，并能够理解相关基础概念。
> 如有疑问，欢迎加入 美洽 SDK 开发 QQ 群：295646206


## 目录
* [SDK 工作流程](#1-sdk-工作流程)
* [导入美洽 SDK](#2-导入美洽-sdk)
* [快速集成 SDK](#3-快速集成-sdk)
* [美洽开源聊天界面集成客服功能](#4-使用美洽开源聊天界面集成客服功能)
* [美洽 API 接口介绍](#5-美洽-api-接口介绍)
* [消息推送](#7-消息推送)
* [常见问题](#8-常见问题)

## 1. SDK 工作流程

美洽 SDK 的工作流程如下图所示。

![SDK工作流程图](https://s3.cn-north-1.amazonaws.com.cn/pics.meiqia.bucket/dd401360bac3d4ab)

说明：
* 自定义用户数据将会在美洽客服工作台上显示；
* 当打开美洽推送服务后，客服发送的消息，将会发送至开发者的推送服务器。如果开发者需要推送，请务必在美洽工作台中设置推送的服务器地址，请使用美洽管理员帐号登录[美洽](http://www.meiqia.com)，在「设置」-「SDK」中设置。

![设置推送地址](https://s3.cn-north-1.amazonaws.com.cn/pics.meiqia.bucket/8fbdaa6076d0b9d0)


## 2. 导入美洽 SDK

### 文件介绍

Demo中的文件 | 说明
---- | -----
MeiQiaSDK.framework | 美洽 SDK 的 framework 。
MQChatViewController/ | 美洽提供的开源聊天界面 Library，详细介绍请移步 [github](https://github.com/Meiqia/MQChatViewController) 。
[MeiqiaSDKViewInterface]() | 美洽的 SDK 逻辑接口层 与 开源聊天 Library 的中间层，调用美洽 SDK 的接口，完成界面所需的功能。

framework中的文件 | 说明
---- | -----
[MQManager.h]() | 美洽 SDK 提供的逻辑 API，开发者可调用其中的逻辑接口，实现自定义在线客服界面
[MCDefination.h]() | 美洽 SDK 所用的枚举分类
[MQAgent.h]() | 实体类：客服
[MQMessage.h]() | 实体类：消息


### 导入美洽 SDK

把美洽 SDK 文件夹中的`MeiQiaSDK.framework`和`MQChatViewController/`文件夹（选做）拷贝到新创建的工程路径下面，然后在工程目录结构中，右键选择 *Add Files to “工程名”* 。或者将这两个个文件拖入 XCode 工程目录结构中。


### 引入依赖库

美洽 SDK 的实现，依赖了一些系统框架，在开发应用时，要在工程里加入这些框架。开发者首先点击工程右边的工程名,然后在工程名右边依次选择 *TARGETS* -> *BuiLd Phases* -> *Link Binary With Libraries*，展开 *LinkBinary With Libraries* 后点击展开后下面的 *+* 来添加下面的依赖项:

- libsqlite3.dylib (Xcode 7以前) / libsqlite3.tbd (Xcode 7)
- libicucore.dylib (Xcode 7以前) / libicucore.tbd (Xcode 7)
- AVFoundation.framework
- CoreTelephony.framework
- SystemConfiguration.framework
- MobileCoreServices.framework


## 3. 快速集成 SDK
美洽开源了一套[聊天界面 Library](https://github.com/Meiqia/MQChatViewController)，帮助开发者快速生成聊天视图，并提供自定义接口，满足一定定制需求。


### 三分钟快速应用 SDK
如上所述，使用美洽 SDK ，必不可少的一步便是[初始化 SDK](#初始化-sdk)，完成初始化后便可操作 SDK 其他功能和接口，比如推出视图等。美洽提供的 UI 简化了开发流程，使得为 APP 添加客服功能最低仅需2行代码和一个info.plist配置：
```objc
//建议在AppDelegate.m中系统回调didFinishLaunchingWithOptions中增加
[MQManager initWithAppkey:@"开发者注册的App的AppKey" completion:^(NSString *clientId, NSError *error) {
}];
```

```objc
MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
[chatViewManager pushMQChatViewControllerInViewController:self];
```


#### info.plist设置
美洽的图片、语音等静态资源放在了 AWS S3 上，但 `s3.amazonaws.com` 使用了 SHA1 证书，不满足 iOS 9 的 [ATS (App Transport Security)](https://developer.apple.com/library/prerelease/ios/releasenotes/General/WhatsNewIniOS/Articles/iOS9.html#//apple_ref/doc/uid/TP40016198-SW14) 要求。

所以为了能让聊天界面正确显示图片和语音，开发者需要在 App 的 info.plist 中增加如下设置 (右键点击`info.plist` -> `Open As` -> `Source Code`):

```xml
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSAllowsArbitraryLoads</key>
	<true/>
	<key>NSExceptionDomains</key>
	<dict>
		<key>s3.cn-north-1.amazonaws.com.cn</key>
			<dict>
			<key>NSExceptionRequiresForwardSecrecy</key>
			<false/>
		</dict>
	</dict>
</dict>
```
添加完成后，info.plist显示效果如图：

![info.plist配置](https://s3.cn-north-1.amazonaws.com.cn/pics.meiqia.bucket/f4564c89cef713c1)

关于 S3 证书问题，可参考 stackoverflow 上面的一个[讨论](http://stackoverflow.com/questions/32500655/ios-9-app-download-from-amazon-s3-ssl-error-tls-1-2-support)。

**注意**，为了规避遗漏此项设置，如果开发者没有增加此项配置，SDK 是不会初始化成功的，xcode会打印错误提示。

至此，你已经为你的 APP 添加美洽提供的客服服务。而美洽 SDK 还提供其他强大的功能，可以帮助提高服务效率，提升用户使用体验。接下来为你详细介绍如何使用其他功能。

## 4. 使用美洽开源聊天界面集成客服功能

此小节介绍如何使用美洽的开源聊天界面快速集成客服功能。

### 初始化 SDK

**注意：**
* 所有操作都必须在初始化 SDK ，并且美洽服务端返回可用的 clientId 后才能正常执行。

开发者在美洽工作台注册 App 后，可获取到一个可用的 AppKey。在 `AppDelegate.m` 的系统回调 `didFinishLaunchingWithOptions` 中调用初始化 SDK 接口：

```objc
[MQManager initWithAppkey:@"开发者注册的App的AppKey" completion:^(NSString *clientId, NSError *error) {
}];
```

如果您不知道 *AppKey* ，请使用美洽管理员帐号登录[美洽](http://www.meiqia.com)，在「设置」 -> 「SDK」 菜单中查看。如下图：

![美洽 AppKey 查看界面图片](https://s3.cn-north-1.amazonaws.com.cn/pics.meiqia.bucket/5a999b67233e77dc)


### 上传设备的 deviceToken

App 进入后台后，美洽推送给开发者服务端的消息数据格式中，会有 deviceToken 的字段。

将下列代码添加到 `AppDelegate.m` 中系统回调 `didRegisterForRemoteNotificationsWithDeviceToken` 中：
```objc
[MQManager registerDeviceToken:deviceToken];
```

美洽推送消息给开发者服务端的数据格式，可参考[推送消息数据结构](#推送消息数据结构)。


### 添加自定义信息
功能效果展示：

![美洽工作台顾客自定义信息图片]()

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
[MQManager setClientInfo:clientCustomizedAttrs completion:^(BOOL success) {
}];
```

以下字段是美洽定义好的，开发者可通过上方提到的接口，直接对下方的字段进行设置：

|Key|说明|
|---|---|
|name|真实姓名|
|sex|性别|
|age|年龄|
|job|职业|
|avatar|头像URL|
|comment|备注|
|tel|电话|
|email|邮箱|
|address|地址|
|qq|QQ号|
|weibo|微博ID|
|weixin|微信号|


### 指定分配客服和客服组

美洽默认会按照管理员设置的分配方式智能分配客服，但如果需要让来自 App 的顾客指定分配给某个客服或者某组客服，需要在上线前添加以下代码：

如果您使用美洽提供的 UI ，可对 UI 进行如下配置，进行指定分配：

```objc
MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
[chatViewManager setScheduledAgentToken:agentToken];
```

如果您自定义 UI，可直接使用如下美洽 SDK 逻辑接口：

```objc
//分配到指定客服，或指定组里面的客服，指定客服优先级高
[MQManager setScheduledAgentWithAgentToken:agentToken agentGroupToken:agentGroupToken];
```

**注意**
* 该选项需要在用户上线前设置。
* 客服组 token 和客服 token 可以通过管理员帐号在后台的「设置」中查看。
![查看ID](https://s3.cn-north-1.amazonaws.com.cn/pics.meiqia.bucket/8cde8b54491c203e)


### 调出视图
美洽开源了一套[聊天界面 Library](https://github.com/Meiqia/MQChatViewController)，完成了一整套 `MQManager` 中的接口。让开发者免去 UI 开发工作。并在 `MQChatViewController` 类中添加其他自定义选项和功能扩展。

你只需要在用户需要客服服务的时候，推出美洽 UI。如下所示：

```objc
//当用户需要使用客服服务时，创建并推出视图
MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
[chatViewManager pushMQChatViewControllerInViewController:self];
```

**注意**，如果这样不对 `MQChatViewManager` 进行任何配置直接调出视图，实际上是用美洽 初始化SDK后的顾客进行上线。如果开发者需要指定顾客上线，可参考:

[设置登录客服的开发者自定义 id](#设置登录客服的开发者自定义-id)

[设置登录客服的顾客 id](#设置登录客服的顾客-id)

`MQServiceToViewInterface` 文件是开源聊天界面调用美洽 SDK 接口的中间层，目的是剥离开源界面中的美洽业务逻辑。这样就能让该聊天界面用于非美洽项目中，开发者只需要实现 `MQServiceToViewInterface` 中的方法，即可将自己项目的业务逻辑和该聊天界面对接。

**更多开源聊天界面 Library 详细介绍和使用方法，请移步 [github](https://github.com/Meiqia/MQChatViewController)。**


### 配置开源 UI 实现更多客服功能
下面介绍开源 UI 中的美洽逻辑的配置，开发者可根据需求对其进行配置，再调出聊天视图。

#### 开启同步服务端消息设置

如果开启消息同步，在聊天界面中下拉刷新，将会获取服务端的历史消息；

如果关闭消息同步，则是获取本机数据库中的历史消息；

由于顾客可能在多设备聊天，关闭消息同步后获取的历史消息，将可能少于服务端的历史消息。
```objc
MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
//开启同步消息
[chatViewManager enableSyncServerMessage:true];
[chatViewManager pushMQChatViewControllerInViewController:self];
```


#### 指定分配客服和客服组设置

上文已有介绍，请参考[指定分配客服和客服组](#指定分配客服和客服组)。


#### 设置登录客服的开发者自定义 id

设置开发者自定义 id 后，将会以该自定义 id 对应的顾客上线。

**注意**，如果美洽服务端没有找到该自定义 id 对应的顾客，则美洽将会自动关联该 id 与 SDK 当前的顾客。
```objc
MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
[chatViewManager setLoginCustomizedId:customizedId];
[chatViewManager pushMQChatViewControllerInViewController:self];
```

使用该接口，可让美洽绑定开发者的用户系统和美洽的顾客系统。

**注意**，如果开发者的自定义 id 是自增长，美洽建议开发者服务端保存美洽顾客 id，登陆时[设置登录客服的顾客 id](#设置登录客服的顾客-id)，否则非常容易受到中间人攻击。


#### 设置登录客服的顾客 id

设置美洽顾客的 id 后，该id对应的顾客将会上线。
```objc
MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
[chatViewManager setLoginMQClientId:clientId];
[chatViewManager pushMQChatViewControllerInViewController:self];
```

**注意**，如果美洽服务端没有找到该顾客 id 对应的顾客，则会返回`该顾客不存在`的错误。

开发者需要获取 clientId，可使用接口`[MQManager getCurrentClientId]`。


#### 国际化

请参考[美洽开源聊天界面的国际化说明](https://github.com/Meiqia/MQChatViewController#localization---国际化本地化)。

更多配置，可参见 [MQChatViewManager.h](https://github.com/Meiqia/MQChatViewController/blob/master/MQChatViewControllerDemo/MQChatViewController/Config/MQChatViewManager.h) 文件。

## 5. 美洽 API 接口介绍

**本节主要介绍部分重要的接口。在`MeiqiaSDK.framework`的`MQManager.h`中，所有接口都有详细注释。**

开发者可使用美洽提供的API，自行定制聊天界面。使用以下接口前，别忘了[初始化 SDK](#初始化-sdk)。


### 接口描述

#### 初始化SDK

美洽建议开发者在 `AppDelegate.m` 的系统回调 `didFinishLaunchingWithOptions` 中，调用初始化 SDK 接口。这是因为第一次初始化美洽 SDK，SDK 会向美洽服务端发送一个初始化顾客的请求，SDK 其他接口都必须是在初始化 SDK 成功后进行，所以 App 应尽早初始化 SDK 。
```objc
//建议在AppDelegate.m系统回调didFinishLaunchingWithOptions中增加
[MQManager initWithAppkey:@"开发者注册的App的AppKey" completion:^(NSString *clientId, NSError *error) {
}];
```


#### 注册设备的 deviceToken

美洽需要获取每个设备的 deviceToken，才能在 App 进入后台以后，推送消息给开发者的服务端。消息数据中有 deviceToken 字段，开发者获取到后，可通知 APNS 推送给该设备。

在 AppDelegate.m中的系统回调 `didRegisterForRemoteNotificationsWithDeviceToken` 中，调用上传 deviceToken 接口：
```objc
[MQManager registerDeviceToken:deviceToken];
```

#### 关闭美洽推送

详细介绍请见[消息推送](#7-消息推送)。


#### 指定分配客服和客服组接口

该接口上文已有介绍，请见 [指定分配客服和客服组](#指定分配客服和客服组)。


#### 让当前的顾客上线。

初始化 SDK 成功后，SDK 中有一个可使用的顾客 id，调用该接口即可让其上线，如下代码：
```objc
[MQManager setCurrentClientOnlineWithCompletion:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
//可根据result来判断是否上线成功
} receiveMessageDelegate:self];
```


#### 根据美洽的顾客 id，登陆美洽客服系统，并上线该顾客。

开发者可通过[获取当前顾客 id](#获取当前顾客-id) 接口，取得顾客 id ，保存到开发者的服务端，以此来绑定美洽顾客和开发者用户系统。
如果开发者保存了美洽的顾客 id，可调用如下接口让其上线。调用此接口后，当前可用的顾客即为开发者传的顾客 id。
```objc
[MQManager setClientOnlineWithClientId:clientId completion:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
//可根据result来判断是否上线成功
} receiveMessageDelegate:self];
```


#### 根据开发者自定义的 id，登陆美洽客服系统，并上线该顾客。

如果开发者不愿保存美洽顾客 id，来绑定自己的用户系统，也将用户 id当做参数，进行顾客的上线，美洽将会为开发者绑定一个顾客，下次开发者直接调用如下接口，就能让这个绑定的顾客上线。

调用此接口后，当前可用的顾客即为该自定义 id 对应的顾客 id。

**特别注意：**传给美洽的自定义 id 不能为自增长的，否则非常容易受到中间人攻击，此情况的开发者建议保存美洽顾客 id。
```objc
[MQManager setClientOnlineWithCustomizedId:customizedId completion:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
//可根据result来判断是否上线成功
} receiveMessageDelegate:self];
```


#### 获取当前顾客 id

开发者可通过此接口接口，取得顾客 id，保存到开发者的服务端，以此来绑定美洽顾客和开发者用户系统。
```objc
NSString *clientId = [MQManager getCurrentClientId];
```


#### 创建一个新的顾客

如果开发者想初始化一个新的顾客，可调用此接口。

该顾客没有任何历史记录及用户信息。

开发者可选择将该 id 保存并与 App 的用户绑定。
```objc
[MQManager createClient:^(BOOL success, NSString *clientId) {
//开发者可保存该clientId
}];
```


#### 设置顾客离线

```objc
NSString *clientId = [MQManager setClientOffline];
```

如果没有设置顾客离线，开发者设置的代理将收到即时消息，并收到新消息产生的广播。开发者可以监听此 notification，用于显示小红点未读标记。

如果设置了顾客离线，则客服发送的消息将会发送给开发者的服务端。

`美洽建议`，顾客推出聊天界面时，不设置顾客离线，这样开发者仍能监听到收到消息的广播，以便提醒顾客有新消息。


#### 监听收到消息的广播

开发者可在合适的地方，监听收到消息的广播，用于提醒顾客有新消息。

**注意**，如果顾客推出聊天界面，开发者没有调用设置顾客离线接口的话，以后该顾客收到新消息，仍能收到`有新消息的广播`。
```objc
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMeiqiaMessage) name:MQ_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil];
```


#### 获取当前正在接待的客服信息

开发者可用此接口获取当前正在接待顾客的客服信息：
```objc
MQAgent *agent = [MQManager getCurrentAgent];
```


#### 添加自定义信息

添加自定义信息操作和上述相同，跳至 [添加自定义信息](#添加自定义信息)。


#### 从服务端获取更多消息

开发者可用此接口获取服务端的历史消息：
```objc
[MQManager getServerHistoryMessagesWithUTCMsgDate:firstMessageDate messagesNumber:messageNumber success:^(NSArray<MQMessage *> *messagesArray) {
//显示获取到的消息等逻辑
} failure:^(NSError *error) {
//进行错误处理
}];
```

**注意**，服务端的历史消息是该顾客在**所有平台上**产生的消息，包括网页端、Android SDK、iOS SDK、微博、微信，可在聊天界面的下拉刷新处调用。


#### 从本地数据库获取历史消息

由于使用[从服务端获取更多消息](#从服务端获取更多消息)接口，会产生数据流量，开发者也可使用此接口来获取 iOS SDK 本地的历史消息。

```objc
[MQManager getDatabaseHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:messageNumber result:^(NSArray<MQMessage *> *messagesArray) {
//显示获取到的消息等逻辑
}];
```

**注意**，由于没有同步服务端的消息，所以本地数据库的历史消息有可能少于服务端的消息。

#### 接收即时消息

开发者可能注意到了，使用上面提到的3个顾客上线接口，都有一个参数是`设置接收消息的代理`，开发者可在此设置接收消息的代理，由代理来接收消息。

设置代理后，实现 `MQManagerDelegate` 中的 `didReceiveMQMessage:` 方法，即可通过这个代理函数接收消息。


#### 发送消息

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

**注意**,调用发送消息接口后，回调中会返回一个消息实体，开发者可根据此消息的状态，来判断该条消息是发送成功还是发送失败。


## 6. SDK 中嵌入美洽 SDK
如果你的开发项目也是 SDK，那么在了解常规 App 嵌入美洽 SDK 的基础上，还需要注意其他事项。

与 App 嵌入美洽 SDK 的步骤相同，需要 导入美洽 SDK -\> 引入依赖库 -\> 初始化 SDK -\> 使用美洽 SDK。

如果开发者使用了美洽提供的聊天界面，还需要公开素材包：

开发者点击工程右边的工程名,然后在工程名右边依次选择 *TARGETS* -\> *BuiLd Phases* -\> *Copy Files* ，展开 *Copy Files* 后点击展开后下面的 *+* 来添加美洽素材包 `MQChatViewAsset.bundle`。

在之后发布你的 SDK 时，将 `MQChatViewAsset.bundle` 一起打包即可。


## 7. 消息推送

当前仅支持一种推送方案，即美洽服务端发送消息至开发者的服务端，开发者再推送消息到 App，可见 [SDK 工作流程](#SDK-工作流程) 。

未来美洽 iOS SDK 将会支持直接推送消息给 App，即开发者可上传 App 的推送证书至美洽，美洽将推送消息至苹果 APNS 服务器。目前正在紧张开发中。

#### 设置接收推送的服务器地址

推送消息将会发送至开发者的服务器。

设置服务器地址，请使用美洽管理员帐号登录[美洽](http://www.meiqia.com)，在「设置」 -\> 「SDK」中设置。
![设置推送地址](https://s3.cn-north-1.amazonaws.com.cn/pics.meiqia.bucket/8fbdaa6076d0b9d0)


#### 通知美洽服务端发送消息至开发者的服务端

目前，美洽的推送是通过推送消息给开发者提供的 URL 上来实现的。

在 App 进入后台时，应该通知美洽服务端，让其将以后的消息推送给开发者提供的服务器地址。

开发者需要在 `AppDelegate.m` 的系统回调 `applicationDidEnterBackground` 调用打开美洽推送的接口，如下代码：
```objc
- (void)applicationDidEnterBackground:(UIApplication *)application {
	[MQManager openMeiQiaRemotePushService];
}
```

#### 关闭美洽推送

在 App 进入前台时，应该通知美洽服务端，让其将以后的消息发送给SDK，而不再推送给开发者提供的服务端。

开发者需要在 `AppDelegate.m` 的系统回调 `applicationWillEnterForeground` 调用关闭美洽推送的接口，如下代码：
```objc
- (void)applicationWillEnterForeground:(UIApplication *)application {
	[MQManager closeMeiQiaRemotePushService];
}
```


##### 推送消息数据结构 (待补充)

当有消息需要推送时，美洽服务器会向开发者设置的服务器地址发送推送消息，方法类型为 *POST*，数据格式为 *JSON* 。


## 8. 常见问题

- [SDK 初始化失败](#sdk-初始化失败)
- [Xcode Warning: was built for newer iOS version (7.0) than being linked (6.0)](#xcode-warning-was-built-for-newer-ios-version-70-than-being-linked-60)

### SDK 初始化失败

#### 1. 美洽的 AppKey 版本不正确
当前SDK是为美洽3.0提供服务，如果你使用的 AppKey 是美洽2.0的，请使用美洽2.0 SDK

#### 2. 没有配置 NSExceptionDomains
如果没有配置`NSExceptionDomains`，美洽SDK会返回`MQErrorCodePlistConfigurationError`，并且在控制台中打印：`!!!美洽 SDK Error：请开发者在 App 的 info.plist 中增加 NSExceptionDomains，具体操作方法请见「https://github.com/Meiqia/MeiqiaSDK-iOS#info.plist设置」`。如果出现上诉情况，请[配置NSExceptionDomains](#infoplist设置)

#### 3. 网络异常
如果上诉情况均不存在，请检查引入美洽SDK的设备的网络是否通畅

### Xcode Warning: was built for newer iOS version (7.0) than being linked (6.0)

如果开发者的App最低支持系统是7.0一下，将会出现这种waring。

`ld: warning: object file (/Meiqia-SDK-Demo/MQChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/libopencore-amrnb.a(wrapper.o)) was built for newer iOS version (7.0) than being linked (6.0)`

原因是美洽将SDK中使用的开源库 [opencore-amr](http://sourceforge.net/projects/opencore-amr/) 针对支持Bitcode而从新编译了一次，但这并不影响SDK在iOS 6中的使用。如果你介意，并且不会使用Bitcode，可以将美洽SDK中使用`opencore-amr`替换为老版本：[传送门](https://github.com/molon/MLAudioRecorder/tree/master/MLRecorder/MLAudioRecorder/amr_en_de/lib)

