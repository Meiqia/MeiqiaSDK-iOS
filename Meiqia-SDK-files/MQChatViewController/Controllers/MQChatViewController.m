//
//  MQChatViewController.m
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/28.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MQChatViewController.h"
#import "MQChatViewTableDataSource.h"
#import "MQChatViewService.h"
#import "MQCellModelProtocol.h"
#import "MQChatDeviceUtil.h"
#import "MQInputBar.h"
#import "MQToast.h"
#import "MQRecordView.h"
#import "MQBundleUtil.h"
#import "MQImageUtil.h"
#import <MeiQiaSDK/MQDefinition.h>
#import "MQEvaluationView.h"
#import "MQAssetUtil.h"
#import "MQStringSizeUtil.h"
#import "MQTransitioningAnimation.h"
#import "UIView+Layout.h"
#import "MQCustomizedUIText.h"
#import "MQImageUtil.h"
#import "MQMessageFormViewManager.h"

static CGFloat const kMQChatViewInputBarHeight = 50.0;
#ifdef INCLUDE_MEIQIA_SDK
@interface MQChatViewController () <UITableViewDelegate, MQChatViewServiceDelegate, MQInputBarDelegate, UIImagePickerControllerDelegate, MQChatTableViewDelegate, MQChatCellDelegate, MQRecordViewDelegate, MQServiceToViewInterfaceErrorDelegate,UINavigationControllerDelegate, MQEvaluationViewDelegate>
#else
@interface MQChatViewController () <UITableViewDelegate, MQChatViewServiceDelegate, MQInputBarDelegate, UIImagePickerControllerDelegate, MQChatTableViewDelegate, MQChatCellDelegate, MQRecordViewDelegate,UINavigationControllerDelegate, MQEvaluationViewDelegate>
#endif

@end

@interface MQChatViewController()

//@property (nonatomic, strong) id evaluateBarButtonItem;//保存隐藏的barButtonItem

@end

@implementation MQChatViewController {
    MQChatViewConfig *chatViewConfig;
    MQChatViewTableDataSource *tableDataSource;
    MQChatViewService *chatViewService;
    MQInputBar *chatInputBar;
    MQRecordView *recordView;
    MQEvaluationView *evaluationView;
    BOOL isMQCommunicationFailed;  //判断是否通信没有连接上
    UIStatusBarStyle previousStatusBarStyle;//当前statusBar样式
    BOOL previousStatusBarHidden;   //调出聊天视图界面前是否隐藏 statusBar
    NSTimeInterval sendTime;        //发送时间，用于限制发送频率
    UIView *translucentView;        //loading 的半透明层
    UIActivityIndicatorView *activityIndicatorView; //loading
}

- (void)dealloc {
    NSLog(@"清除chatViewController");
    [self removeDelegateAndObserver];
    [chatViewConfig setConfigToDefault];
    [chatViewService setCurrentInputtingText:chatInputBar.textView.text];
#ifdef INCLUDE_MEIQIA_SDK
    [self closeMeiqiaChatView];
#endif
    [MQCustomizedUIText reset];
}

- (instancetype)initWithChatViewManager:(MQChatViewConfig *)config {
    if (self = [super init]) {
        chatViewConfig = config;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    previousStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:[MQChatViewConfig sharedConfig].chatViewStyle.statusBarStyle];
    [self setNeedsStatusBarAppearanceUpdate];
    
    sendTime = [NSDate timeIntervalSinceReferenceDate];
    self.view.backgroundColor = [MQChatViewConfig sharedConfig].chatViewStyle.backgroundColor ?: [UIColor colorWithWhite:0.95 alpha:1];
    [self setNavBar];
    [self initChatTableView];
    [self initchatViewService];
    [self initEvaluationView];
    [self initTableViewDataSource];
    [self initInputBar];
    chatViewService.chatViewWidth = self.chatTableView.frame.size.width;
    [chatViewService sendLocalWelcomeChatMessage];
    
#ifdef INCLUDE_MEIQIA_SDK
    [self updateNavBarTitle:[MQBundleUtil localizedStringForKey:@"wait_agent"]];
    isMQCommunicationFailed = NO;
    [self addObserver];
#endif
    
    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:MQAudioPlayerDidInterruptNotification object:nil];
