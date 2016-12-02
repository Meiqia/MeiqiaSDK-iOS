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
#import "MQInputToolBar.h"
#import "MQTabInputContentView.h"
#import "MQKeyboardController.h"
#import "MQToast.h"
#import "MQRecordView.h"
#import "MQBundleUtil.h"
#import "MQImageUtil.h"
#import <MeiQiaSDK/MQDefinition.h>
#import "MQEvaluationView.h"
#import "MQAssetUtil.h"
#import "MQStringSizeUtil.h"
#import "MQTransitioningAnimation.h"
#import "UIView+MQLayout.h"
#import "MQCustomizedUIText.h"
#import "MQImageUtil.h"
#import "MQRecorderView.h"
#import "MQMessageFormViewManager.h"
#import "MQPreChatFormListViewController.h"
#import "MQAGEmojiKeyBoardView.h"

static CGFloat const kMQChatViewInputBarHeight = 80.0;

@interface MQChatViewController () <UITableViewDelegate, MQChatViewServiceDelegate, MQInputToolBarDelegate, UIImagePickerControllerDelegate, MQChatTableViewDelegate, MQChatCellDelegate, MQServiceToViewInterfaceErrorDelegate,UINavigationControllerDelegate, MQEvaluationViewDelegate, MQInputContentViewDelegate, MQKeyboardControllerDelegate, MQRecordViewDelegate, MQRecorderViewDelegate, MQAGEmojiKeyboardViewDelegate, MQAGEmojiKeyboardViewDataSource>

@end

@interface MQChatViewController()

@property (nonatomic, strong) id evaluateBarButtonItem;//保存隐藏的barButtonItem
@property (nonatomic, strong) MQInputToolBar *chatInputBar;
@property (nonatomic, strong) NSLayoutConstraint *constaintInputBarHeight;
@property (nonatomic, strong) NSLayoutConstraint *constraintInputBarBottom;
@property (nonatomic, strong) MQEvaluationView *evaluationView;
@property (nonatomic, strong) MQKeyboardController *keyboardController;
@property (nonatomic, strong) MQRecordView *recordView;
@property (nonatomic, strong) MQRecorderView *displayRecordView;//只用来显示
@property (nonatomic, strong) MQAGEmojiKeyboardView *emojiView;

@end

@implementation MQChatViewController {
    MQChatViewConfig *chatViewConfig;
    MQChatViewTableDataSource *tableDataSource;
    MQChatViewService *chatViewService;
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
    [chatViewService setCurrentInputtingText:[(MQTabInputContentView *)self.chatInputBar.contentView textField].text];
    [self closeMeiqiaChatView];
    [MQCustomizedUIText reset];
    chatViewService = nil;
}

- (instancetype)initWithChatViewManager:(MQChatViewConfig *)config {
    if (self = [super init]) {
        chatViewConfig = config;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MQServiceToViewInterface prepareForChat];
    
    // Do any additional setup after loading the view.
    previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    previousStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:[MQChatViewConfig sharedConfig].chatViewStyle.statusBarStyle];
    [self setNeedsStatusBarAppearanceUpdate];
    
    sendTime = [NSDate timeIntervalSinceReferenceDate];
    self.view.backgroundColor = [MQChatViewConfig sharedConfig].chatViewStyle.backgroundColor ?: [UIColor colorWithWhite:0.95 alpha:1];
    [self initChatTableView];
    [self initInputBar];
    [self layoutViews];
    [self initchatViewService];
    [self initTableViewDataSource];
    
    
    chatViewService.chatViewWidth = self.chatTableView.frame.size.width;
    
#ifdef INCLUDE_MEIQIA_SDK
    //[self updateNavBarTitle:[MQBundleUtil localizedStringForKey:@"wait_agent"]];
    isMQCommunicationFailed = NO;
    [self addObserver];
#endif
    
    if ([MQChatViewConfig sharedConfig].presentingAnimation == MQTransiteAnimationTypePush) {
        UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
        popRecognizer.edges = UIRectEdgeLeft;
        [self.view addGestureRecognizer:popRecognizer];
    }
    
    [self presentUI];
}

