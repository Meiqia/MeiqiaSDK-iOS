//
//  MQChatViewManager.h
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/27.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQChatViewController.h"
#import "MQChatViewConfig.h"
#import <MeiQiaSDK/MQDefinition.h>
#import "MQCustomizedUIText.h"

#define style_deprecated __attribute__((deprecated("修改 MQChatViewStyleType 中的对应属性代替")))

/**
 * @brief 客服聊天界面的配置类
 *
 * 开发者可以通过MQChatViewManager中提供的接口，来对客服聊天界面进行自定义配置；
 */
@interface MQChatViewManager : NSObject

///chatViewStyle 预设的聊天界面样式
@property (nonatomic, strong) MQChatViewStyle *chatViewStyle;

///如果应用中有其他地方正在播放声音，比如游戏，需要将此设置为 YES，防止其他声音在录音播放完之后无法继续播放
@property (nonatomic, assign) BOOL keepAudioSessionActive;

/**
 typedef NS_ENUM(NSUInteger, MQRecordMode) {
 MQRecordModePauseOther = 0, //暂停其他音频
 MQRecordModeMixWithOther = AVAudioSessionCategoryOptionMixWithOthers, //和其他音频同时播放
 MQRecordModeDuckOther = AVAudioSessionCategoryOptionDuckOthers //降低其他音频的声音
 };
*/
@property (nonatomic, assign) MQRecordMode recordMode;

/**
 typedef NS_ENUM(NSUInteger, MQPlayMode) {
 MQPlayModePauseOther = 0, //暂停其他音频
 MQPlayModeMixWithOther = AVAudioSessionCategoryOptionMixWithOthers, //和其他音频同时播放
 MQPlayModeDuckOther = AVAudioSessionCategoryOptionDuckOthers //降低其他音频的声音
 };
*/
@property (nonatomic, assign) MQPlayMode playMode;

/**
 设置显示聊天界面的时候，自动发送给客服的消息, 可以包括图片和文字
 */
@property (nonatomic, strong) NSArray *preSendMessages;

/**
 * 在一个ViewController中Push出一个客服聊天界面
 * @param viewController 在这个viewController中push出客服聊天界面
 */
- (MQChatViewController *)pushMQChatViewControllerInViewController:(UIViewController *)viewController;

/**
 * 在一个ViewController中Present出一个客服聊天界面的Modal视图
 * @param viewController 在这个viewController中push出客服聊天界面
 */
- (MQChatViewController *)presentMQChatViewControllerInViewController:(UIViewController *)viewController;

/**
 * 将客服聊天界面移除
 */
- (void)disappearMQChatViewController;

/**
 *  push视图时，隐藏底部TabBar
 *
 *  @param hide 默认为YES
 */
- (void)hidesBottomBarWhenPushed:(BOOL)hide;

/**
 *  设置是否开启自定义聊天界面的坐标，默认不自定义
 *
 *  @param enable YES 自定义 NO 不自定义
 */
//- (void)enableCustomChatViewFrame:(BOOL)enable;

/**
 * 是否显示导航栏右键'评价'按钮，默认显示；
 * @param enable YES:显示'评价'按钮 NO:隐藏'评价'按钮
 */
- (void)enableEvaluationButton:(BOOL)enable;

/**
 * 设置客服聊天界面的坐标。
 * @warning 默认聊天界面全屏显示。
 * @param viewFrame 客服聊天tableView的界面的坐标
 */
- (void)setChatViewFrame:(CGRect)viewFrame;

/**
 *  设置客服聊天 viewController 的起始坐标点
 *
 *  @param viewPoint 其实坐标点
 *  @warning 默认聊天界面从(0,0)开始，全屏显示。默认支持系统的 navigationController。如果开发者自定义导航栏，可调用此接口调整起始坐标。
 */
- (void)setViewControllerPoint:(CGPoint)viewPoint;

/**
 * 增加消息中可选中的数字的正则表达式，用于匹配消息，满足条件段落可以被用户点击。
 * @param numberRegex 数字的正则表达式
 */
- (void)setMessageNumberRegex:(NSString *)numberRegex;

