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
#import "MQBottomBar.h"
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
#import "MQRefresh.h"
#import "MQTextCellModel.h"
#import "MQTipsCellModel.h"
#import "MQRichTextViewModel.h"
#import "MQWebViewBubbleCellModel.h"
#import "MQToolUtil.h"
#import "MQChatViewManager.h"
#import <MeiQiaSDK/MQManager.h>
#import "MEIQIA_InputView.h"
#import "MQCellModelProtocol.h"
#import "MQVideoPlayerViewController.h"
#import "MQNotificationManager.h"

static CGFloat const kMQChatViewInputBarHeight = 80.0;

@interface MQChatViewController () <UITableViewDelegate, MQChatViewServiceDelegate, MQBottomBarDelegate, UIImagePickerControllerDelegate, MQChatTableViewDelegate, MQChatCellDelegate, MQServiceToViewInterfaceErrorDelegate,UINavigationControllerDelegate, MQEvaluationViewDelegate, MQInputContentViewDelegate, MQKeyboardControllerDelegate, MQRecordViewDelegate, MQRecorderViewDelegate,MEIQIA_InputViewDelegate>

@property(nonatomic, strong)MQChatViewService *chatViewService;

@end

@interface MQChatViewController()

@property (nonatomic, strong) id evaluateBarButtonItem;//保存隐藏的barButtonItem
@property (nonatomic, strong) MQBottomBar *bottomBar;
@property (nonatomic, strong) NSLayoutConstraint *constaintInputBarHeight;
@property (nonatomic, strong) NSLayoutConstraint *constraintInputBarBottom;
@property (nonatomic, strong) MQEvaluationView *evaluationView;
@property (nonatomic, strong) MQKeyboardController *keyboardView;
@property (nonatomic, strong) MQRecordView *recordView;
@property (nonatomic, strong) MQRecorderView *displayRecordView;//只用来显示
@property (nonatomic, assign) bool sendVideoMsgStatus;

@property (nonatomic, assign) BOOL isFirstScheduleClient;

@property (nonatomic, assign) BOOL showEvaluatBarButton; // 是否显示评价按钮，需要在访客发送了消息才能显示

@end

@implementation MQChatViewController {
    MQChatViewConfig *chatViewConfig;
    MQChatViewTableDataSource *tableDataSource;
    BOOL isMQSocketFailed;  //socket通信没有连接上
    UIStatusBarStyle previousStatusBarStyle;//当前statusBar样式
    BOOL previousStatusBarHidden;   //调出聊天视图界面前是否隐藏 statusBar
    NSTimeInterval sendTime;        //发送时间，用于限制发送频率
    UIView *translucentView;        //loading 的半透明层
    UIActivityIndicatorView *activityIndicatorView; //loading
    UILabel *networkStatusLable;        //网络链接不可用的提示Label
    
    BOOL shouldSendInputtingMessageToServer;
    BOOL needToBotttom;
    BOOL willDisapper; // 页面即将消失
}

- (void)dealloc {
    [self removeDelegateAndObserver];
    [chatViewConfig setConfigToDefault];
    [self.chatViewService setCurrentInputtingText:[(MQTabInputContentView *)self.bottomBar.contentView textField].text];
    [self closeMeiqiaChatView];
    [MQCustomizedUIText reset];
    [MQServiceToViewInterface completeChat];
    [MQServiceToViewInterface insertMQGroupNotificationToConversion:nil];
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
    needToBotttom = YES;
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
    
    
    self.chatViewService.chatViewWidth = self.chatTableView.frame.size.width;
    
#ifdef INCLUDE_MEIQIA_SDK
    //[self updateNavBarTitle:[MQBundleUtil localizedStringForKey:@"wait_agent"]];
    isMQSocketFailed = NO;
    [self addObserver];
#endif
    
    if ([MQChatViewConfig sharedConfig].presentingAnimation == MQTransiteAnimationTypePush) {
        UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
        popRecognizer.edges = UIRectEdgeLeft;
        [self.view addGestureRecognizer:popRecognizer];
    }
    
    [self presentUI];
    
    shouldSendInputtingMessageToServer = YES;
    
    if (![MQManager obtainNetIsReachable]) {
        [self showNetworkStatusViewWithText:[MQBundleUtil localizedStringForKey:@"network_connect_error"]];
    }
}