- (void)presentUI {
    [MQPreChatFormListViewController usePreChatFormIfNeededOnViewController:self compeletion:^(NSDictionary *userInfo){
        NSString *targetType = userInfo[@"targetType"];
        NSString *target = userInfo[@"target"];
        NSString *menu = userInfo[@"menu"];
        
        if ([targetType isEqualToString:@"agent"]) {
            [MQChatViewConfig sharedConfig].scheduledAgentId = target;
        } else if ([targetType isEqualToString:@"group"]) {
            [MQChatViewConfig sharedConfig].scheduledGroupId = target;
        }
        
        if ([menu length] > 0) {
            NSMutableArray *m = [[MQChatViewConfig sharedConfig].preSendMessages mutableCopy] ?: [NSMutableArray new];
            [m addObject:menu];
            [MQChatViewConfig sharedConfig].preSendMessages = m;
        }
        
        [chatViewService setClientOnline];
    } cancle:^{
        [self dismissViewControllerAnimated:NO completion:^{
            [self dismissChatViewController];
        }];
    }];
    
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
    
    [[UIApplication sharedApplication] setStatusBarHidden:previousStatusBarHidden];
    
    [MQServiceToViewInterface completeChat];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.keyboardController beginListeningForKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    [self.keyboardController endListeningForKeyboard];
    
    if ([MQServiceToViewInterface waitingInQueuePosition] > 0) {
        [chatViewService saveTextDraftIfNeeded:(UITextField *)[(MQTabInputContentView *)self.chatInputBar.contentView textField]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIView setAnimationsEnabled:YES];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [chatViewService fillTextDraftToFiledIfExists:(UITextField *)[(MQTabInputContentView *)self.chatInputBar.contentView textField]];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma 初始化viewModel
- (void)initchatViewService {
    chatViewService = [[MQChatViewService alloc] initWithDelegate:self errorDelegate:self];
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
//    [self setChatTableViewFrame];
    self.chatTableView = [[MQChatTableView alloc] initWithFrame:chatViewConfig.chatViewFrame style:UITableViewStylePlain];
    self.chatTableView.chatTableViewDelegate = self;
    self.chatTableView.delegate = self;
    [self.view addSubview:self.chatTableView];
}

/**
 * 初始化聊天的inpur bar
 */
- (void)initInputBar {
    [self.view addSubview:self.chatInputBar];
}

- (void)layoutViews {
    self.chatTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.chatInputBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constrains = [NSMutableArray new];
    
    [constrains addObjectsFromArray:[self addFitWidthConstraintsToView:self.chatTableView onTo:self.view]];
    [constrains addObjectsFromArray:[self addFitWidthConstraintsToView:self.chatInputBar onTo:self.view]];
    
    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.chatTableView attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeTop) multiplier:1 constant:0]];
    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.chatTableView attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeLeft) multiplier:1 constant:0]];
    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.chatTableView attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeRight) multiplier:1 constant:0]];
    self.constraintInputBarBottom = [NSLayoutConstraint constraintWithItem:self.view attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self.chatInputBar attribute:(NSLayoutAttributeBottom) multiplier:1 constant:0];
    [constrains addObject:self.constraintInputBarBottom];
    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.chatTableView attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self.chatInputBar attribute:(NSLayoutAttributeTop) multiplier:1 constant:0]];
    
    [self.view addConstraints:constrains];
    
    self.constaintInputBarHeight = [NSLayoutConstraint constraintWithItem:self.chatInputBar attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:(NSLayoutAttributeNotAnAttribute) multiplier:1 constant:kMQChatViewInputBarHeight];
    
    [self.chatInputBar addConstraint:self.constaintInputBarHeight];
}

- (NSArray *)addFitWidthConstraintsToView:(UIView *)innerView onTo:(UIView *)outterView {
    return @[[NSLayoutConstraint constraintWithItem:innerView attribute:NSLayoutAttributeWidth relatedBy:(NSLayoutRelationEqual) toItem:outterView attribute:(NSLayoutAttributeWidth) multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:innerView attribute:NSLayoutAttributeCenterX relatedBy:(NSLayoutRelationEqual) toItem:outterView attribute:(NSLayoutAttributeCenterX) multiplier:1 constant:0]];
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

- (void)reloadCellAsContentUpdated:(UITableViewCell *)cell {
    [self.chatTableView reloadData];
    
    if (cell.viewBottomEdge >= self.chatTableView.contentSize.height) {
        if (!self.chatTableView.isDragging && !self.chatTableView.tracking && !self.chatTableView.decelerating ) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self scrollTableViewToBottom];
            });
        }
    }
}