//    //当横屏时，恢复原来的 statusBar 是否 hidden
//    if (viewSize.height < viewSize.width) {
//        [[UIApplication sharedApplication] setStatusBarHidden:previousStatusBarHidden];
//    }
//    //恢复原来的导航栏透明模式
//    self.navigationController.navigationBar.translucent = previousStatusBarTranslucent;
    //恢复原来的导航栏时间条
    [UIApplication sharedApplication].statusBarStyle = previousStatusBarStyle;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //更新view frame
    [self updateContentViewsFrame];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIView setAnimationsEnabled:YES];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissChatViewController {
    if ([MQChatViewConfig sharedConfig].presentingAnimation == MQTransiteAnimationTypePush) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.view.window.layer addAnimation:[MQTransitioningAnimation createDismissingTransiteAnimation:[MQChatViewConfig sharedConfig].presentingAnimation] forKey:nil];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)addObserver {
#ifdef INCLUDE_MEIQIA_SDK
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMQCommunicationErrorNotification:) name:MQ_COMMUNICATION_FAILED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRefreshOutgoingAvatarNotification:) name:MQChatTableViewShouldRefresh object:nil];
#endif
}

- (void)removeDelegateAndObserver {
    self.navigationController.delegate = nil;
    chatViewService.delegate = nil;
    tableDataSource.chatCellDelegate = nil;
    self.chatTableView.chatTableViewDelegate = nil;
    self.chatTableView.delegate = nil;
    chatInputBar.delegate = nil;
    recordView.recordViewDelegate = nil;
#ifdef INCLUDE_MEIQIA_SDK
    chatViewService.errorDelegate = nil;
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma 初始化viewModel
- (void)initchatViewService {
    chatViewService = [[MQChatViewService alloc] init];
    chatViewService.delegate = self;
#ifdef INCLUDE_MEIQIA_SDK
    chatViewService.errorDelegate = self;
#endif
}

#pragma 初始化tableView dataSource
- (void)initTableViewDataSource {
    tableDataSource = [[MQChatViewTableDataSource alloc] initWithChatViewService:chatViewService];
    tableDataSource.chatCellDelegate = self;
    self.chatTableView.dataSource = tableDataSource;
}

#pragma 初始化所有Views
/**
 * 初始化聊天的tableView
 */
- (void)initChatTableView {
    [self setChatTableViewFrame];
    self.chatTableView = [[MQChatTableView alloc] initWithFrame:chatViewConfig.chatViewFrame style:UITableViewStylePlain];
    self.chatTableView.contentInset = UIEdgeInsetsMake(0, 0, kMQChatViewInputBarHeight, 0);
    self.chatTableView.chatTableViewDelegate = self;
    self.chatTableView.delegate = self;
    [self.view addSubview:self.chatTableView];
}

/**
 * 初始化聊天的inpur bar
 */
- (void)initInputBar {
    CGRect inputBarFrame = CGRectMake(self.chatTableView.frame.origin.x, self.chatTableView.frame.origin.y+self.chatTableView.frame.size.height, self.chatTableView.frame.size.width, kMQChatViewInputBarHeight);
    chatInputBar = [[MQInputBar alloc] initWithFrame:inputBarFrame
                                           superView:self.view
                                           tableView:self.chatTableView
                                     enableSendVoice:[MQChatViewConfig sharedConfig].enableSendVoiceMessage
                                     enableSendImage:[MQChatViewConfig sharedConfig].enableSendImageMessage
                                    photoSenderImage:[MQChatViewConfig sharedConfig].photoSenderImage
                               photoHighlightedImage:[MQChatViewConfig sharedConfig].photoSenderHighlightedImage
                                    voiceSenderImage:[MQChatViewConfig sharedConfig].voiceSenderImage
                               voiceHighlightedImage:[MQChatViewConfig sharedConfig].voiceSenderHighlightedImage
                                 keyboardSenderImage:[MQChatViewConfig sharedConfig].keyboardSenderImage
                            keyboardHighlightedImage:[MQChatViewConfig sharedConfig].keyboardSenderHighlightedImage
                                 resignKeyboardImage:[MQChatViewConfig sharedConfig].resignKeyboardImage
                      resignKeyboardHighlightedImage:[MQChatViewConfig sharedConfig].resignKeyboardHighlightedImage];
    chatInputBar.delegate = self;
    [self.view addSubview:chatInputBar];
    chatInputBar.textView.text = [chatViewService getPreviousInputtingText];
    self.inputBarView = chatInputBar;
    self.inputBarTextView = chatInputBar.textView.internalTextView;
}

/**
 * 初始化评价的 alertView
 */
- (void)initEvaluationView {
    evaluationView = [[MQEvaluationView alloc] init];
    evaluationView.delegate = self;
}

#pragma 添加消息通知的observer
- (void)setNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignKeyboardFirstResponder:) name:MQChatViewKeyboardResignFirstResponderNotification object:nil];
}