- (void)presentUI {
    
    __weak typeof(self) weakSelf = self;
    [MQPreChatFormListViewController usePreChatFormIfNeededOnViewController:self compeletion:^(NSDictionary *userInfo){

        // 询前表单界面返回的数据，如果未进入表单，则为空,如果进入表单则userInfo为表单提交信息
        /**
           {
               menu = "价格";
               target = dbd2e3a951bb7563873e9223073c5149;
               targetType = agent;
           }
         */
        NSString *targetType = userInfo[@"targetType"];
        NSString *target = userInfo[@"target"];
        NSString *menu = userInfo[@"menu"];
        if ([targetType isEqualToString:@"agent"]) {
            [MQChatViewConfig sharedConfig].scheduledAgentId = target;
        } else if ([targetType isEqualToString:@"group"]) {
            [MQChatViewConfig sharedConfig].scheduledGroupId = target;
        }
        if ([menu length] > 0) {
            [weakSelf.chatViewService selectedFormProblem:menu];
            NSMutableArray *m = [[MQChatViewConfig sharedConfig].preSendMessages mutableCopy] ?: [NSMutableArray new];
            [m addObject:menu];
            [MQChatViewConfig sharedConfig].preSendMessages = m;
        }
        // TODO: [MQServiceToViewInterface prepareForChat]也会初始化企业配置，这里会导致获取企业配置的接口调用两次,APP第一次初始化时会调3次
        [MQServiceToViewInterface getEnterpriseConfigInfoWithCache:YES complete:^(MQEnterprise *enterprise, NSError *e) {
            weakSelf.sendVideoMsgStatus = enterprise.configInfo.videoMsgStatus;
            weakSelf.isFirstScheduleClient = YES;
            [weakSelf.chatViewService setClientOnline];
        }];
    } cancle:^{
        //讯前表单 左返回按钮
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            [weakSelf dismissChatViewController];
        }];
    }];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:MQAudioPlayerDidInterruptNotification object:nil];

    //恢复原来的导航栏时间条
    [UIApplication sharedApplication].statusBarStyle = previousStatusBarStyle;
    
    [[UIApplication sharedApplication] setStatusBarHidden:previousStatusBarHidden];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.keyboardView beginListeningForKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    willDisapper = YES;
    [self.keyboardView endListeningForKeyboard];
    
    if ([MQServiceToViewInterface waitingInQueuePosition] > 0) {
        [self.chatViewService saveTextDraftIfNeeded:(UITextField *)[(MQTabInputContentView *)self.bottomBar.contentView textField]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    willDisapper = NO;
    [UIView setAnimationsEnabled:YES];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self.chatViewService fillTextDraftToFiledIfExists:(UITextField *)[(MQTabInputContentView *)self.bottomBar.contentView textField]];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRefreshOutgoingAvatarNotification:) name:MQChatTableViewShouldRefresh object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSocketStatusChangeNotification:) name:MQ_NOTIFICATION_SOCKET_STATUS_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSocketConnectFailedNotification:) name:MQ_COMMUNICATION_FAILED_NOTIFICATION object:nil];
    if (![MQNotificationManager sharedManager].handleNotification) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveClickGroupNotification:) name:MQ_CLICK_GROUP_NOTIFICATION object:nil];
    }
#endif
}

- (void)removeDelegateAndObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma 初始化viewModel
- (void)initchatViewService {
    self.chatViewService = [[MQChatViewService alloc] initWithDelegate:self errorDelegate:self];
}

#pragma 初始化tableView dataSource
- (void)initTableViewDataSource {
    tableDataSource = [[MQChatViewTableDataSource alloc] initWithChatViewService: self.chatViewService];
    tableDataSource.chatCellDelegate = self;
    self.chatTableView.dataSource = tableDataSource;
}

#pragma mark - 初始化所有Views
/**
 * 初始化聊天的tableView
 */
- (void)initChatTableView {
    self.chatTableView = [[MQChatTableView alloc] initWithFrame:chatViewConfig.chatViewFrame style:UITableViewStylePlain];
    self.chatTableView.chatTableViewDelegate = self;
    
    //xlp 修复 发送消息 或者受到消息 会弹一下
    self.chatTableView.estimatedRowHeight = 0;
    self.chatTableView.estimatedSectionFooterHeight = 0;
    self.chatTableView.estimatedSectionHeaderHeight = 0;
    if (@available(iOS 15.0, *)) {
        self.chatTableView.sectionHeaderTopPadding = 0;
    }
    
    if (@available(iOS 11.0, *)) {
        self.chatTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
    self.chatTableView.delegate = self;
    [self.view addSubview:self.chatTableView];
    
    __weak typeof(self) wself = self;
    [self.chatTableView setupPullRefreshWithAction:^{
        __strong typeof (wself) sself = wself;
        [sself.chatViewService startGettingHistoryMessages];
    }];
    
    [self.chatTableView.refreshView setText:[MQBundleUtil localizedStringForKey:@"pull_refresh_normal"] forStatus: MQRefreshStatusDraging];
    [self.chatTableView.refreshView setText:[MQBundleUtil localizedStringForKey:@"pull_refresh_triggered"] forStatus: MQRefreshStatusTriggered];
    [self.chatTableView.refreshView setText:[MQBundleUtil localizedStringForKey:@"no_more_messages"] forStatus: MQRefreshStatusEnd];
}

/**
 * 初始化聊天的inpur bar
 */
- (void)initInputBar {
    [self.view addSubview:self.bottomBar];
}

- (void)layoutViews {
    self.chatTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constrains = [NSMutableArray new];
    
    [constrains addObjectsFromArray:[self addFitWidthConstraintsToView:self.chatTableView onTo:self.view]];
    [constrains addObjectsFromArray:[self addFitWidthConstraintsToView:self.bottomBar onTo:self.view]];
    
    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.chatTableView attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeTop) multiplier:1 constant:0]];
    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.chatTableView attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeLeft) multiplier:1 constant:0]];
    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.chatTableView attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeRight) multiplier:1 constant:0]];
    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.chatTableView attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self.bottomBar attribute:(NSLayoutAttributeTop) multiplier:1 constant:0]];
   

    
    self.constraintInputBarBottom = [NSLayoutConstraint constraintWithItem:self.view attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self.bottomBar attribute:(NSLayoutAttributeBottom) multiplier:1 constant: (MQToolUtil.kMQObtainDeviceVersionIsIphoneX > 0 ? 34 : 0)];
    
    [constrains addObject:self.constraintInputBarBottom];
    [self.view addConstraints:constrains];
    
    self.constaintInputBarHeight = [NSLayoutConstraint constraintWithItem:self.bottomBar attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:(NSLayoutAttributeNotAnAttribute) multiplier:1 constant:kMQChatViewInputBarHeight];
    
    [self.bottomBar addConstraint:self.constaintInputBarHeight];
    
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

#pragma mark - MQChatTableViewDelegate

- (void)didTapChatTableView:(UITableView *)tableView {
    [self.view endEditing:true];
}

- (void)tapNavigationRightBtn:(id)sender {
    [self showEvaluationAlertView];
}