//下拉刷新，获取以前的消息
- (void)startLoadingTopMessagesInTableView:(UITableView *)tableView {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.chatTableView finishLoadingTopRefreshViewWithCellNumber:1 isLoadOver:true];
//    });
    [chatViewService startGettingHistoryMessages];
}

//上拉刷新，获取更新的消息
- (void)startLoadingBottomMessagesInTableView:(UITableView *)tableView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.chatTableView finishLoadingBottomRefreshView];
    });
}

- (void)tapNavigationRightBtn:(id)sender {
    [self showEvaluationAlertView];
}

- (void)tapNavigationRedirectBtn:(id)sender {
    [chatViewService forceRedirectToHumanAgent];
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

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self.chatTableView scrollViewDidEndScrollingAnimation:scrollView];
}

#pragma MQChatViewServiceDelegate

- (void)didGetHistoryMessagesWithCellNumber:(NSInteger)cellNumber isLoadOver:(BOOL)isLoadOver{
    [self.chatTableView finishLoadingTopRefreshViewWithCellNumber:cellNumber isLoadOver:isLoadOver];
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
    [self.view.window endEditing:YES];
    [self.evaluationView showEvaluationAlertView];
}

- (BOOL)isChatRecording {
    return [self.recordView isRecording];
}

- (void)didScheduleClientWithViewTitle:(NSString *)viewTitle agentStatus:(MQChatAgentStatus)agentStatus{
    [self updateNavTitleWithAgentName:viewTitle agentStatus:agentStatus];
}

- (void)changeNavReightBtnWithAgentType:(NSString *)agentType hidden:(BOOL)hidden {
    // 隐藏 loading
    [self dismissActivityIndicatorView];
    __block UIBarButtonItem *item = nil;
    if ([agentType isEqualToString:@"bot"]) {
        [MQServiceToViewInterface getIsShowRedirectHumanButtonComplete:^(BOOL isShow, NSError *error) {
            if (isShow) {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[MQBundleUtil localizedStringForKey:@"meiqia_redirect_sheet"] style:(UIBarButtonItemStylePlain) target:self action:@selector(tapNavigationRedirectBtn:)];
            }
        }];
        return;
    } else if ([MQChatViewConfig sharedConfig].navBarRightButton) {
        item = [[UIBarButtonItem alloc]initWithCustomView:[MQChatViewConfig sharedConfig].navBarRightButton];
    } else {
        if (![MQChatViewConfig sharedConfig].navBarRightButton && !hidden) {
            item =  [[UIBarButtonItem alloc]initWithTitle:[MQBundleUtil localizedStringForKey:@"meiqia_evaluation_sheet"] style:(UIBarButtonItemStylePlain) target:self action:@selector(tapNavigationRightBtn:)];
        }
    }
    
    self.navigationItem.rightBarButtonItem = item;
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
        [[(MQTabInputContentView *)self.chatInputBar.contentView textField] setText:text];
        return NO;
    }
    [chatViewService sendTextMessageWithContent:text];
    sendTime = [NSDate timeIntervalSinceReferenceDate];
    [self chatTableViewScrollToBottomWithAnimated:YES];
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

- (void)inputContentTextDidChange:(NSString *)newString {
    //用户正在输入
    static BOOL shouldSendInputtingMessageToServer = YES;
    
    if (shouldSendInputtingMessageToServer) {
        shouldSendInputtingMessageToServer = NO;
        [chatViewService sendUserInputtingWithContent:newString];
        
        //wait for 5 secs to enable sending message again
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            shouldSendInputtingMessageToServer = YES;
        });
    }
    
}

- (void)chatTableViewScrollToBottomWithAnimated:(BOOL)animated {
    NSInteger cellCount = [self.chatTableView numberOfRowsInSection:0];
    if (cellCount == 0) {
        return;
    }
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cellCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
}

- (void)beginRecord:(CGPoint)point {
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
                [self startRecord];
            } else {
                [MQToast showToast:[MQBundleUtil localizedStringForKey:@"microphone_denied"] duration:2 window:self.view];
            }
        }];
    } else {
        [self startRecord];
    }
}

- (void)startRecord {
    [self.recordView reDisplayRecordView];
    [self.recordView startRecording];
}

