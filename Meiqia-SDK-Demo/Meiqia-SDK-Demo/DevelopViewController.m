//
//  DevelopViewController.m
//  MQEcoboostSDK-test
//
//  Created by ijinmao on 15/12/3.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "DevelopViewController.h"
#import "MQChatViewManager.h"
#import <MeiQiaSDK/MQManager.h>
#import "MQAssetUtil.h"
#import "MQToast.h"

#define MQ_DEMO_ALERTVIEW_TAG 3000

typedef enum : NSUInteger {
    MQSDKDemoManagerClientId = 0,
    MQSDKDemoManagerCustomizedId,
    MQSDKDemoManagerAgentId,
    MQSDKDemoManagerGroupId,
    MQSDKDemoManagerClientAttrs,
    MQSDKDemoManagerClientOffline,
    MQSDKDemoManagerEndConversation
} MQSDKDemoManager;

static CGFloat   const kMQSDKDemoTableCellHeight = 56.0;
static NSString *kSwitchShowUnreadMessageCount = @"kSwitchShowUnreadMessageCount";


@interface DevelopViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@end

@implementation DevelopViewController{
    UITableView *configTableView;
    NSArray *sectionHeaders;
    NSArray *sectionTextArray;
    NSString *currentClientId;
    NSDictionary *clientCustomizedAttrs;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    sectionHeaders = @[
                       @"以下是开发者可能会用到的客服功能，请参考^.^",
                       @"以下是开源界面的不同的设置"
                       ];
    
    sectionTextArray = @[
                         @[
                             @"使用当前的顾客 id 上线，并同步消息",
                             @"输入美洽顾客 id 进行上线",
                             @"输入自定义 id 进行上线",
                             @"查看当前美洽顾客 id",
                             @"建立一个全新美洽顾客 id 账号",
                             @"输入一个客服 id 进行指定分配",
                             @"输入一个客服组 id 进行指定分配",
                             @"上传该顾客的自定义信息",
                             @"设置当前顾客为离线状态",
                             @"结束当前对话",
                             @"删除所有美洽多媒体存储",
                             @"删除本地数据库中的消息",
                             @"查看当前 SDK 版本号",
                             @"当前的美洽顾客 id 为：(点击复制该顾客 id )",
                             @"显示当前未读的消息数"],
                         @[
                             @"自定义主题 1",
                             @"自定义主题 2",
                             @"自定义主题 3",
                             @"自定义主题 4",
                             @"自定义主题 5",
                             @"自定义主题 6",
                             @"系统主题 MQChatViewStyleTypeBlue",
                             @"系统主题 MQChatViewStyleTypeGreen",
                             @"系统主题 MQChatViewStyleTypeDark",
                             ]
                         ];
    
    clientCustomizedAttrs = @{
                              @"name"       :   @"Kobe Bryant",
                              @"avatar"     :   @"https://s3.cn-north-1.amazonaws.com.cn/pics.meiqia.bucket/07eaa42f339963e9",
                              @"gender"     :   @"男",
                              @"身高"         :    @"1.98m",
                              @"体重"         :    @"93.0kg",
                              @"效力球队"      :    @"洛杉矶湖人队",
                              @"场上位置"      :    @"得分后卫",
                              @"球衣号码"      :    @"24号",
                              @"comment"     :     @"这是一个备注",
                              @"tags"        :     @[@"重要顾客", @"无效标签"]
                              };
    
    [self initNavBar];
    [self initTableView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //等待sdk初始化成功
        currentClientId = [MQManager getCurrentClientId];
        [configTableView reloadData];
    });
    
    //在聊天界面外，监听是否收到了客服消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMQMessages:) name:MQ_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    currentClientId = [MQManager getCurrentClientId];
    [configTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavBar {
    self.navigationItem.title = @"美洽SDK";
}

- (void)initTableView {
    configTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    configTableView.delegate = self;
    configTableView.dataSource = self;
    [self.view addSubview:configTableView];
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kMQSDKDemoTableCellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self setCurrentClientOnline];
                break;
            case 1:
                [self inputClientId];
                break;
            case 2:
                [self inputCustomizedId];
                break;
            case 3:
                [self getCurrentClientId];
                break;
            case 4:
                [self creatMQClient];
                break;
            case 5:
                [self inputScheduledAgentId];
                break;
            case 6:
                [self inputScheduledGroupId];
                break;
            case 7:
                [self showSetClientAttributesAlertView];
                break;
            case 8:
                [self showSetClientOfflineAlertView];
                break;
            case 9:
                [self showEndConversationAlertView];
                break;
            case 10:
                [self removeMeiqiaMediaData];
                break;
            case 11:
                [self removeAllMesagesFromDatabase];
                break;
            case 12:
                [self getMeiqiaSDKVersion];
                break;
            case 13:
                [self copyCurrentClientIdToPasteboard];
                break;
            case 14:
                [self showUnreadMessageCount:[tableView cellForRowAtIndexPath:indexPath]];
            default:
                break;
        }
        return;
    }
    switch (indexPath.row) {
        case 0:
            [self chatViewStyle1];
            break;
        case 1:
            [self chatViewStyle2];
            break;
        case 2:
            [self chatViewStyle3];
            break;
        case 3:
            [self chatViewStyle4];
            break;
        case 4:
            [self chatViewStyle5];
            break;
        case 5:
            [self chatViewStyle6];
            break;
        case 6:
            [self systemStyleBlue];
            break;
        case 7:
            [self systemStyleGreen];
            break;
        case 8:
            [self systemStyleDark];
            break;
        default:
            break;
    }
}