- (void)tapNavigationRedirectBtn:(id)sender {
    [self.chatViewService forceRedirectToHumanAgent];
    [self showActivityIndicatorView];
}

- (void)didSelectNavigationRightButton {
    NSLog(@"点击了自定义导航栏右键，开发者可在这里增加功能。");
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<MQCellModelProtocol> cellModel = [self.chatViewService.cellModels objectAtIndex:indexPath.row];
    return [cellModel getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.000001;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.chatTableView.refreshView.status == MQRefreshStatusTriggered) {
        [self.chatTableView startAnimation];
    }
    needToBotttom = false;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentH = scrollView.contentSize.height;
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat sizeH = scrollView.bounds.size.height;
    if (offsetY > contentH - 1.5 * sizeH) {
        needToBotttom = true;
    }
}

- (void)didGetHistoryMessagesWithCommitTableAdjustment:(void(^)(void))commitTableAdjustment {
    __weak typeof(self) wself = self;
    [self.chatTableView stopAnimationCompletion:^{
        __strong typeof (wself) sself = wself;
        CGFloat oldHeight = sself.chatTableView.contentSize.height;
        commitTableAdjustment();
        CGFloat heightIncreatment = sself.chatTableView.contentSize.height - oldHeight;
        if (heightIncreatment > 0) {
            heightIncreatment -= sself.chatTableView.refreshView.bounds.size.height;
            sself.chatTableView.contentOffset = CGPointMake(0, heightIncreatment);
            [sself.chatTableView flashScrollIndicators];
        } else {
            [sself.chatTableView setLoadEnded];
        }
    }];
}

- (void)didUpdateCellModelWithIndexPath:(NSIndexPath *)indexPath needToBottom:(BOOL)toBottom {
    [self.chatTableView updateTableViewAtIndexPath:indexPath];
    toBottom ? [self chatTableViewScrollToBottomWithAnimated:false] : nil;
}

- (void)insertCellAtBottomForModelCount:(NSInteger)count {
    [self checkEvaluationBarButton];
    NSMutableArray *indexToAdd = [NSMutableArray new];
    NSInteger currentCellCount = [self.chatTableView numberOfRowsInSection: 0];
    for (int i = 0; i < count; i ++) {
        [indexToAdd addObject:[NSIndexPath indexPathForRow:currentCellCount + i inSection:0]];
    }
    [self.chatTableView insertRowsAtIndexPaths:indexToAdd withRowAnimation:(UITableViewRowAnimationBottom)];
}

- (void)insertCellAtTopForModelCount:(NSInteger)count {
    NSMutableArray *indexToAdd = [NSMutableArray new];
    for (int i = 0; i < count; i ++) {
        [indexToAdd insertObject:[NSIndexPath indexPathForRow:i inSection:0] atIndex: 0];
    }
    [self.chatTableView insertRowsAtIndexPaths:indexToAdd withRowAnimation:(UITableViewRowAnimationTop)];
}

- (void)insertCellAtCurrentIndex:(NSInteger)currentRow modelCount:(NSInteger)count {
    NSMutableArray *indexToAdd = [NSMutableArray new];
    for (int i = 0; i < count; i ++) {
        [indexToAdd addObject:[NSIndexPath indexPathForRow:currentRow + i inSection:0]];
    }

    [self.chatTableView insertRowsAtIndexPaths:indexToAdd withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)removeCellAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: index inSection: 0];
    [self.chatTableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationFade];
}

- (void)reloadChatTableView {
    [self.chatTableView reloadData];
}

- (void)scrollTableViewToBottomAnimated:(BOOL)animated {
    [self checkEvaluationBarButton];
    [self chatTableViewScrollToBottomWithAnimated: animated];
}

- (void)showEvaluationAlertView {
    if (!willDisapper) {
        [self.view.window endEditing:YES];
        [self.evaluationView showEvaluationAlertView];
    }
}

- (BOOL)isChatRecording {
    return [self.recordView isRecording];
}

- (void)needToDisplayLeaveComment:(BOOL)display {
    if (self.isFirstScheduleClient && display) {
        self.isFirstScheduleClient = NO;
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        MQMessageFormViewManager *formManager = [[MQMessageFormViewManager alloc] init];
        [formManager pushMQMessageFormViewControllerInViewController:self.navigationController.presentingViewController];
    }
    self.isFirstScheduleClient = NO;
}

- (void)didScheduleClientWithViewTitle:(NSString *)viewTitle agentStatus:(MQChatAgentStatus)agentStatus{
    
    [self updateNavTitleWithAgentName:viewTitle agentStatus:agentStatus];
}

- (void)changeNavReightBtnWithAgentType:(NSString *)agentType hidden:(BOOL)hidden {
    // 隐藏 loading
    [self dismissActivityIndicatorView];
    UIBarButtonItem *item = nil;
    self.showEvaluatBarButton = NO;
    if ([agentType isEqualToString:@"bot"]) {
        __weak typeof(self) weakSelf = self;
        [MQServiceToViewInterface getIsShowRedirectHumanButtonComplete:^(BOOL isShow, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (isShow && strongSelf) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
                btn.frame = CGRectMake(0, 0, 30, 30);
                [btn setTitle:[MQBundleUtil localizedStringForKey:@"meiqia_redirect_sheet"] forState:UIControlStateNormal];
                btn.titleLabel.font = [MQChatViewConfig sharedConfig].chatViewStyle.navTitleFont ?: [UIFont systemFontOfSize:16.0];
                [btn addTarget:strongSelf action:@selector(tapNavigationRedirectBtn:) forControlEvents:UIControlEventTouchUpInside];
                strongSelf.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
            }
        }];
        return;
    } else if ([MQChatViewConfig sharedConfig].navBarRightButton) {
        item = [[UIBarButtonItem alloc]initWithCustomView:[MQChatViewConfig sharedConfig].navBarRightButton];
    } else {
        if (![MQChatViewConfig sharedConfig].navBarRightButton && !hidden && [MQChatViewConfig sharedConfig].enableEvaluationButton && [MQServiceToViewInterface allowActiveEvaluation]) {
            self.showEvaluatBarButton = YES;
        }
    }
    
    self.navigationItem.rightBarButtonItem = item;
}