#pragma 消息通知observer的处理函数
- (void)resignKeyboardFirstResponder:(NSNotification *)notification {
    [self.view endEditing:true];
}

#pragma MQChatTableViewDelegate
- (void)didTapChatTableView:(UITableView *)tableView {
    [self.view endEditing:true];
}

//下拉刷新，获取以前的消息
- (void)startLoadingTopMessagesInTableView:(UITableView *)tableView {
#ifndef INCLUDE_MEIQIA_SDK
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.chatTableView finishLoadingTopRefreshViewWithCellNumber:1 isLoadOver:true];
    });
#else
    [chatViewService startGettingHistoryMessages];
#endif
}

//上拉刷新，获取更新的消息
- (void)startLoadingBottomMessagesInTableView:(UITableView *)tableView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.chatTableView finishLoadingBottomRefreshView];
    });
}

#pragma 编辑导航栏 - Demo用到的收取消息按钮
- (void)setNavBar {
    if ([MQChatViewConfig sharedConfig].didSetStatusBarStyle) {
        [UIApplication sharedApplication].statusBarStyle = [MQChatViewConfig sharedConfig].statusBarStyle;
    }
    if ([MQChatViewConfig sharedConfig].navBarRightButton) {
        return;
    }
#ifndef INCLUDE_MEIQIA_SDK
    UIBarButtonItem *loadMessageButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"收取消息" style:(UIBarButtonItemStylePlain) target:self action:@selector(tapNavigationRightBtn:)];
    loadMessageButtonItem.tintColor = [UIColor redColor];
    self.navigationItem.rightBarButtonItem = loadMessageButtonItem;
    if (![MQChatViewConfig sharedConfig].enableEvaluationButton) {
        return;
    }
    UIBarButtonItem *rightNavButtonItem = [[UIBarButtonItem alloc]initWithTitle:[MQBundleUtil localizedStringForKey:@"meiqia_evaluation_sheet"] style:(UIBarButtonItemStylePlain) target:self action:@selector(tapNavigationRightBtn:)];
    rightNavButtonItem.tintColor = chatViewConfig.chatViewStyle.btnTextColor;
    self.navigationItem.rightBarButtonItem = rightNavButtonItem;
#endif
}

- (void)tapNavigationRightBtn:(id)sender {
#ifndef INCLUDE_MEIQIA_SDK
    [chatViewService loadLastMessage];
    [self chatTableViewScrollToBottomWithAnimated:true];
    //显示评价
    [evaluationView showEvaluationAlertView];
#else
    [self showEvaluationAlertView];
#endif
}

- (void)tapNavigationRedirectBtn:(id)sender {
    [chatViewService forceRedirectToHumanAgent];
    // 清除当前右上角的按钮
    self.navigationItem.rightBarButtonItem = nil;
    // 改变 title
#ifdef INCLUDE_MEIQIA_SDK
    [self updateNavTitleWithAgentName:[MQBundleUtil localizedStringForKey:@"wait_agent"] agentStatus:MQChatAgentStatusOffLine];
#endif
    [self showActivityIndicatorView];
}