#pragma UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [sectionHeaders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[sectionTextArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *textArray = [sectionTextArray objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[textArray objectAtIndex:indexPath.row]];
    if (!cell){
        if (indexPath.row + 1 == [textArray count] && indexPath.section == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[textArray objectAtIndex:indexPath.row]];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[textArray objectAtIndex:indexPath.row]];
        }
    }
    
    cell.accessoryView = nil;
    cell.detailTextLabel.text = nil;
    if (indexPath.row + 2 == [textArray count] && indexPath.section == 0) {
        cell.detailTextLabel.text = currentClientId;
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = [UIColor darkTextColor];
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = [UIColor darkTextColor];
    }
    cell.textLabel.text = [textArray objectAtIndex:indexPath.row];
    return cell;
}

/**
 *  当前顾客id上线
 */
- (void)setCurrentClientOnline {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    //开启同步消息
    [chatViewManager enableSyncServerMessage:true];
    [chatViewManager.chatViewStyle setEnableOutgoingAvatar:false];
    [chatViewManager pushMQChatViewControllerInViewController:self];
}

/**
 *  输入顾客id
 */
- (void)inputClientId {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入美洽顾客id" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerClientId;
    [alertView show];
}

/**
 *  使用顾客id上线
 *
 *  @param clientId 顾客id
 */
- (void)setClientOnlineWithClientId:(NSString *)clientId {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager setLoginMQClientId:clientId];
    [chatViewManager.chatViewStyle setEnableOutgoingAvatar:false];
    [chatViewManager presentMQChatViewControllerInViewController:self];
}

/**
 *  输入开发者自定义id
 */
- (void)inputCustomizedId {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入自定义Id进行上线" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerCustomizedId;
    [alertView show];
}

/**
 *  使用自定义id上线
 *
 *  @param customizedId 自定义id
 */
- (void)setClientOnlineWithCustomizedId:(NSString *)customizedId {
    [MQManager initWithAppkey:@"44e9a76b103e840a310a6e326c404f80" completion:^(NSString *clientId, NSError *error) {
        if (!error) {
            MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
            [chatViewManager setLoginCustomizedId:customizedId];
            [chatViewManager setScheduledAgentId:@"b51d1028f8fdfc0a708076e504d10c2f"];
            [chatViewManager pushMQChatViewControllerInViewController:self];
        }
    }];
}

/**
 *  获取当前顾客id
 */
- (void)getCurrentClientId {
    NSString *clientId = [MQManager getCurrentClientId];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"当前的美洽顾客id为：" message:clientId delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alertView show];
}

/**
 *  创建一个新的顾客
 */
- (void)creatMQClient {
    [MQManager createClient:^(NSString *clientId, NSError *error) {
        if (!error) {
            NSLog(@"新的美洽顾客id为%@", clientId);
            currentClientId = clientId;
            [configTableView reloadData];
            NSString *clientId = [MQManager getCurrentClientId];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新的美洽顾客id为：" message:clientId delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alertView show];
        } else {
            NSLog(@"新建美洽client失败");
        }
    }];
}

/**
 *  输入指定分配客服的Id
 */
- (void)inputScheduledAgentId {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入一个客服Id进行指定分配" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerAgentId;
    [alertView show];
}

/**
 *  指定分配到某客服
 *
 *  @param agentId 客服Id
 */