- (void)checkEvaluationBarButton {
    if (self.showEvaluatBarButton && [self.chatViewService haveSendMessage]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(0, 0, 30, 30);
        [btn setTitle:[MQBundleUtil localizedStringForKey:@"meiqia_evaluation_sheet"] forState:UIControlStateNormal];
        btn.titleLabel.font = [MQChatViewConfig sharedConfig].chatViewStyle.navTitleFont ?: [UIFont systemFontOfSize:16.0];
        [btn addTarget:self action:@selector(tapNavigationRightBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

        self.showEvaluatBarButton = NO;
    }
}

- (void)didReceiveMessage {
    //判断是否显示新消息提示  旧版本 是根据此时 是否已经滚动到底部,不在底部 则toast 提示新消息 否则直接显示最新消息
    if ([self.chatTableView isTableViewScrolledToBottom]) {
        [self chatTableViewScrollToBottomWithAnimated: YES];
    } else {
        if ([MQChatViewConfig sharedConfig].enableShowNewMessageAlert) {
            [MQToast showToast:[MQBundleUtil localizedStringForKey:@"display_new_message"] duration:1.5 window:[[UIApplication sharedApplication].windows lastObject]];
        }
    }
}

- (void)showToastViewWithContent:(NSString *)content {
    [MQToast showToast:content duration:1.0 window:self.view];
}

#pragma mark - MQInputBarDelegate


- (BOOL)sendMessagePrepareWithText:(NSString *)text image:(UIImage *)image andAMRFilePath:(NSString *)filePath andVideoFilePath:(NSString *)videoPath {
    // 判断当前顾客是否正在登陆，如果正在登陆，显示禁止发送的提示
    if (self.chatViewService.clientStatus == MQStateAllocatingAgent || [NSDate timeIntervalSinceReferenceDate] - sendTime < 1) {
        NSString *alertText = self.chatViewService.clientStatus == MQStateAllocatingAgent ? @"cannot_text_client_is_onlining" : @"send_to_fast";
        [MQToast showToast:[MQBundleUtil localizedStringForKey:alertText] duration:2 window:self.view.window];
        [[(MQTabInputContentView *)self.bottomBar.contentView textField] setText:text];
        return NO;
    }
    
    if (self.chatViewService.clientStatus == MQStateUnallocatedAgent) {
        [self.view endEditing:YES];
    }
    if (text) {
        [self.chatViewService sendTextMessageWithContent:text];
    } else if (image) {
        [self.chatViewService sendImageMessageWithImage:image];
    } else if (filePath) {
        [self.chatViewService sendVoiceMessageWithAMRFilePath:filePath];
    } else if (videoPath) {
        [self.chatViewService sendVideoMessageWithFilePath:videoPath];
    }
    sendTime = [NSDate timeIntervalSinceReferenceDate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self chatTableViewScrollToBottomWithAnimated:YES];
    });
    return YES;
}

// 发送文本消息
-(BOOL)sendTextMessage:(NSString*)text {
    // 判断当前顾客是否正在登陆，如果正在登陆，显示禁止发送的提示
    return [self sendMessagePrepareWithText:text image:nil andAMRFilePath:nil andVideoFilePath:nil];
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
    if (self.chatViewService.clientStatus == MQStateAllocatingAgent || [NSDate timeIntervalSinceReferenceDate] - sendTime < 1) {
        NSString *alertText = self.chatViewService.clientStatus == MQStateAllocatingAgent ? @"cannot_text_client_is_onlining" : @"send_to_fast";
        [MQToast showToast:[MQBundleUtil localizedStringForKey:alertText] duration:2 window:self.view];
        return ;
    }
    sendTime = [NSDate timeIntervalSinceReferenceDate];
    self.navigationController.delegate = self;
    //兼容ipad打不开相册问题，使用队列延迟
//    videoExportPreset
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType               = (int)sourceType;
        picker.mediaTypes               = self.sendVideoMsgStatus ? @[@"public.movie",@"public.image"] : @[@"public.image"];
        picker.videoQuality             = UIImagePickerControllerQualityTypeHigh;
        picker.delegate                 = (id)self;
        picker.allowsEditing            = [MQChatViewConfig sharedConfig].enablePhotoLibraryEdit;
        if (@available(iOS 11.0, *)) {
            picker.videoExportPreset    = AVAssetExportPresetPassthrough;
        }
        picker.modalPresentationStyle   = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:nil];
    }];
}

- (void)inputContentTextDidChange:(NSString *)newString {
    if ([MQManager getCurrentState] == MQStateAllocatedAgent){

        if (shouldSendInputtingMessageToServer && newString.length > 0) {
            shouldSendInputtingMessageToServer = NO;
            [self.chatViewService sendUserInputtingWithContent:newString];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self->shouldSendInputtingMessageToServer = YES;

            });
        }
    }
}