/**
 * 增加消息中可选中的链接的正则表达式，用于匹配消息，满足条件段落可以被用户点击。
 * @param numberRegex 链接的正则表达式
 */
- (void)setMessageLinkRegex:(NSString *)linkRegex;

/**
 * 增加消息中可选中的email的正则表达式，用于匹配消息，满足条件段落可以被用户点击。
 * @param emailRegex email的正则表达式
 */
- (void)setMessageEmailRegex:(NSString *)emailRegex;

/**
 * 设置顾客第一次进入界面显示的欢迎文字；
 * @param tipText 提示文字
 */
- (void)setChatWelcomeText:(NSString *)welcomText;

/**
 *  设置客服的名字
 *
 *  @param agentName 客服名字
 */
- (void)setAgentName:(NSString *)agentName;

/**
 * 设置收到消息的声音；
 * @param soundFileName 声音文件；如果要自定义声音，请将声音文件放在 MQChatViewAsset.bundle 中
 * @warning 若文件名设置为空，则代表不播放声音
 */

- (void)setIncomingMessageSoundFileName:(NSString *)soundFileName;

/**
 * 设置发送的声音；
 * @param soundFileName 声音文件；如果要自定义声音，请将声音文件放在 MQChatViewAsset.bundle 中
 * @warning 若文件名设置为空，则代表不播放声音
 */
- (void)setOutgoingMessageSoundFileName:(NSString *)soundFileName;

/**
 * 是否支持发送语音消息；默认支持
 * @param enable YES:支持发送语音消息 NO:不支持发送语音消息
 */
- (void)enableSendVoiceMessage:(BOOL)enable;

/**
 * 是否支持发送图片消息；默认支持
 * @param enable YES:支持发送图片消息 NO:不支持发送图片消息
 */
- (void)enableSendImageMessage:(BOOL)enable;


/**
 * 是否支持表情键盘
 * @param
 */
- (void)enableSendEmoji:(BOOL)enable;

/**
 *  客服聊天界面打开时，收到新消息，是否显示收到新消息提示；默认支持
 *
 * @param enable YES:支持 NO:不支持
 */
- (void)enableShowNewMessageAlert:(BOOL)enable;

/**
 * 是否支持对方头像的显示；默认支持
 * @param enable YES:支持 NO:不支持
 */
- (void)enableIncomingAvatar:(BOOL)enable style_deprecated;

/**
 *  是否支持当前用户头像的显示；默认不支持
 *
 * @param enable YES:支持 NO:不支持
 */
- (void)enableOutgoingAvatar:(BOOL)enable style_deprecated;

/**
 * 是否开启接受/发送消息的声音；默认开启
 * @param enable YES:开启声音 NO:关闭声音
 */
- (void)enableMessageSound:(BOOL)enable;

/**
 *  是否开启下拉刷新（顶部刷新）；默认开启
 *
 * @warning 如果开发者要禁用下拉刷新，则需要将enableTopPullRefresh和enableTopAutoRefresh都置为false
 * @param enable YES:支持 NO:不支持
 */
- (void)enableTopPullRefresh:(BOOL)enable;

/**
 *  是否开启上拉刷新（底部刷新）；默认关闭
 *
 * @param enable YES:支持 NO:不支持
 */
- (void)enableBottomPullRefresh:(BOOL)enable;

/**
 *  是否开启顶部自动刷新历史消息；默认开启
 *
 * @warning 如果开发者要禁用下拉刷新，则需要将enableTopPullRefresh和enableTopAutoRefresh都置为false
 * @param enable YES:支持 NO:不支持
 */
- (void)enableTopAutoRefresh:(BOOL)enable;

/**
 *  是否开启圆形头像；默认不支持
 *
 * @param enable YES:支持 NO:不支持
 */
- (void)enableRoundAvatar:(BOOL)enable style_deprecated;

/**
 *  是否支持欢迎语；默认不支持
 *
 * @param enable YES:支持 NO:不支持
 */
- (void)enableChatWelcome:(BOOL)enable;

/**
 *  是否显示录音时的背景模糊效果；默认不显示
 *
 *  @param enable YES:显示 NO:不显示
 */