- (void)setClientOnlineWithAgentId:(NSString *)agentId {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager setScheduledAgentId:agentId];
    [chatViewManager pushMQChatViewControllerInViewController:self];
}

/**
 *  输入指定分配客服组的Id
 */
- (void)inputScheduledGroupId {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入一个客服组Id进行指定分配" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerGroupId;
    [alertView show];
}

/**
 *  指定分配到某客服组
 *
 *  @param groupId 客服组Id
 */
- (void)setClientOnlineWithGroupId:(NSString *)groupId {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager setScheduledGroupId:groupId];
//    [chatViewManager setScheduleLogicWithRule:MQChatScheduleRulesRedirectNone];
    [chatViewManager pushMQChatViewControllerInViewController:self];
}

/**
 *  显示 设置顾客离线 的alertView
 */
- (void)showSetClientOfflineAlertView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"设置当前顾客离线吗？" message:@"美洽建议，退出聊天界面，不需要让顾客离线，这样 SDK 还能接收客服发送的消息。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerClientOffline;
    [alertView show];
}

/**
 *  主动设置当前顾客离线。美洽建议，退出聊天界面，不需要让顾客离线，这样 SDK 还能接收客服发送的消息
 */
- (void)setCurrentClientOffline {
    [MQManager setClientOffline];
}

- (void)showEndConversationAlertView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"结束当前对话吗？" message:@"美洽建议，让美洽后台自动超时结束对话，否则结束对话后，顾客得重新分配客服，建了一个新的客服对话。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerEndConversation;
    [alertView show];
}

/**
 *  主动结束当前对话。美洽建议，让美洽后台自动超时结束对话，否则结束对话后，顾客得重新分配客服，建了一个新的客服对话。
 */
- (void)endCurrentConversation {
    [MQManager endCurrentConversationWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [MQToast showToast:@"对话已结束" duration:1.0 window:self.view];
        } else {
            [MQToast showToast:@"对话结束失败" duration:1.0 window:self.view];
        }
    }];
}

/**
 *  删除美洽多媒体存储
 */
- (void)removeMeiqiaMediaData {
    [MQManager removeAllMediaDataWithCompletion:^(float mediaSize) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"已为您移除多媒体存储，共 %f M", mediaSize] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
    }];
}

/**
 *  删除本地数据库中的消息
 */
- (void)removeAllMesagesFromDatabase {
    [MQManager removeAllMessageFromDatabaseWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"已删除本地数据库中的消息" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"抱歉，删除本地数据库消息失败了>.<" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)getMeiqiaSDKVersion {
    NSString *sdkVersion = [MQManager getMeiQiaSDKVersion];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"当前美洽 SDK 版本号为：%@", sdkVersion] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alertView show];
}

/**
 *  复制当前顾客id到剪切板
 */
- (void)copyCurrentClientIdToPasteboard {
    [UIPasteboard generalPasteboard].string = currentClientId;
    [MQToast showToast:@"已复制" duration:0.5 window:self.view];
}

/**
 *  显示用户退出应用后收到的未读消息数的开关
 */
- (void)switchShowUnreadMessageCount {
    [[NSUserDefaults standardUserDefaults]setObject:@(![self.class shouldShowUnreadMessageCount]) forKey:kSwitchShowUnreadMessageCount];
    [configTableView reloadData];
}

+ (BOOL)shouldShowUnreadMessageCount {
    return [[[NSUserDefaults standardUserDefaults]objectForKey:kSwitchShowUnreadMessageCount] boolValue];
}

- (void)showUnreadMessageCount:(UITableViewCell *)cell {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [indicator startAnimating];
    [cell setAccessoryView:indicator];
    
    [MQServiceToViewInterface getUnreadMessagesWithCompletion:^(NSArray *messages, NSError *error) {
        [indicator stopAnimating];
        cell.accessoryView = nil;
        UIAlertView *alert = [UIAlertView new];
        alert.title = @"未读消息";
        alert.message = [NSString stringWithFormat:@"未读消息数为: %d",(int)messages.count];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }];
}

/**
 *  显示顾客的属性
 */