- (void)chatTableViewScrollToBottomWithAnimated:(BOOL)animated {
    NSInteger cellCount = [self.chatTableView numberOfRowsInSection:0];
    if (cellCount > 0) {
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: cellCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)beginRecord:(CGPoint)point {
    if (TARGET_IPHONE_SIMULATOR){
        [MQToast showToast:[MQBundleUtil localizedStringForKey:@"simulator_not_support_microphone"] duration:2 window:self.view];
        return;
    }
    
    // 判断当前顾客是否正在登陆，如果正在登陆，显示禁止发送的提示
    if (self.chatViewService.clientStatus == MQStateAllocatingAgent || [NSDate timeIntervalSinceReferenceDate] - sendTime < 1) {
        NSString *alertText = self.chatViewService.clientStatus == MQStateAllocatingAgent ? @"cannot_text_client_is_onlining" : @"send_to_fast";
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
//    [self.chatViewService sendVoiceMessageWithAMRFilePath:filePath];
//    [self chatTableViewScrollToBottomWithAnimated:true];
    [self sendMessagePrepareWithText:nil image:nil andAMRFilePath:filePath andVideoFilePath:nil];
}

- (void)didUpdateVolumeInRecordView:(UIView *)recordView volume:(CGFloat)volume {
    [self.displayRecordView changeVolumeLayerDiameter:volume];
}

#pragma UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type          = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        // 图片
        UIImage *image          =  [MQImageUtil resizeImage:[MQImageUtil fixrotation:[info objectForKey:[MQChatViewConfig sharedConfig].enablePhotoLibraryEdit ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage]]maxSize:CGSizeMake(1000, 1000)];
        [picker dismissViewControllerAnimated:YES completion:^{
    //        [self.chatViewService sendImageMessageWithImage:image];
    //        [self chatTableViewScrollToBottomWithAnimated:true];
            [self sendMessagePrepareWithText:nil image:image andAMRFilePath:nil andVideoFilePath:nil];
        }];
        return;
    } else if ([type isEqualToString:@"public.movie"]) {
        // 视频
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if (videoUrl) {
            float videoSize = [MQChatFileUtil getfileSizeAtPath:[videoUrl path]];
            if (videoSize > 400 * 1024 * 1024) {
                [MQToast showToast:[MQBundleUtil localizedStringForKey:@"display_video_more_than_limit"] duration:2 window:[UIApplication sharedApplication].keyWindow];
                [MQChatFileUtil deleteFileAtPath:[videoUrl path]];
                return;
            }
            NSString *resultPath = [MQChatFileUtil saveVideoSourceWith:videoUrl];
            if (resultPath) {
                [self sendMessagePrepareWithText:nil image:nil andAMRFilePath:nil andVideoFilePath:resultPath];
            }
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
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
    [self.chatViewService resendMessageAtIndex:indexPath.row resendData:resendData];
    [self chatTableViewScrollToBottomWithAnimated:true];
}

- (void)replaceTipCell:(UITableViewCell *)cell {
    
}

- (void)reloadCellAsContentUpdated:(UITableViewCell *)cell messageId:(NSString *)messageId {
    [self.chatTableView reloadData];
    [self.chatTableView layoutIfNeeded];
    if (needToBotttom) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow: ([weakSelf.chatTableView numberOfRowsInSection:([weakSelf.chatTableView numberOfSections]-1)]-1) inSection:([weakSelf.chatTableView numberOfSections]-1)];
        [weakSelf.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:false];
        });
    }
}

- (void)deleteCell:(UITableViewCell *)cell withTipMsg:(NSString *)tipMsg enableLinesDisplay:(BOOL)enable{
    NSIndexPath *indexPath = [self.chatTableView indexPathForCell:cell];
    [self.chatViewService deleteMessageAtIndex:indexPath.row withTipMsg:tipMsg enableLinesDisplay:enable];
    [self chatTableViewScrollToBottomWithAnimated:true];
}


- (void)didSelectMessageInCell:(UITableViewCell *)cell messageContent:(NSString *)content selectedContent:(NSString *)selectedContent {
    
}

- (void)evaluateBotAnswer:(BOOL)isUseful messageId:(NSString *)messageId {
    [self.chatViewService evaluateBotAnswer:isUseful messageId:messageId];
}

- (void)collectionOperationIndex:(int)index messageId:(NSString *)messageId {
    [self.chatViewService collectionOperationIndex:index messageId:messageId];
}

- (void)didTapMenuWithText:(NSString *)menuText {
    //去掉 menu 的序号后，主动发送该 menu 消息
    NSRange orderRange = [menuText rangeOfString:@". "];
    if (orderRange.location == NSNotFound) {
        return ;
    }
    NSString *sendText = [menuText substringFromIndex:orderRange.location+2];
    [self.chatViewService sendTextMessageWithContent:sendText];
    [self chatTableViewScrollToBottomWithAnimated:YES];
}

- (void)didTapGuideWithText:(NSString *)guideText {
    [self.chatViewService sendTextMessageWithContent:guideText];
    [self chatTableViewScrollToBottomWithAnimated:YES];
}

- (void)didTapReplyBtn {
    if ([MQServiceToViewInterface enableLeaveComment]) {
        [self showMQMessageForm];
    }
}

- (void)didTapBotRedirectBtn {
    [self tapNavigationRedirectBtn:nil];
}

- (void)didTapMessageInCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.chatTableView indexPathForCell:cell];
    [self.chatViewService didTapMessageCellAtIndex:indexPath.row];
}

- (void)showPlayVideoControllerWith:(NSString *)videoLocalPath serverPath:(NSString *)videoServer {
    MQVideoPlayerViewController *playerVC = [[MQVideoPlayerViewController alloc] initPlayerWithLocalPath:videoLocalPath serverPath:videoServer];
    [self presentViewController:playerVC animated:YES completion:nil];
}

- (void)didTapProductCard:(NSString *)productUrl {
    
    if (chatViewConfig.productCardCallBack) {
        chatViewConfig.productCardCallBack(productUrl);
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:productUrl] options:@{} completionHandler:nil];
    }
}

