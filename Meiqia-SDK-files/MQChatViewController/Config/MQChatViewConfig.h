//
//  MQChatViewConfig.h
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MQChatViewStyle.h"
#import "MQChatAudioTypes.h"

//是否引入美洽SDK
#define INCLUDE_MEIQIA_SDK

/** 关闭键盘的通知 */
extern NSString * const MQChatViewKeyboardResignFirstResponderNotification;
/** 中断audio player的通知 */
extern NSString * const MQAudioPlayerDidInterruptNotification;
/** 刷新TableView的通知 */
extern NSString * const MQChatTableViewShouldRefresh;

/**
 指定分配客服，该客服不在线后转接的逻辑
 */
typedef enum : NSUInteger {
    MQChatScheduleRulesRedirectNone         = 1,            //不转接给任何人
    MQChatScheduleRulesRedirectGroup        = 2,            //转接给组内的人
    MQChatScheduleRulesRedirectEnterprise   = 3             //转接给企业其他随机一个人
} MQChatScheduleRules;

/**
 客服的状态
 */
typedef enum : NSUInteger {
    MQChatAgentStatusOnDuty         = 1,            //客服在线
    MQChatAgentStatusOffDuty        = 2,            //客服隐身
    MQChatAgentStatusOffLine        = 3             //客服离线
} MQChatAgentStatus;

/*
 显示聊天窗口的动画
 */
typedef NS_ENUM(NSUInteger, MQTransiteAnimationType) {
    MQTransiteAnimationTypeDefault = 0,
    MQTransiteAnimationTypePush
};

/**
 * @brief MQChatViewConfig为客服聊天界面的前置配置，由MQChatViewManager生成，在MQChatViewController内部逻辑消费
 *
 */
@interface MQChatViewConfig : NSObject

@property (nonatomic, strong) MQChatViewStyle *chatViewStyle;

@property (nonatomic, assign) BOOL hidesBottomBarWhenPushed;
//@property (nonatomic, assign) BOOL isCustomizedChatViewFrame;
@property (nonatomic, assign) CGRect chatViewFrame;
@property (nonatomic, assign) CGPoint chatViewControllerPoint;
@property (nonatomic, strong) NSMutableArray *numberRegexs;
@property (nonatomic, strong) NSMutableArray *linkRegexs;
@property (nonatomic, strong) NSMutableArray *emailRegexs;
@property (nonatomic, assign) MQTransiteAnimationType presentingAnimation;

@property (nonatomic, copy  ) NSString *chatWelcomeText;
@property (nonatomic, copy  ) NSString *agentName;
@property (nonatomic, copy  ) NSString *incomingMsgSoundFileName;
@property (nonatomic, copy  ) NSString *outgoingMsgSoundFileName;
@property (nonatomic, copy  ) NSString *scheduledAgentId;
@property (nonatomic, copy  ) NSString *notScheduledAgentId;
@property (nonatomic, copy  ) NSString *scheduledGroupId;
@property (nonatomic, copy  ) NSString *customizedId;
@property (nonatomic, copy  ) NSString *navTitleText;

@property (nonatomic, assign) BOOL enableEventDispaly;
@property (nonatomic, assign) BOOL enableSendVoiceMessage;
@property (nonatomic, assign) BOOL enableSendImageMessage;
@property (nonatomic, assign) BOOL enableSendEmoji;
@property (nonatomic, assign) BOOL enableMessageImageMask;
@property (nonatomic, assign) BOOL enableMessageSound;
@property (nonatomic, assign) BOOL enableTopPullRefresh;
@property (nonatomic, assign) BOOL enableBottomPullRefresh;
@property (nonatomic, assign) BOOL enableChatWelcome;
@property (nonatomic, assign) BOOL enableTopAutoRefresh;
@property (nonatomic, assign) BOOL enableShowNewMessageAlert;
@property (nonatomic, assign) BOOL isPushChatView;
@property (nonatomic, assign) BOOL enableEvaluationButton;
@property (nonatomic, assign) BOOL enableVoiceRecordBlurView;
@property (nonatomic, assign) BOOL updateClientInfoUseOverride;

@property (nonatomic, strong) UIImage *incomingDefaultAvatarImage;
@property (nonatomic, strong) UIImage *outgoingDefaultAvatarImage;
@property (nonatomic, assign) BOOL shouldUploadOutgoingAvartar;


@property (nonatomic, assign) NSTimeInterval maxVoiceDuration;

///如果应用中有其他地方正在播放声音，比如游戏，需要将此设置为 YES，防止其他声音在录音或者播放完之后无法继续播放
@property (nonatomic, assign) BOOL keepAudioSessionActive;
@property (nonatomic, assign) MQRecordMode recordMode;
@property (nonatomic, assign) MQPlayMode playMode;

@property (nonatomic, strong) NSArray *preSendMessages;


#pragma 以下配置是美洽SDK用户所用到的配置
#ifdef INCLUDE_MEIQIA_SDK
@property (nonatomic, assign) BOOL enableSyncServerMessage;
@property (nonatomic, copy  ) NSString *MQClientId;


@property (nonatomic, strong) NSDictionary *clientInfo;
@property (nonatomic, assign) MQChatScheduleRules scheduleRule;


#endif

+ (instancetype)sharedConfig;

/** 将配置设置为默认值 */
- (void)setConfigToDefault;

@end


///以下内容为向下兼容之前的版本
@interface MQChatViewConfig(deprecated)

@property (nonatomic, assign) BOOL enableRoundAvatar;
@property (nonatomic, assign) BOOL enableIncomingAvatar;
@property (nonatomic, assign) BOOL enableOutgoingAvatar;

@property (nonatomic, copy) UIColor *incomingMsgTextColor;
@property (nonatomic, copy) UIColor *incomingBubbleColor;
@property (nonatomic, copy) UIColor *outgoingMsgTextColor;
@property (nonatomic, copy) UIColor *outgoingBubbleColor;
@property (nonatomic, copy) UIColor *eventTextColor;
@property (nonatomic, copy) UIColor *redirectAgentNameColor;
@property (nonatomic, copy) UIColor *navTitleColor;

@property (nonatomic, copy) UIColor *navBarTintColor;
@property (nonatomic, copy) UIColor *navBarColor;
@property (nonatomic, copy) UIColor *pullRefreshColor;

@property (nonatomic, strong) UIImage *incomingDefaultAvatarImage;
@property (nonatomic, strong) UIImage *outgoingDefaultAvatarImage;
@property (nonatomic, strong) UIImage *messageSendFailureImage;
@property (nonatomic, strong) UIImage *photoSenderImage;
@property (nonatomic, strong) UIImage *photoSenderHighlightedImage;
@property (nonatomic, strong) UIImage *voiceSenderImage;
@property (nonatomic, strong) UIImage *voiceSenderHighlightedImage;
@property (nonatomic, strong) UIImage *keyboardSenderImage;
@property (nonatomic, strong) UIImage *keyboardSenderHighlightedImage;
@property (nonatomic, strong) UIImage *resignKeyboardImage;
@property (nonatomic, strong) UIImage *resignKeyboardHighlightedImage;
@property (nonatomic, strong) UIImage *incomingBubbleImage;
@property (nonatomic, strong) UIImage *outgoingBubbleImage;
@property (nonatomic, strong) UIImage *imageLoadErrorImage;

@property (nonatomic, assign) UIEdgeInsets bubbleImageStretchInsets;

@property (nonatomic, strong) UIButton *navBarLeftButton;
@property (nonatomic, strong) UIButton *navBarRightButton;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign) BOOL didSetStatusBarStyle;


@end