- (void)didSelectNavigationRightButton {
    NSLog(@"点击了自定义导航栏右键，开发者可在这里增加功能。");
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<MQCellModelProtocol> cellModel = [chatViewService.cellModels objectAtIndex:indexPath.row];
    return [cellModel getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

#pragma UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.chatTableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.chatTableView scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self.chatTableView scrollViewDidEndScrollingAnimation:scrollView];
}

#pragma MQChatViewServiceDelegate

- (void)didGetHistoryMessagesWithCellNumber:(NSInteger)cellNumber isLoadOver:(BOOL)isLoadOver{
    [self.chatTableView finishLoadingTopRefreshViewWithCellNumber:cellNumber isLoadOver:isLoadOver];
//    [self.chatTableView reloadData];
//    [self reloadChatTableView];
}

- (void)didUpdateCellModelWithIndexPath:(NSIndexPath *)indexPath {
    [self.chatTableView updateTableViewAtIndexPath:indexPath];
}

- (void)reloadChatTableView {
    CGSize preContentSize = self.chatTableView.contentSize;
    [self.chatTableView reloadData];
    if (!CGSizeEqualToSize(preContentSize, self.chatTableView.contentSize)) {
        [self scrollTableViewToBottom];
    }
}

- (void)scrollTableViewToBottom {
    [self chatTableViewScrollToBottomWithAnimated:false];
}

- (void)showEvaluationAlertView {
    [chatInputBar.textView resignFirstResponder];
    [evaluationView showEvaluationAlertView];
}

- (BOOL)isChatRecording {
    return [recordView isRecording];
}

#ifdef INCLUDE_MEIQIA_SDK
- (void)didScheduleClientWithViewTitle:(NSString *)viewTitle agentStatus:(MQChatAgentStatus)agentStatus{
    [self updateNavTitleWithAgentName:viewTitle agentStatus:agentStatus];
}
#endif

- (void)changeNavReightBtnWithAgentType:(NSString *)agentType {
    // 隐藏 loading
    [self dismissActivityIndicatorView];
    
    if ([MQChatViewConfig sharedConfig].navBarRightButton) {
        return;
    }
    NSString *titleKey = nil;
    SEL navBtnSelector = nil;
    if ([agentType isEqualToString:@"bot"]) {
        if (chatViewService.isShowBotRedirectBtn) {
            titleKey = @"meiqia_redirect_sheet";
            navBtnSelector = @selector(tapNavigationRedirectBtn:);
        }
    } else if ([agentType isEqualToString:@"agent"] || [agentType isEqualToString:@"admin"]) {
        if ([MQChatViewConfig sharedConfig].enableEvaluationButton) {
            titleKey = @"meiqia_evaluation_sheet";
            navBtnSelector = @selector(tapNavigationRightBtn:);
        }
    }
    // 判断是否隐藏右导航栏按钮
    if (!navBtnSelector) {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    NSString *title = [MQBundleUtil localizedStringForKey:titleKey];
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:title]) {
        return;
    }
    UIBarButtonItem *rightNavButtonItem = [[UIBarButtonItem alloc]initWithTitle:title style:(UIBarButtonItemStylePlain) target:self action:navBtnSelector];
    rightNavButtonItem.tintColor = chatViewConfig.chatViewStyle.btnTextColor;
    self.navigationItem.rightBarButtonItem = rightNavButtonItem;
}

- (void)didReceiveMessage {
    //判断是否显示新消息提示
    if ([self.chatTableView isTableViewScrolledToBottom]) {
        [self chatTableViewScrollToBottomWithAnimated:true];
    } else {
        if ([MQChatViewConfig sharedConfig].enableShowNewMessageAlert) {
            [MQToast showToast:[MQBundleUtil localizedStringForKey:@"display_new_message"] duration:1.5 window:self.view];
        }
    }
}

- (void)showToastViewWithContent:(NSString *)content {
    [MQToast showToast:content duration:1.0 window:self.view];
}