#pragma MQEvaluationViewDelegate
- (void)didSelectLevel:(NSInteger)level comment:(NSString *)comment {
    [self.chatViewService sendEvaluationLevel:level comment:comment];
}

#ifdef INCLUDE_MEIQIA_SDK
#pragma MQServiceToViewInterfaceErrorDelegate 后端返回的数据的错误委托方法
- (void)getLoadHistoryMessageError {
    //    [self.chatTableView finishLoadingTopRefreshViewWithCellNumber:0 isLoadOver:YES];
    [self.chatTableView stopAnimationCompletion:^{
        
//        [MQToast showToast:[MQBundleUtil localizedStringForKey:@"load_history_message_error"] duration:1.0 window:self.view];

        //后端获取信息失败，取消错误信息提示，从数据库获取历史消息
        [self.chatViewService startGettingDateBaseHistoryMessages];
        
    }];
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
    CGFloat titleHeight = [MQStringSizeUtil getHeightForText:@"客服" withFont:titleLabel.font andWidth:self.view.frame.size.width];
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
    CGFloat maxTitleViewWidth = [[UIScreen mainScreen] bounds].size.width - 2 * 50;
    CGFloat statusImageWidth = statusImageView.image.size.width;
    CGFloat titleLabelOriginX = statusImageWidth + 8;
    CGFloat titleLabelWidth =  titleLabelOriginX + titleWidth > maxTitleViewWidth ? maxTitleViewWidth - (statusImageView.image.size.width + 8) : titleWidth;
    
    statusImageView.frame = CGRectMake(0, titleHeight/2 - statusImageView.image.size.height/2, statusImageWidth, statusImageView.image.size.height);
    titleLabel.frame = CGRectMake(titleLabelOriginX, 0, titleLabelWidth, titleHeight);
    titleView.frame = CGRectMake(0, 0, titleLabelOriginX + titleLabelWidth, titleHeight);
    [titleView addSubview:statusImageView];
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
}

- (void)didReceiveSocketConnectFailedNotification:(NSNotification *)notification {
    isMQSocketFailed = YES;
    if (![MQManager obtainNetIsReachable]) {
        [self showNetworkStatusViewWithText:[MQBundleUtil localizedStringForKey:@"network_connect_error"]];
    } else {
        [self showNetworkStatusViewWithText:[MQBundleUtil localizedStringForKey:@"network_connect_warning"]];
    }
}

- (void)didReceiveClickGroupNotification:(NSNotification *)notification {
    [self.chatViewService setClientOnline];
}

- (void)didReceiveSocketStatusChangeNotification:(NSNotification *)notification {
    if (notification.userInfo) {
        NSString *status = [notification.userInfo objectForKey:MQ_NOTIFICATION_SOCKET_STATUS_CHANGE];
        id reason = [notification.userInfo objectForKey:@"reason"];
        if ([status isEqualToString:SOCKET_STATUS_CONNECTED]) {
            isMQSocketFailed = NO;
            [self dismissNetworkStatusView];
        } else if ([status isEqualToString:SOCKET_STATUS_DISCONNECTED]) {
            isMQSocketFailed = YES;
            if (![MQManager obtainNetIsReachable]) {
                                [self showNetworkStatusViewWithText:[MQBundleUtil localizedStringForKey:@"network_connect_error"]];
            } else if (reason && ![reason isEqual:[NSNull null]] && [@"autoconnect fail" isEqualToString:reason]) {
                                [self showNetworkStatusViewWithText:[MQBundleUtil localizedStringForKey:@"network_connect_warning"]];
            }
        }
    }
}

- (void)didReceiveRefreshOutgoingAvatarNotification:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[UIImage class]]) {
        [self.chatViewService refreshOutgoingAvatarWithImage:notification.object];
    }
}

- (void)closeMeiqiaChatView {
    if ([self.navigationItem.title isEqualToString:[MQBundleUtil localizedStringForKey:@"no_agent_title"]]) {
        [self.chatViewService dismissingChatViewController];
    }
}

#pragma mark - rotation

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateTableCells];
    [self.view endEditing:YES];
    
}
#else
#endif

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
    self.chatViewService.chatViewWidth = self.chatTableView.frame.size.width;
    [self.chatViewService updateCellModelsFrame];
    [self.chatTableView reloadData];
}

#pragma mark - input content view deletate