- (void)showSetClientAttributesAlertView {
    NSString *attrs = [NSString stringWithCString:[clientCustomizedAttrs.description cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"上传下列属性吗？" message:attrs delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerClientAttrs;
    [alertView show];
}

/**
 *  上传顾客的属性
 */
- (void)uploadClientAttributes {
    [MQManager setClientInfo:clientCustomizedAttrs completion:^(BOOL success, NSError *error) {
        NSString *alertString = @"上传顾客自定义信息成功~";
        NSString *message = @"您可前往美洽工作台，查看该顾客的信息是否有修改";
        if (!success) {
            alertString = @"上传顾客自定义信息失败";
            message = @"请检查当前的美洽顾客id是否还没有显示出来(红色字体)，没有显示出即表示没有成功初始化SDK";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertString message:message delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
    }];
}

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        switch (alertView.tag) {
            case MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerClientId:
                [self setClientOnlineWithClientId:[alertView textFieldAtIndex:0].text];
                break;
            case MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerCustomizedId:
                [self setClientOnlineWithCustomizedId:[alertView textFieldAtIndex:0].text];
                break;
            case MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerAgentId:
                [self setClientOnlineWithAgentId:[alertView textFieldAtIndex:0].text];
                break;
            case MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerGroupId:
                [self setClientOnlineWithGroupId:[alertView textFieldAtIndex:0].text];
                break;
            case MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerClientAttrs:
                [self uploadClientAttributes];
                break;
            case MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerClientOffline:
                [self setCurrentClientOffline];
                break;
            case MQ_DEMO_ALERTVIEW_TAG + (int)MQSDKDemoManagerEndConversation:
                [self endCurrentConversation];
                break;
            default:
                break;
        }
    }
}

/**
 *  开发者这样配置可：底部按钮、修改气泡颜色、文字颜色、使头像设为圆形
 */
- (void)chatViewStyle1 {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    UIImage *photoImage = [UIImage imageNamed:@"MQMessageCameraInputImageNormalStyleTwo"];
    UIImage *photoHighlightedImage = [UIImage imageNamed:@"MQMessageCameraInputHighlightedImageStyleTwo"];
    UIImage *voiceImage = [UIImage imageNamed:@"MQMessageVoiceInputImageNormalStyleTwo"];
    UIImage *voiceHighlightedImage = [UIImage imageNamed:@"MQMessageVoiceInputHighlightedImageStyleTwo"];
    UIImage *keyboardImage = [UIImage imageNamed:@"MQMessageTextInputImageNormalStyleTwo"];
    UIImage *keyboardHighlightedImage = [UIImage imageNamed:@"MQMessageTextInputHighlightedImageStyleTwo"];
    UIImage *resightKeyboardImage = [UIImage imageNamed:@"MQMessageKeyboardDownImageNormalStyleTwo"];
    UIImage *resightKeyboardHighlightedImage = [UIImage imageNamed:@"MQMessageKeyboardDownHighlightedImageStyleTwo"];
    UIImage *avatar = [UIImage imageNamed:@"ijinmaoAvatar"];
    
    MQChatViewStyle *chatViewStyle = [chatViewManager chatViewStyle];
    
    [chatViewStyle setPhotoSenderImage:photoImage];
    [chatViewStyle setPhotoSenderHighlightedImage:photoHighlightedImage];
    [chatViewStyle setVoiceSenderImage:voiceImage];
    [chatViewStyle setVoiceSenderHighlightedImage:voiceHighlightedImage];
    [chatViewStyle setKeyboardSenderImage:keyboardImage];
    [chatViewStyle setKeyboardSenderHighlightedImage:keyboardHighlightedImage];
    [chatViewStyle setResignKeyboardImage:resightKeyboardImage];
    [chatViewStyle setResignKeyboardHighlightedImage:resightKeyboardHighlightedImage];
    [chatViewStyle setIncomingBubbleColor:[UIColor redColor]];
    [chatViewStyle setIncomingMsgTextColor:[UIColor whiteColor]];
    [chatViewStyle setOutgoingBubbleColor:[UIColor yellowColor]];
    [chatViewStyle setOutgoingMsgTextColor:[UIColor darkTextColor]];
    [chatViewStyle setEnableRoundAvatar:true];
    
    [chatViewManager setoutgoingDefaultAvatarImage:avatar];
    [chatViewManager pushMQChatViewControllerInViewController:self];
}

/**
 *  开发者这样配置可：是否支持发送语音、是否显示本机头像、修改气泡的样式
 */
- (void)chatViewStyle2 {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    UIImage *incomingBubbleImage = [UIImage imageNamed:@"MQBubbleIncomingStyleTwo"];
    UIImage *outgoingBubbleImage = [UIImage imageNamed:@"MQBubbleOutgoingStyleTwo"];
    CGPoint stretchPoint = CGPointMake(incomingBubbleImage.size.width / 2.0f - 4.0, incomingBubbleImage.size.height / 2.0f);
    [chatViewManager enableSendVoiceMessage:false];
    [chatViewManager setIncomingMessageSoundFileName:@""];
    
    MQChatViewStyle *chatViewStyle = [chatViewManager chatViewStyle];
    
    [chatViewStyle setEnableOutgoingAvatar:false];
    [chatViewStyle setIncomingBubbleImage:incomingBubbleImage];
    [chatViewStyle setOutgoingBubbleImage:outgoingBubbleImage];
    [chatViewStyle setIncomingBubbleColor:[UIColor yellowColor]];
    [chatViewStyle setBubbleImageStretchInsets:UIEdgeInsetsMake(stretchPoint.y, stretchPoint.x, incomingBubbleImage.size.height-stretchPoint.y+0.5, stretchPoint.x)];
    [chatViewManager pushMQChatViewControllerInViewController:self];
}

/**
 *  开发者这样配置可：增加可点击链接的正则表达式( Library 本身已支持多种格式链接，如未满足需求可增加)、增加欢迎语、是否开启消息声音、修改接受消息的铃声
 */
- (void)chatViewStyle3 {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager setIncomingMessageSoundFileName:@"MQNewMessageRingStyleTwo.wav"];
    [chatViewManager setMessageLinkRegex:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"];
    [chatViewManager enableChatWelcome:true];
    [chatViewManager setChatWelcomeText:@"你好，请问有什么可以帮助到您？"];
    [chatViewManager enableMessageSound:true];
    [chatViewManager pushMQChatViewControllerInViewController:self];
    
}

/**
 *  如果 tableView 没有在底部，开发者这样可打开消息的提示
 */
- (void)chatViewStyle4 {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager enableShowNewMessageAlert:true];

    [chatViewManager pushMQChatViewControllerInViewController:self];
}