#pragma MQInputBarDelegate
-(BOOL)sendTextMessage:(NSString*)text {
    // 判断当前顾客是否正在登陆，如果正在登陆，显示禁止发送的提示
    if (chatViewService.clientStatus == MQClientStatusOnlining || [NSDate timeIntervalSinceReferenceDate] - sendTime < 1) {
        NSString *alertText = chatViewService.clientStatus == MQClientStatusOnlining ? @"cannot_text_client_is_onlining" : @"send_to_fast";
        [MQToast showToast:[MQBundleUtil localizedStringForKey:alertText] duration:2 window:self.view];
        chatInputBar.textView.text = text;
        return NO;
    }
    [chatViewService sendTextMessageWithContent:text];
    [self chatTableViewScrollToBottomWithAnimated:true];
    sendTime = [NSDate timeIntervalSinceReferenceDate];
    return YES;
}

-(void)sendImageWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    NSString *mediaPermission = [MQChatDeviceUtil isDeviceSupportImageSourceType:(int)sourceType];
    if (!mediaPermission) {
        return;
    }
    if (![mediaPermission isEqualToString:@"ok"]) {
        [MQToast showToast:[MQBundleUtil localizedStringForKey:mediaPermission] duration:2 window:self.view];
        return;
    }
    
    // 判断当前顾客是否正在登陆，如果正在登陆，显示禁止发送的提示
    if (chatViewService.clientStatus == MQClientStatusOnlining || [NSDate timeIntervalSinceReferenceDate] - sendTime < 1) {
        NSString *alertText = chatViewService.clientStatus == MQClientStatusOnlining ? @"cannot_text_client_is_onlining" : @"send_to_fast";
        [MQToast showToast:[MQBundleUtil localizedStringForKey:alertText] duration:2 window:self.view];
        return ;
    }
    sendTime = [NSDate timeIntervalSinceReferenceDate];
    self.navigationController.delegate = self;
    //兼容ipad打不开相册问题，使用队列延迟
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType               = (int)sourceType;
        picker.delegate                 = (id)self;
        [self presentViewController:picker animated:YES completion:nil];
    }];
}

-(void)inputting:(NSString*)content {
    //用户正在输入
    
    static BOOL shouldSendInputtingMessageToServer = YES;
    
    if (shouldSendInputtingMessageToServer) {
        shouldSendInputtingMessageToServer = NO;
        [chatViewService sendUserInputtingWithContent:content];
        
        //wait for 5 secs to enable sending message again
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            shouldSendInputtingMessageToServer = YES;
        });
    }
    
}

-(void)chatTableViewScrollToBottomWithAnimated:(BOOL)animated {
    NSInteger lastCellIndex = chatViewService.cellModels.count;
    if (lastCellIndex == 0) {
        return;
    }
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastCellIndex-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

-(void)beginRecord:(CGPoint)point {
    if (TARGET_IPHONE_SIMULATOR){
        [MQToast showToast:[MQBundleUtil localizedStringForKey:@"simulator_not_support_microphone"] duration:2 window:self.view];
        return;
    }
    
    // 判断当前顾客是否正在登陆，如果正在登陆，显示禁止发送的提示
    if (chatViewService.clientStatus == MQClientStatusOnlining || [NSDate timeIntervalSinceReferenceDate] - sendTime < 1) {
        NSString *alertText = chatViewService.clientStatus == MQClientStatusOnlining ? @"cannot_text_client_is_onlining" : @"send_to_fast";
        [MQToast showToast:[MQBundleUtil localizedStringForKey:alertText] duration:2 window:self.view];
        return ;
    }
    sendTime = [NSDate timeIntervalSinceReferenceDate];
    //停止播放的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:MQAudioPlayerDidInterruptNotification object:nil];
    
    //判断是否开启了语音权限
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        //首先记录点击语音的时间，如果第一次授权，则确定授权的时间会较长，这时不应该初始化record view
        CGFloat tapVoiceTimeInMilliSeconds = [NSDate timeIntervalSinceReferenceDate] * 1000;
        [MQChatDeviceUtil isDeviceSupportMicrophoneWithPermission:^(BOOL permission) {
            CGFloat getPermissionTimeInMilliSeconds = [NSDate timeIntervalSinceReferenceDate] * 1000;
            if (getPermissionTimeInMilliSeconds - tapVoiceTimeInMilliSeconds > 100) {
                return ;
            }
            if (permission) {
                [self initRecordView];
            } else {
                [MQToast showToast:[MQBundleUtil localizedStringForKey:@"microphone_denied"] duration:2 window:self.view];
            }
        }];
    } else {
        [self initRecordView];
    }
}

