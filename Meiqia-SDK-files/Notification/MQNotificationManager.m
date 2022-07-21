//
//  MQNotificationManager.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/5/30.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import "MQNotificationManager.h"
#import "MQToolUtil.h"
#import "MQNotificationView.h"
#import "MQServiceToViewInterface.h"
#import "MQChatViewManager.h"
#import "MQChatViewController.h"

#define kMQNotificationWindowContentHeight [MQToolUtil kMQObtainStatusBarHeight] + 100
static NSInteger const kMQNotificationDismissTime = 5.0;

@interface MQNotificationManager ()<MQGroupNotificationDelegate>

@property (strong, nonatomic) UIWindow *notificationWindow;

@property (strong, nonatomic) MQNotificationView *notificationView;

@property (nonatomic, strong) dispatch_source_t countdownTimer;

@property (nonatomic, assign) BOOL currentLongGesture;

@property (nonatomic, strong) MQGroupNotification *currentNotification;

@end

@implementation MQNotificationManager

+ (MQNotificationManager *)sharedManager {
    static dispatch_once_t once;
    static MQNotificationManager * instance = nil;
    dispatch_once(&once, ^{
        instance = [super new];
    });
    return instance;
}

- (void)openMQGroupNotificationServer {
    [MQServiceToViewInterface openMQGroupNotificationServiceWithDelegate:self];
}

- (void)showNotification {
    if (!self.notificationWindow) {
        [self createNotificationWindow];
        [self.notificationWindow addSubview:self.notificationView];
        
        UISwipeGestureRecognizer *topSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [topSwipe setDirection:(UISwipeGestureRecognizerDirectionUp)];
        [self.notificationWindow addGestureRecognizer:topSwipe];
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self.notificationWindow addGestureRecognizer:longGesture];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self.notificationWindow addGestureRecognizer:tap];
        
        [self.notificationWindow makeKeyAndVisible];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.notificationWindow.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kMQNotificationWindowContentHeight);
        } completion:^(BOOL finished) {
            [self resetCountdown:kMQNotificationDismissTime];
        }];
    } else {
        if (!self.currentLongGesture) {
            [self resetCountdown:kMQNotificationDismissTime];
        }
    }
}

- (void)dismissNotification {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.notificationWindow.frame = CGRectMake(0, -(kMQNotificationWindowContentHeight), [UIScreen mainScreen].bounds.size.width, kMQNotificationWindowContentHeight);
    } completion:^(BOOL finished) {
        self.notificationWindow = nil;
    }];
}

- (void)createNotificationWindow {
    CGRect bounds = CGRectMake(0, -(kMQNotificationWindowContentHeight), [UIScreen mainScreen].bounds.size.width, kMQNotificationWindowContentHeight);
    self.notificationWindow = [[UIWindow alloc] initWithFrame:bounds];
    self.notificationWindow.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    self.notificationWindow.windowLevel = 4000;
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.currentLongGesture = YES;
        [self cancelCountdownTimer];
    } else {
        self.currentLongGesture = NO;
        [self resetCountdown:kMQNotificationDismissTime];
    }
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    [self cancelCountdownTimer];
    [self dismissNotification];
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    [[NSNotificationCenter defaultCenter] postNotificationName:MQ_CLICK_GROUP_NOTIFICATION object:nil userInfo:[self.currentNotification fromMapping]];
    [self cancelCountdownTimer];
    [self dismissNotification];
    if (!self.handleNotification) {
        [MQServiceToViewInterface insertMQGroupNotificationToConversion:self.currentNotification];
        self.currentNotification = nil;
        UIViewController *vc = [self findCurrentShowingViewController];
        if (![vc isKindOfClass:[MQChatViewController class]]) {
            MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
            [chatViewManager pushMQChatViewControllerInViewController:vc];
        }
    }
}

- (MQNotificationView *)notificationView {
    if (!_notificationView) {
        _notificationView = [[MQNotificationView alloc] initWithFrame:CGRectMake(kMQNotificationViewMargin, [MQToolUtil kMQObtainStatusBarHeight], [MQToolUtil kMQScreenWidth] - kMQNotificationViewMargin * 2, kMQNotificationViewHeight)];
    }
    return _notificationView;
}

- (void)countDownWithTimer:(dispatch_source_t)timer timeInterval:(NSTimeInterval)timeInterval complete:(void(^)(void))completeBlock {
    __block int timeout = timeInterval;
    if (timeout != 0) {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), (int64_t)(1.0 * NSEC_PER_SEC), 0);
        dispatch_source_set_event_handler(timer, ^{
            if(timeout <= 0){ //倒计时结束，关闭
                dispatch_source_cancel(timer);
                dispatch_async(dispatch_get_main_queue(), ^{ // block 回调
                    if (completeBlock) {
                        completeBlock();
                    }
                });
            }else{
                timeout--;
            }
        });
        dispatch_resume(timer);
    }
}

- (void)resetCountdown:(NSInteger)time {
    [self cancelCountdownTimer];
    NSInteger count = time;
    // 创建一个队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.countdownTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    __weak typeof(self) weakSelf = self;
    [self countDownWithTimer:self.countdownTimer timeInterval:count complete:^{
        [weakSelf dismissNotification];
    }];
}

- (void)cancelCountdownTimer {
    if (_countdownTimer) {
        dispatch_source_cancel(_countdownTimer);
        _countdownTimer = nil;
    }
}

- (UIViewController *)findCurrentShowingViewController {
    
    UIWindow* window = nil;
    
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
        {
            if (windowScene.activationState == UISceneActivationStateForegroundActive)
            {
                window = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
        window = [UIApplication sharedApplication].keyWindow;
    }
    UIViewController *vc = window.rootViewController;

    return [self findCurrentShowingViewControllerFrom:vc];
}

- (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{
    // 递归方法 Recursive method
    UIViewController *currentShowingVC;
    if ([vc presentedViewController]) {
        // 当前视图是被presented出来的
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else {
        // 根视图为非导航类
        currentShowingVC = vc;
    }

    return currentShowingVC;
}

#pragma mark MQGroupNotificationDelegate

-(void)didReceiveMQGroupNotification:(NSArray<MQGroupNotification *> *)message {
    if (message.count > 0) {
        MQGroupNotification *notification = [message lastObject];
        self.currentNotification = notification;
        [self.notificationView configViewWithSenderName:notification.name senderAvatarUrl:notification.avatar sendContent:notification.content];
        [self showNotification];
    }
}

@end