- (void)inputContentView:(MQInputContentView *)inputContentView userObjectChange:(NSObject *)object {
    self.bottomBar.buttonGroupBar.buttons = [NSMutableArray new];
    CGRect rect = CGRectMake(0, 0, 40, 40);
    UIButton *recorderBtn  = [[UIButton alloc] initWithFrame:rect];
    [recorderBtn setImage: [MQChatViewConfig sharedConfig].chatViewStyle.voiceSenderImage forState:(UIControlStateNormal)];
    if ([MQChatViewConfig sharedConfig].chatViewStyle.voiceSenderHighlightedImage) {
        [recorderBtn setImage: [MQChatViewConfig sharedConfig].chatViewStyle.voiceSenderHighlightedImage forState:UIControlStateHighlighted];
    }
    [recorderBtn addTarget:self action:@selector(showRecorder) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *cameraBtn  = [[UIButton alloc] initWithFrame:rect];
    [cameraBtn setImage: [MQChatViewConfig sharedConfig].chatViewStyle.cameraSenderImage forState:(UIControlStateNormal)];
    if ([MQChatViewConfig sharedConfig].chatViewStyle.cameraSenderHighlightedImage) {
        [cameraBtn setImage: [MQChatViewConfig sharedConfig].chatViewStyle.cameraSenderHighlightedImage forState:UIControlStateHighlighted];
    }
    [cameraBtn addTarget:self action:@selector(camera) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *imageRoll  = [[UIButton alloc] initWithFrame:rect];
    [imageRoll setImage: [MQChatViewConfig sharedConfig].chatViewStyle.photoSenderImage forState:(UIControlStateNormal)];
    if ([MQChatViewConfig sharedConfig].chatViewStyle.photoSenderHighlightedImage) {
        [imageRoll setImage: [MQChatViewConfig sharedConfig].chatViewStyle.photoSenderHighlightedImage forState:UIControlStateHighlighted];
    }
    [imageRoll addTarget:self action:@selector(imageRoll) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *emoji  = [[UIButton alloc] initWithFrame:rect];
    [emoji setImage:[MQChatViewConfig sharedConfig].chatViewStyle.emojiSenderImage forState:(UIControlStateNormal)];
    if ([MQChatViewConfig sharedConfig].chatViewStyle.emojiSenderHighlightedImage) {
        [emoji setImage: [MQChatViewConfig sharedConfig].chatViewStyle.emojiSenderHighlightedImage forState:UIControlStateHighlighted];
    }
    [emoji addTarget:self action:@selector(emoji) forControlEvents:(UIControlEventTouchUpInside)];
    
//    UIButton *send  = [[UIButton alloc] initWithFrame:rect];
//    [send setImage:[MQAssetUtil imageFromBundleWithName:@"emoji"] forState:(UIControlStateNormal)];
//    [send addTarget:self action:@selector(send) forControlEvents:(UIControlEventTouchUpInside)];

    if ([MQChatViewConfig sharedConfig].enableSendVoiceMessage) {
        [self.bottomBar.buttonGroupBar addButton:recorderBtn];
    }
    
    if ([MQChatViewConfig sharedConfig].enableSendImageMessage) {
        [self.bottomBar.buttonGroupBar addButton:cameraBtn];
        [self.bottomBar.buttonGroupBar addButton:imageRoll];
    }
    
    if ([MQChatViewConfig sharedConfig].enableSendEmoji) {
        [self.bottomBar.buttonGroupBar addButton:emoji];
    }
    
//            [self.bottomBar.buttonGroupBar addButton:send];

}

- (BOOL)handleSendMessageAbility {
    
    //xlp 检测网络 排除断网状态还能发送信息
    if (![MQManager obtainNetIsReachable] || isMQSocketFailed) {
        [[(MQTabInputContentView *)self.bottomBar.contentView textField] resignFirstResponder];
        [MQToast showToast:[MQBundleUtil localizedStringForKey:@"meiqia_communication_failed"] duration:2.0 window:self.view];
        return NO;
    }
        
    
    //xlp 旧的: waitingInQueuePosition>0 && getCurrentAgent].privilege != MQAgentPrivilegeBot  改为 waitingInQueuePosition>0
    if ([MQServiceToViewInterface waitingInQueuePosition] > 0 && [MQServiceToViewInterface getCurrentAgent].privilege != MQAgentPrivilegeBot) {
        [self.view.window endEditing:YES];
        [MQToast showToast:@"正在排队，请等待客服接入后发送消息" duration:2.5 window:self.view.window];
        
        [MQServiceToViewInterface getClientQueuePositionComplete:^(NSInteger position, NSError *error) {
            //从后台获取 position 然后保存到本地
        }];
        return NO;
    }
    
    // 判断当前顾客是否正在登陆，如果正在登陆，显示禁止发送的提示
    if (self.chatViewService.clientStatus == MQStateAllocatingAgent) {
        NSString *alertText = @"cannot_text_client_is_onlining";
        [MQToast showToast:[MQBundleUtil localizedStringForKey:alertText] duration:2 window:[[UIApplication sharedApplication].windows lastObject]];
        
        return NO;
    }
    return YES;
}

- (void)showRecorder {
    if ([self handleSendMessageAbility]) {
        if (self.bottomBar.isFirstResponder) {
            [self.bottomBar resignFirstResponder];
        }else{
            self.bottomBar.inputView = self.displayRecordView;
            [self.bottomBar becomeFirstResponder];
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
        if (self.bottomBar.isFirstResponder) {
            [self.bottomBar resignFirstResponder];
        }else{
            
            CGFloat emojiViewHeight = MQToolUtil.kMQObtainDeviceVersionIsIphoneX ? (emojikeyboardHeight + 34) : emojikeyboardHeight;
            
            MEIQIA_InputView * mmView = [[MEIQIA_InputView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, emojiViewHeight)];
            mmView.inputViewDelegate = self;
            self.bottomBar.inputView = mmView;
            
            [self.bottomBar becomeFirstResponder];
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
    
    //xlp 检测网络 排除断网状态还能发送信息
    if (![MQManager obtainNetIsReachable] || isMQSocketFailed) {
        [MQToast showToast:[MQBundleUtil localizedStringForKey:@"meiqia_communication_failed"] duration:2.0 window:self.view];
        return NO;
    }
    return YES;
}

#pragma mark - inputbar delegate

- (void)inputBar:(MQBottomBar *)inputBar willChangeHeight:(CGFloat)height {
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
    
    self.keyboardView.keyboardTriggerPoint = CGPointMake(0, height);
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)changeInputBarBottomLayoutGuideConstant:(CGFloat)height {
    //xlp 收回键盘 时 减去 34 todo
    if (MQToolUtil.kMQObtainDeviceVersionIsIphoneX ) {
        if (height == 0) {
            height = 34;
            
        } else if(height == emojikeyboardHeight) {
            // 点击表情 弹出表情键盘时
            height += 34;
        }
    }
    
    self.constraintInputBarBottom.constant = height;
    
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

#pragma mark - keyboard controller delegate
- (void)keyboardController:(MQKeyboardController *)keyboardController keyboardChangeFrame:(CGRect)keyboardFrame isImpressionOfGesture:(BOOL)isImpressionOfGesture {
    
    CGFloat viewHeight = self.navigationController.navigationBar.translucent ? CGRectGetMaxY(self.view.frame) : CGRectGetMaxY(self.view.frame) - MQToolUtil.kMQObtainNaviHeight;
    
    CGFloat heightFromBottom = MAX(0.0, viewHeight - CGRectGetMinY(keyboardFrame));
    
    if (!isImpressionOfGesture) {
        
        if (MQToolUtil.kMQObtainDeviceVersionIsIphoneX ) {
            
            CGFloat diff = heightFromBottom - self.constraintInputBarBottom.constant + (heightFromBottom == 0 ? 34 : 0);
            if (diff < self.chatTableView.contentInset.top + self.chatTableView.contentSize.height) {
                self.chatTableView.contentOffset = CGPointMake(self.chatTableView.contentOffset.x, self.chatTableView.contentOffset.y + diff);
            }
            
        }else{
            
            CGFloat diff = heightFromBottom - self.constraintInputBarBottom.constant;
            if (diff < self.chatTableView.contentInset.top + self.chatTableView.contentSize.height) {
                self.chatTableView.contentOffset = CGPointMake(self.chatTableView.contentOffset.x, self.chatTableView.contentOffset.y + diff);
            }
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

- (void)MQInputViewObtainEmojiStr:(NSString *)emojiStr{
    MEIQIA_HPGrowingTextView *textField = [(MQTabInputContentView *)self.bottomBar.contentView textField];
    textField.text = [textField.text stringByAppendingString:emojiStr];
}
- (void)MQInputViewDeleteEmoji{
    MEIQIA_HPGrowingTextView *textField = [(MQTabInputContentView *)self.bottomBar.contentView textField];
    if (textField.text.length > 0) {
        NSRange lastRange = [textField.text rangeOfComposedCharacterSequenceAtIndex:([textField.text length] - 1)];
        textField.text = [textField.text stringByReplacingCharactersInRange:lastRange withString:@""];
    }
}
- (void)MQInputViewSendEmoji{
    MEIQIA_HPGrowingTextView *textField = [(MQTabInputContentView *)self.bottomBar.contentView textField];
    if (textField.text.length > 0) {
        
        [self sendTextMessage:textField.text];
        [(MQTabInputContentView *)self.bottomBar.contentView textField].text = @"";
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

- (MQBottomBar *)bottomBar {
    if (!_bottomBar) {
        MQTabInputContentView *contentView = [[MQTabInputContentView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, emojikeyboardHeight )];
        
        _bottomBar = [[MQBottomBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kMQChatViewInputBarHeight) contentView: contentView];
        _bottomBar.delegate = self;
        _bottomBar.contentViewDelegate = self;
        [contentView setupButtons];
        
    }
    return _bottomBar;
}

- (MQKeyboardController *)keyboardView {
    if (!_keyboardView) {
        _keyboardView = [[MQKeyboardController alloc] initWithResponders:@[self.bottomBar.contentView, self.bottomBar] contextView:self.view panGestureRecognizer:self.chatTableView.panGestureRecognizer delegate:self];
        _keyboardView.keyboardTriggerPoint = CGPointMake(0, self.constaintInputBarHeight.constant);
    }
    return _keyboardView;
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
                                                                     /*viewSize.height*/[UIScreen mainScreen].bounds.size.height - self.bottomBar.frame.size.height)
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
        self->translucentView.alpha = 0.5;
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


#pragma mark - network status view

/**
 显示网络链接错误的提示
 */
- (void)showNetworkStatusViewWithText:(NSString *)content {
    if (!networkStatusLable) {
        networkStatusLable = [[UILabel alloc] initWithFrame:CGRectZero];
        networkStatusLable.textAlignment = NSTextAlignmentCenter;
        networkStatusLable.backgroundColor = [UIColor redColor];
        [self.view addSubview:networkStatusLable];
        [self.view bringSubviewToFront:networkStatusLable];
        networkStatusLable.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:@[
        [NSLayoutConstraint constraintWithItem:networkStatusLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:[MQChatDeviceUtil getDeviceNavRect:self].size.height + [MQChatDeviceUtil getDeviceStatusBarRect].size.height],
        [NSLayoutConstraint constraintWithItem:networkStatusLable attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:networkStatusLable attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:networkStatusLable attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30],
        ]];
    }
    
    UIImage *iconImage = [content isEqualToString:[MQBundleUtil localizedStringForKey:@"network_connect_error"]] ? [MQAssetUtil networkStatusError] : [MQAssetUtil networkStatusWarning];
    UIColor *statusBackgroundColor = [content isEqualToString:[MQBundleUtil localizedStringForKey:@"network_connect_error"]] ? [UIColor mq_colorWithHexString:@"#FFECEA"] : [UIColor mq_colorWithHexString:@"#FFF5E6"];
    
    NSMutableAttributedString * mutableAttr = [[NSMutableAttributedString alloc] init];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = iconImage;
    attachment.bounds = CGRectMake(0, -2, 15, 15);
    [mutableAttr appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    
    [mutableAttr appendAttributedString:[
                                         [NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",content] attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:14.0],
                                                                                                                        NSForegroundColorAttributeName : [UIColor grayColor],}]];
    
    networkStatusLable.attributedText = mutableAttr;
    networkStatusLable.hidden = NO;
    networkStatusLable.backgroundColor = statusBackgroundColor;
}

/**
 隐藏网络链接错误的提示
 */
- (void)dismissNetworkStatusView {
    if (networkStatusLable) {
        networkStatusLable.hidden = YES;
    }
}

@end