- (void)initRecordView {
    //如果开发者不自定义录音界面，则将播放界面显示出来
    if (!recordView) {
        recordView = [[MQRecordView alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    self.chatTableView.frame.size.width,
                                                                    /*viewSize.height*/[UIScreen mainScreen].bounds.size.height - chatInputBar.frame.size.height)
                                       maxRecordDuration:[MQChatViewConfig sharedConfig].maxVoiceDuration];
        recordView.recordMode = [MQChatViewConfig sharedConfig].recordMode;
        recordView.keepSessionActive = [MQChatViewConfig sharedConfig].keepAudioSessionActive;
        recordView.recordViewDelegate = self;
        [self.view addSubview:recordView];
    }
    [recordView reDisplayRecordView];
    [recordView startRecording];
}

-(void)finishRecord:(CGPoint)point {
    [recordView stopRecord];
    [self didEndRecord];
}

-(void)cancelRecord:(CGPoint)point {
    [recordView cancelRecording];
    [self didEndRecord];
}

-(void)changedRecordViewToCancel:(CGPoint)point {
    recordView.revoke = true;
}

-(void)changedRecordViewToNormal:(CGPoint)point {
    recordView.revoke = false;
}

- (void)didEndRecord {
    
}

#pragma MQRecordViewDelegate
- (void)didFinishRecordingWithAMRFilePath:(NSString *)filePath {
    [chatViewService sendVoiceMessageWithAMRFilePath:filePath];
    [self chatTableViewScrollToBottomWithAnimated:true];
}

- (void)didUpdateVolumeInRecordView:(UIView *)recordView volume:(CGFloat)volume {
    
}

#pragma UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type          = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if (![type isEqualToString:@"public.image"]) {
        return;
    }
    UIImage *image          =  [MQImageUtil resizeImage:[MQImageUtil fixrotation:[info objectForKey:UIImagePickerControllerOriginalImage]]maxSize:CGSizeMake(1000, 1000)];
    [picker dismissViewControllerAnimated:YES completion:^{
        [chatViewService sendImageMessageWithImage:image];
        [self chatTableViewScrollToBottomWithAnimated:true];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma UINavigationControllerDelegate 设置当前 statusBarStyle
-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    //修改status样式
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        [UIApplication sharedApplication].statusBarStyle = previousStatusBarStyle;
    }
    self.navigationController.delegate = nil;
}

#pragma MQChatCellDelegate
- (void)showToastViewInCell:(UITableViewCell *)cell toastText:(NSString *)toastText {
    [MQToast showToast:toastText duration:1.0 window:self.view];
}

- (void)resendMessageInCell:(UITableViewCell *)cell resendData:(NSDictionary *)resendData {
    //先删除之前的消息
    NSIndexPath *indexPath = [self.chatTableView indexPathForCell:cell];
    [chatViewService resendMessageAtIndex:indexPath.row resendData:resendData];
    [self chatTableViewScrollToBottomWithAnimated:true];
}

- (void)didSelectMessageInCell:(UITableViewCell *)cell messageContent:(NSString *)content selectedContent:(NSString *)selectedContent {
    
}

- (void)evaluateBotAnswer:(BOOL)isUseful messageId:(NSString *)messageId{
    if (isUseful){
        NSLog(@"点击有用按钮");
    } else{
        NSLog(@"点击无用按钮");
    }
    [chatViewService evaluateBotAnswer:isUseful messageId:messageId];
}

- (void)didTapMenuWithText:(NSString *)menuText {
    NSLog(@"点击 menu text = %@", menuText);
    //去掉 menu 的序号后，主动发送该 menu 消息
    NSRange orderRange = [menuText rangeOfString:@". "];
    if (orderRange.location == NSNotFound) {
        return ;
    }
    NSString *sendText = [menuText substringFromIndex:orderRange.location+2];
    [chatViewService sendTextMessageWithContent:sendText];
}