/**
 *  开发者这样配置可：是否支持下拉刷新、修改下拉刷新颜色、增加导航栏标题
 */
- (void)chatViewStyle5 {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager enableTopPullRefresh:true];
    [chatViewManager.chatViewStyle setPullRefreshColor:[UIColor redColor]];
    [chatViewManager.chatViewStyle setNavBarTintColor:[UIColor blueColor]];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.backgroundColor = [UIColor redColor];
    rightButton.frame = CGRectMake(10, 10, 20, 20);
    [chatViewManager.chatViewStyle setNavBarRightButton:rightButton];
    [chatViewManager pushMQChatViewControllerInViewController:self];
}

/**
 *  开发者这样可修改导航栏颜色、导航栏左右键、取消图片消息的mask效果
 */
- (void)chatViewStyle6 {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.backgroundColor = [UIColor redColor];
    rightButton.frame = CGRectMake(10, 10, 20, 20);
    [chatViewManager.chatViewStyle setNavBarTintColor:[UIColor redColor]];
    [chatViewManager.chatViewStyle setNavBarRightButton:rightButton];
    UIButton *lertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lertButton.backgroundColor = [UIColor blueColor];
    lertButton.frame = CGRectMake(10, 10, 20, 20);
    [chatViewManager.chatViewStyle setNavBarLeftButton:lertButton];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [chatViewManager setNavTitleText:@"我是标题哦^.^"];
    [chatViewManager pushMQChatViewControllerInViewController:self];
    
}

- (void)systemStyleBlue {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [chatViewManager setChatViewStyle:[MQChatViewStyle createWithStyle:MQChatViewStyleTypeBlue]];
    
    [chatViewManager enableShowNewMessageAlert:true];
    [chatViewManager pushMQChatViewControllerInViewController:self];
}

- (void)systemStyleGreen {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [chatViewManager setChatViewStyle:[MQChatViewStyle createWithStyle:MQChatViewStyleTypeGreen]];
    
    [chatViewManager enableShowNewMessageAlert:true];
    [chatViewManager pushMQChatViewControllerInViewController:self];
}

- (void)systemStyleDark {
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [chatViewManager setChatViewStyle:[MQChatViewStyle createWithStyle:MQChatViewStyleTypeDark]];
    
    [chatViewManager enableShowNewMessageAlert:true];
    [chatViewManager pushMQChatViewControllerInViewController:self];
}

#pragma 监听收到美洽聊天消息的广播
- (void)didReceiveNewMQMessages:(NSNotification *)notification {
    NSArray *messages = [notification.userInfo objectForKey:@"messages"];
    for (MQMessage *message in messages) {
        NSLog(@"messge content = %@", message.content);
    }
    NSLog(@"在聊天界面外，监听到了收到客服消息的广播");
}


@end