- (void)finishRecord:(CGPoint)point {
    [self.recordView stopRecord];
    [self didEndRecord];
}

- (void)cancelRecord:(CGPoint)point {
    [self.recordView cancelRecording];
    [self didEndRecord];
}

- (void)changedRecordViewToCancel:(CGPoint)point {
    self.recordView.revoke = true;
}

- (void)changedRecordViewToNormal:(CGPoint)point {
    self.recordView.revoke = false;
}

- (void)didEndRecord {
    
}

#pragma MQRecordViewDelegate
- (void)didFinishRecordingWithAMRFilePath:(NSString *)filePath {
    [chatViewService sendVoiceMessageWithAMRFilePath:filePath];
    [self chatTableViewScrollToBottomWithAnimated:true];
}

- (void)didUpdateVolumeInRecordView:(UIView *)recordView volume:(CGFloat)volume {
    [self.displayRecordView changeVolumeLayerDiameter:volume];
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

- (void)evaluateBotAnswer:(BOOL)isUseful messageId:(NSString *)messageId {
    [chatViewService evaluateBotAnswer:isUseful messageId:messageId];
}

- (void)didTapMenuWithText:(NSString *)menuText {
    //去掉 menu 的序号后，主动发送该 menu 消息
    NSRange orderRange = [menuText rangeOfString:@". "];
    if (orderRange.location == NSNotFound) {
        return ;
    }
    NSString *sendText = [menuText substringFromIndex:orderRange.location+2];
    [chatViewService sendTextMessageWithContent:sendText];
}

- (void)didTapReplyBtn {
    [self showMQMessageForm];
}

- (void)didTapBotRedirectBtn {
    [self tapNavigationRedirectBtn:nil];
}

- (void)didTapMessageInCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.chatTableView indexPathForCell:cell];
    [chatViewService didTapMessageCellAtIndex:indexPath.row];
}

#pragma MQEvaluationViewDelegate
- (void)didSelectLevel:(NSInteger)level comment:(NSString *)comment {
    [chatViewService sendEvaluationLevel:level comment:comment];
}

#ifdef INCLUDE_MEIQIA_SDK
#pragma MQServiceToViewInterfaceErrorDelegate 后端返回的数据的错误委托方法
- (void)getLoadHistoryMessageError {
    [self.chatTableView finishLoadingTopRefreshViewWithCellNumber:0 isLoadOver:YES];
    [MQToast showToast:[MQBundleUtil localizedStringForKey:@"load_history_message_error"] duration:1.0 window:self.view];
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
    
    if ([titleLabel.text isEqualToString:[MQBundleUtil localizedStringForKey:@"no_agent_title"]] || [MQServiceToViewInterface waitingInQueuePosition] > 0) {
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

#pragma mark - rotation

// ios7以下系统的横屏的事件
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateTableCells];
    [self.view endEditing:YES];
}

// ios8以上系统的横屏的事件
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateTableCells];
    }];
    [self.view endEditing:YES];
}

- (void)updateTableCells {
    chatViewService.chatViewWidth = self.chatTableView.frame.size.width;
    [chatViewService updateCellModelsFrame];
    [self.chatTableView reloadData];
}

#pragma mark - input content view deletate