- (void)didTapReplyBtn {
    NSLog(@"点击了留言按钮");
    [self showMQMessageForm];
}

- (void)didTapBotRedirectBtn {
    NSLog(@"点击了转人工");
    [self tapNavigationRedirectBtn:nil];
}

- (void)didTapMessageInCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.chatTableView indexPathForCell:cell];
    [chatViewService didTapMessageCellAtIndex:indexPath.row];
}

#pragma MQEvaluationViewDelegate
- (void)didSelectLevel:(NSInteger)level comment:(NSString *)comment {
    NSLog(@"评价 level = %d\n评价内容 = %@", (int)level, comment);
    [chatViewService sendEvaluationLevel:level comment:comment];
}

#pragma ios7以下系统的横屏的事件
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    NSLog(@"willAnimateRotationToInterfaceOrientation");
//    viewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
//}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateContentViewsFrame];
    [self.view endEditing:YES];
}

#pragma ios8以上系统的横屏的事件
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateContentViewsFrame];
    }];
    [self.view endEditing:YES];
}

//更新viewConroller中所有的view的frame
- (void)updateContentViewsFrame {
    //更新tableView的frame
    [self setChatTableViewFrame];
    //更新cellModel的frame
    chatViewService.chatViewWidth = self.chatTableView.frame.size.width;
    [chatViewService updateCellModelsFrame];
    [self.chatTableView reloadData];
    //更新inputBar的frame
    CGRect inputBarFrame = CGRectMake(self.chatTableView.frame.origin.x, self.chatTableView.frame.origin.y+self.chatTableView.frame.size.height - kMQChatViewInputBarHeight, self.chatTableView.frame.size.width, kMQChatViewInputBarHeight);
    [chatInputBar updateFrame:inputBarFrame];
    //更新recordView的frame
    CGRect recordViewFrame = CGRectMake(0,
                                        0,
                                        self.chatTableView.frame.size.width,
                                        self.view.viewHeight);
    [recordView updateFrame:recordViewFrame];
    // 更新半透明层
    if (translucentView) {
        translucentView.frame = CGRectMake(0, 0, self.chatTableView.frame.size.width, self.chatTableView.frame.size.height);
        [activityIndicatorView setCenter:CGPointMake(self.chatTableView.frame.size.width / 2.0, self.chatTableView.frame.size.height / 2.0)];
    }
}

- (void)setChatTableViewFrame {
    //更新tableView的frame
    chatViewConfig.chatViewFrame = self.view.bounds;
    [self.chatTableView updateFrame:chatViewConfig.chatViewFrame];
}

#ifdef INCLUDE_MEIQIA_SDK
#pragma MQServiceToViewInterfaceErrorDelegate 后端返回的数据的错误委托方法
- (void)getLoadHistoryMessageError {
    [self.chatTableView finishLoadingTopRefreshViewWithCellNumber:0 isLoadOver:false];
    [MQToast showToast:[MQBundleUtil localizedStringForKey:@"load_history_message_error"] duration:1.0 window:self.view];
}

/**
 *  更新导航栏title
 */
- (void)updateNavBarTitle:(NSString *)title {
    //如果开发者设定了 title ，则不更新 title
    if ([MQChatViewConfig sharedConfig].navTitleText) {
        return;
    }
    self.navigationItem.title = title;
}

/**
 *  根据是否正在分配客服，更新导航栏title
 */