- (void)enableVoiceRecordBlurView:(BOOL)enable;

/**
 * 设置发送过来的message的文字颜色；
 * @param textColor 文字颜色
 */
- (void)setIncomingMessageTextColor:(UIColor *)textColor style_deprecated;

/**
 *  设置发送过来的message气泡颜色
 *
 *  @param bubbleColor 气泡颜色
 */
- (void)setIncomingBubbleColor:(UIColor *)bubbleColor style_deprecated;

/**
 * 设置发送出去的message的文字颜色；
 * @param textColor 文字颜色
 */
- (void)setOutgoingMessageTextColor:(UIColor *)textColor style_deprecated;

/**
 *  设置发送的message气泡颜色
 *
 *  @param bubbleColor 气泡颜色
 */
- (void)setOutgoingBubbleColor:(UIColor *)bubbleColor style_deprecated;

/**
 * 开启图片消息的无边框遮罩效果。无边框遮罩效果更加美观，但是更消耗资源，存在图片的聊天界面下，转屏会出现卡顿，所以可能不适用没有锁定转屏的app
 * 默认开启
 * @param enable YES:开启 NO:关闭
 */
- (void)enableMessageImageMask:(BOOL)enable;

/**
 * 设置导航栏上的元素颜色；
 * @param tintColor 导航栏上的元素颜色
 */
- (void)setNavigationBarTintColor:(UIColor *)tintColor style_deprecated;

/**
 * 设置导航栏标题颜色；
 * @param tintColor 导航栏标题颜色
 */
- (void)setNavigationBarTitleColor:(UIColor *)tintColor style_deprecated;

/**
 * 设置导航栏的背景色；
 * @param barColor 导航栏背景颜色
 */
- (void)setNavigationBarColor:(UIColor *)barColor style_deprecated;

/**
 *  设置导航栏右键的图片
 *
 *  @param rightButtonImage 右键图片
 */
- (void)setNavRightButton:(UIButton *)rightButton style_deprecated;

/**
 *  设置导航栏左键的图片
 *
 *  @param leftButton 左键图片
 */
- (void)setNavLeftButton:(UIButton *)leftButton __attribute__((deprecated("使用 chatViewStyle.navBackButtonImage 代替")));

/**
 *  设置导航栏标题
 *
 *  @param titleText 标题文字
 */
- (void)setNavTitleText:(NSString *)titleText;

/**
 *  设置下拉/上拉刷新的颜色；默认绿色
 *
 *  @param pullRefreshColor 颜色
 */
- (void)setPullRefreshColor:(UIColor *)pullRefreshColor style_deprecated;

/**
 * 设置客服的缺省头像图片；
 * @param image 头像image
 */
- (void)setincomingDefaultAvatarImage:(UIImage *)image style_deprecated;

/**
 * 设置顾客的头像图片；
 * @param image 头像image
 */
- (void)setoutgoingDefaultAvatarImage:(UIImage *)image;

/**
 *  设置底部自定义发送图片的按钮图片；
 *  @param image 图片发送按钮image
 *  @param highlightedImage 图片发送按钮选中image
 */
- (void)setPhotoSenderImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage style_deprecated;

/**
 *  设置底部自定义发送语音的按钮图片；
 *  @param image 语音发送按钮image
 *  @param highlightedImage 语音发送按钮选中image
 */
- (void)setVoiceSenderImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage style_deprecated;

/**
 *  设置底部自定义发送文字的按钮图片
 *
 *  @param image            文字发送按钮image
 *  @param highlightedImage 文字发送按钮选中image
 */
- (void)setTextSenderImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage style_deprecated;

/**
 *  设置底部自定义取消键盘的按钮图片
 *
 *  @param image            取消键盘按钮image
 *  @param highlightedImage 取消键盘按钮选中image
 */
- (void)setResignKeyboardImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage style_deprecated;

/**
 * 设置自定义客服的消息气泡（发送过来的消息气泡）的背景图片；
 * @param bubbleImage 气泡图片
 */