- (void)inputContentView:(MQInputContentView *)inputContentView userObjectChange:(NSObject *)object {
    self.chatInputBar.buttonGroupBar.buttons = [NSMutableArray new];
    CGRect rect = CGRectMake(0, 0, 40, 40);
    UIButton *recorderBtn  = [[UIButton alloc] initWithFrame:rect];
    [recorderBtn setImage:[MQAssetUtil imageFromBundleWithName:@"micIcon"] forState:(UIControlStateNormal)];
    [recorderBtn addTarget:self action:@selector(showRecorder) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *cameraBtn  = [[UIButton alloc] initWithFrame:rect];
    [cameraBtn setImage:[MQAssetUtil imageFromBundleWithName:@"cameraIcon"] forState:(UIControlStateNormal)];
    [cameraBtn addTarget:self action:@selector(camera) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *imageRoll  = [[UIButton alloc] initWithFrame:rect];
    [imageRoll setImage:[MQAssetUtil imageFromBundleWithName:@"imageIcon"] forState:(UIControlStateNormal)];
    [imageRoll addTarget:self action:@selector(imageRoll) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *emoji  = [[UIButton alloc] initWithFrame:rect];
    [emoji setImage:[MQAssetUtil imageFromBundleWithName:@"emoji"] forState:(UIControlStateNormal)];
    [emoji addTarget:self action:@selector(emoji) forControlEvents:(UIControlEventTouchUpInside)];
    
    if ([MQChatViewConfig sharedConfig].enableSendVoiceMessage) {
        [self.chatInputBar.buttonGroupBar addButton:recorderBtn];
    }
    
    if ([MQChatViewConfig sharedConfig].enableSendImageMessage) {
        [self.chatInputBar.buttonGroupBar addButton:cameraBtn];
        [self.chatInputBar.buttonGroupBar addButton:imageRoll];
    }
    
    if ([MQChatViewConfig sharedConfig].enableSendEmoji) {
        [self.chatInputBar.buttonGroupBar addButton:emoji];
    }
    
}

- (BOOL)handleSendMessageAbility {
    if ([MQServiceToViewInterface waitingInQueuePosition] > 0 && [MQServiceToViewInterface getCurrentAgent].privilege != MQAgentPrivilegeBot) {
        [self.view.window endEditing:YES];
        [MQToast showToast:@"正在排队，请等待客服接入后发送消息" duration:2.5 window:self.view.window];
        return NO;
    }
    return YES;
}

- (void)showRecorder {
    if ([self handleSendMessageAbility]) {
        if (self.chatInputBar.isFirstResponder) {
            [self.chatInputBar resignFirstResponder];
        }else{
            self.chatInputBar.inputView = self.displayRecordView;
            [self.chatInputBar becomeFirstResponder];
        }
    }
}

- (void)camera {
    if ([self handleSendMessageAbility]) {
        [self sendImageWithSourceType:(UIImagePickerControllerSourceTypeCamera)];
    }
}

- (void)imageRoll {
    if ([self handleSendMessageAbility]) {
        [self sendImageWithSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
    }
}

- (void)emoji {
    if ([self handleSendMessageAbility]) {
        if (self.chatInputBar.isFirstResponder) {
            [self.chatInputBar resignFirstResponder];
        }else{
            self.chatInputBar.inputView = self.emojiView;
            [self.chatInputBar becomeFirstResponder];
        }
    }
}

- (BOOL)inputContentViewShouldReturn:(MQInputContentView *)inputContentView content:(NSString *)content userObject:(NSObject *)object {

    if ([content length] > 0) {
        if ([self handleSendMessageAbility]) {
            [self sendTextMessage:content];
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)inputContentViewShouldBeginEditing:(MQInputContentView *)inputContentView {
    return YES;
}

#pragma mark - inputbar delegate

- (void)inputBar:(MQInputToolBar *)inputBar willChangeHeight:(CGFloat)height {
    if (height > kMQChatViewInputBarHeight) {
        CGFloat diff = height - self.constaintInputBarHeight.constant;
        if (diff < self.chatTableView.contentInset.top + self.self.chatTableView.contentSize.height) {
            self.chatTableView.contentOffset = CGPointMake(self.chatTableView.contentOffset.x, self.chatTableView.contentOffset.y + diff);
        }
        
        [self changeInputBarHeightConstraintConstant:height];
    }else{
        [self changeInputBarHeightConstraintConstant:kMQChatViewInputBarHeight];
    }
}

- (void)changeInputBarHeightConstraintConstant:(CGFloat)height {
    self.constaintInputBarHeight.constant = height;
    
    self.keyboardController.keyboardTriggerPoint = CGPointMake(0, height);
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)changeInputBarBottomLayoutGuideConstant:(CGFloat)height {
    self.constraintInputBarBottom.constant = height;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

#pragma mark - keyboard controller delegate
- (void)keyboardController:(MQKeyboardController *)keyboardController keyboardChangeFrame:(CGRect)keyboardFrame isImpressionOfGesture:(BOOL)isImpressionOfGesture {

    CGFloat viewHeight = self.navigationController.navigationBar.translucent ? CGRectGetMaxY(self.view.frame) : CGRectGetMaxY(self.view.frame) - 64;
    CGFloat heightFromBottom = MAX(0.0, viewHeight - CGRectGetMinY(keyboardFrame));
    
    if (!isImpressionOfGesture) {
        CGFloat diff = heightFromBottom - self.constraintInputBarBottom.constant;
        if (diff < self.chatTableView.contentInset.top + self.chatTableView.contentSize.height) {
            self.chatTableView.contentOffset = CGPointMake(self.chatTableView.contentOffset.x, self.chatTableView.contentOffset.y + diff);
        }
    }
    
    [self changeInputBarBottomLayoutGuideConstant:heightFromBottom];
}

#pragma mark - MCRecorderViewDelegate

- (void)recordEnd {
    [self finishRecord:CGPointZero];
}

- (void)recordStarted {
    [self beginRecord:CGPointZero];
}

- (void)recordCanceld {
    [self cancelRecord:CGPointZero];
}

#pragma mark - emoji delegate and datasource

- (void)emojiKeyBoardView:(MQAGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    MEIQIA_HPGrowingTextView *textField = [(MQTabInputContentView *)self.chatInputBar.contentView textField];
    textField.text = [textField.text stringByAppendingString:emoji];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(MQAGEmojiKeyboardView *)emojiKeyBoardView {
    MEIQIA_HPGrowingTextView *textField = [(MQTabInputContentView *)self.chatInputBar.contentView textField];
    if (textField.text.length > 0) {
        NSRange lastRange = [textField.text rangeOfComposedCharacterSequenceAtIndex:([textField.text length] - 1)];
        textField.text = [textField.text stringByReplacingCharactersInRange:lastRange withString:@""];
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

#pragma mark - lazy

- (MQEvaluationView *)evaluationView {
    if (!_evaluationView) {
        _evaluationView = [[MQEvaluationView alloc] init];
        _evaluationView.delegate = self;
    }
    return _evaluationView;
}

- (MQInputToolBar *)chatInputBar {
    if (!_chatInputBar) {
        MQTabInputContentView *contentView = [[MQTabInputContentView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 118)];
        _chatInputBar = [[MQInputToolBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kMQChatViewInputBarHeight) contentView: contentView];
        _chatInputBar.delegate = self;
        _chatInputBar.contentViewDelegate = self;
        [contentView setupButtons];
        _chatInputBar.backgroundColor = [UIColor greenColor];
    }
    return _chatInputBar;
}

- (MQKeyboardController *)keyboardController {
    if (!_keyboardController) {
        _keyboardController = [[MQKeyboardController alloc] initWithResponders:@[self.chatInputBar.contentView, self.chatInputBar] contextView:self.view panGestureRecognizer:self.chatTableView.panGestureRecognizer delegate:self];
        _keyboardController.keyboardTriggerPoint = CGPointMake(0, self.constaintInputBarHeight.constant);
    }
    return _keyboardController;
}

- (MQRecorderView *)displayRecordView {
    if (!_displayRecordView) {
        _displayRecordView = [[MQRecorderView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 258)];
        _displayRecordView.delegate = self;
        _displayRecordView.backgroundColor = [[UIColor alloc] initWithRed: 242/255.0 green: 242/255.0 blue: 247/255.0 alpha: 1];
    }
    return _displayRecordView;
}

- (MQRecordView *)recordView {
    //如果开发者不自定义录音界面，则将播放界面显示出来
    if (!_recordView) {
        _recordView = [[MQRecordView alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    self.chatTableView.frame.size.width,
                                                                    /*viewSize.height*/[UIScreen mainScreen].bounds.size.height - self.chatInputBar.frame.size.height)
                                       maxRecordDuration:[MQChatViewConfig sharedConfig].maxVoiceDuration];
        _recordView.recordMode = [MQChatViewConfig sharedConfig].recordMode;
        _recordView.keepSessionActive = [MQChatViewConfig sharedConfig].keepAudioSessionActive;
        _recordView.recordViewDelegate = self;
//        [self.view addSubview:_recordView];
    }
    
    return _recordView;
}

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
        translucentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicatorView setCenter:CGPointMake(self.chatTableView.frame.size.width / 2.0, self.chatTableView.frame.size.height / 2.0)];
        [translucentView addSubview:activityIndicatorView];
        activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
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

- (MQAGEmojiKeyboardView *)emojiView {
    if (!_emojiView) {
        _emojiView = [[MQAGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
        _emojiView.delegate = self;
        _emojiView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _emojiView;
}

@end