- (void)updateNavTitleWithAgentName:(NSString *)agentName agentStatus:(MQChatAgentStatus)agentStatus {
    //如果开发者设定了 title ，则不更新 title
    if ([MQChatViewConfig sharedConfig].navTitleText) {
        return;
    }
    UIView *titleView = [UIView new];
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = agentName;
    
    UIFont *font = [MQChatViewConfig sharedConfig].chatViewStyle.navTitleFont ?: [[UINavigationBar appearance].titleTextAttributes objectForKey:NSFontAttributeName] ?: [UIFont systemFontOfSize:16.0];
    UIColor *color = [MQChatViewConfig sharedConfig].navTitleColor ?: [[UINavigationBar appearance].titleTextAttributes objectForKey:NSForegroundColorAttributeName];
    titleLabel.font = font;
    titleLabel.textColor = color;
    CGFloat titleHeight = [MQStringSizeUtil getHeightForText:agentName withFont:titleLabel.font andWidth:self.view.frame.size.width];
    CGFloat titleWidth = [MQStringSizeUtil getWidthForText:agentName withFont:titleLabel.font andHeight:titleHeight];
    UIImageView *statusImageView = [UIImageView new];
    switch (agentStatus) {
        case MQChatAgentStatusOnDuty:
            statusImageView.image = [MQAssetUtil agentOnDutyImage];
            break;
        case MQChatAgentStatusOffDuty:
            statusImageView.image = [MQAssetUtil agentOffDutyImage];
            break;
        case MQChatAgentStatusOffLine:
            statusImageView.image = [MQAssetUtil agentOfflineImage];
            break;
        default:
            break;
    }
    
    if ([titleLabel.text isEqualToString:[MQBundleUtil localizedStringForKey:@"no_agent_title"]]) {
        statusImageView.image = nil;
    }
    
    statusImageView.frame = CGRectMake(0, titleHeight/2 - statusImageView.image.size.height/2, statusImageView.image.size.width, statusImageView.image.size.height);
    titleLabel.frame = CGRectMake(statusImageView.frame.size.width + 8, 0, titleWidth, titleHeight);
    titleView.frame = CGRectMake(0, 0, titleLabel.frame.origin.x + titleLabel.frame.size.width, titleHeight);
    [titleView addSubview:statusImageView];
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
}

/**
 *  收到美洽通信连接失败的通知
 */
- (void)didReceiveMQCommunicationErrorNotification:(NSNotification *)notification {
    if (isMQCommunicationFailed) {
        return;
    }
    isMQCommunicationFailed = true;
    [MQToast showToast:[MQBundleUtil localizedStringForKey:@"meiqia_communication_failed"] duration:1.0 window:self.view];
}


- (void)didReceiveRefreshOutgoingAvatarNotification:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[UIImage class]]) {
        [chatViewService refreshOutgoingAvatarWithImage:notification.object];
    }
}

- (void)closeMeiqiaChatView {
    if ([self.navigationItem.title isEqualToString:[MQBundleUtil localizedStringForKey:@"no_agent_title"]]) {
        [chatViewService dismissingChatViewController];
    }
}

#pragma mark -

- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    
    CGFloat xPercent = translation.x / CGRectGetWidth(self.view.bounds) * 0.5;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [MQTransitioningAnimation setInteractive:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            [MQTransitioningAnimation updateInteractiveTransition:xPercent];
            break;
        default:
            if (xPercent < .25) {
                [MQTransitioningAnimation cancelInteractiveTransition];
            } else {
                [MQTransitioningAnimation finishInteractiveTransition];
            }
            [MQTransitioningAnimation setInteractive:NO];
            break;
    }
    
}

#endif


#pragma 美洽留言的界面
- (void)showMQMessageForm {
    MQMessageFormViewManager *formManager = [[MQMessageFormViewManager alloc] init];
    [formManager pushMQMessageFormViewControllerInViewController:self];
}

/**
 显示数据提交遮罩层
 */
- (void)showActivityIndicatorView {
    if (!translucentView) {
        translucentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.chatTableView.frame.size.width, self.chatTableView.frame.size.height)];
        translucentView.backgroundColor = [UIColor blackColor];
        translucentView.alpha = 0.5;
        
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicatorView setCenter:CGPointMake(self.chatTableView.frame.size.width / 2.0, self.chatTableView.frame.size.height / 2.0)];
        [translucentView addSubview:activityIndicatorView];
        [self.view addSubview:translucentView];
    }
    
    translucentView.hidden = NO;
    translucentView.alpha = 0;
    [activityIndicatorView startAnimating];
    [UIView animateWithDuration:0.5 animations:^{
        translucentView.alpha = 0.5;
    }];
}

/**
 隐藏数据提交遮罩层
 */
- (void)dismissActivityIndicatorView {
    if (translucentView) {
        [activityIndicatorView stopAnimating];
        translucentView.hidden = YES;
    }
}


@end