- (void)setIncomingBubbleImage:(UIImage *)bubbleImage style_deprecated;

/**
 * 设置自定义顾客的消息气泡（发送出去的消息气泡）的背景图片；
 * @param bubbleImage 气泡图片
 */
- (void)setOutgoingBubbleImage:(UIImage *)bubbleImage style_deprecated;

/**
 *  设置消息气泡的拉伸insets
 *
 *  @param stretchInsets 拉伸insets
 */
- (void)setBubbleImageStretchInsets:(UIEdgeInsets)stretchInsets style_deprecated;

/**
 *  设置录音的最大时长；默认60秒；
 *
 *  @param recordDuration 时长
 */
- (void)setMaxRecordDuration:(NSTimeInterval)recordDuration;

/**
 *  设置导航栏时间条的颜色
 */
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle style_deprecated;

#pragma 以下配置是美洽SDK用户所用到的配置
#ifdef INCLUDE_MEIQIA_SDK
/**
 * 显示的历史聊天消息是否去主动同步服务端的消息记录。因为有可能顾客在其他客户端产生了消息记录，如果设置为NO，则SDK本地消息会与服务端实际的历史消息不相符；默认NO
 * @warning 如果开启同步，将会产生一定网络请求。所以建议顾客端只使用美洽SDK的用户保持默认值
 * @warning 如果开启同步，下拉获取历史消息则会从服务端去获取；如果关闭同步，下拉获取历史消息则是从SDK本地数据库中获取；
 * @param enable YES:同步 NO:不同步
 */
- (void)enableSyncServerMessage:(BOOL)enable;

/**
 *  设置分配给指定的客服id
 *
 *  @param agentId 客服id
 */
- (void)setScheduledAgentId:(NSString *)agentId;

/**
 *  设置分配给指定的客服组id
 *
 *  @warning 如果设置了分配给客服id，以分配给客服id为优先
 *  @param groupId 客服组id
 */
- (void)setScheduledGroupId:(NSString *)groupId;

/**
 *  设置不分配给指定的客服id
 *
 *  @param agentId 客服id
 */
- (void)setNotScheduledAgentId:(NSString *)agentId;

/**
 *  指定分配客服/客服组，该客服/客服组不在线，如何转接的接口
 *
 *  @param scheduleRule 转接规则
 *  @warning 默认转接给企业随机一个客服
 */
- (void)setScheduleLogicWithRule:(MQChatScheduleRules)scheduleRule;

/**
 *  设置登录客服的开发者自定义id，设置该id后，聊天将会以该自定义id的顾客上线
 *
 *  @warning 如果setLoginMQClientId接口，优先使用setLoginMQClientId来进行登录
 *  @param customizedId 开发者自定义id
 */
- (void)setLoginCustomizedId:(NSString *)customizedId;

/**
 *  设置登录客服的顾客的id，设置该id后，聊天将会以该顾客id的顾客上线
 *
 *  @warning 如果调用了setLoginCustomizedId接口，优先使用此接口来进行登录
 *  @param MQClientId 顾客id
 */
- (void)setLoginMQClientId:(NSString *)MQClientId;

/**
 * 是否显示事件状态流；事件的状态流有：初始化对话、对话被转接给其他客服、对话超时、客服主动结束了对话、客服正在输入；默认不支持；
 * @param enable YES:开启事件状态流 NO:关闭事件状态流
 */
- (void)enableEventDispaly:(BOOL)enable;

/**
 * 设置事件流的显示文字的颜色；
 * @param textColor 文字颜色
 */
- (void)setEventTextColor:(UIColor *)textColor;

/**
 *  设置顾客的自定义信息
 *
 *  @param clientInfo 顾客的自定义信息
    @param override 是否强制更新，如果不设置此值为 YES，设置只有第一次有效。
 */
- (void)setClientInfo:(NSDictionary *)clientInfo override:(BOOL)override;

/**
 *  设置顾客的自定义信息
 *
 *  @param clientInfo 顾客的自定义信息，这个信息只有第一次调用的时候起作用。
 */
- (void)setClientInfo:(NSDictionary *)clientInfo;

#endif


@end
