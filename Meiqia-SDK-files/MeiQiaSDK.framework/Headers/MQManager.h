//
//  MQManager.h
//  MeiQiaSDK
//
//  Created by dingnan on 15/10/27.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MQMessage.h"
#import "MQDefinition.h"
#import "MQAgent.h"
#import "MQEnterprise.h"
#import "MQPreChatData.h"


#define MQSDKVersion @"3.3.4"

@protocol MQManagerDelegate <NSObject>

/**
 *  收到了消息
 *  @param message 消息
 */
- (void)didReceiveMQMessages:(NSArray<MQMessage *> *)message;

@end

/**
 * @brief 美洽SDK的配置管理类
 *
 * 开发者可以通过MQManager中提供的接口，对SDK进行配置；
 */

@class MQTicket;
@interface MQManager : NSObject


/// 注册状态观察者在状态改变的时候调用
/// 注意不要使用 self, 该 block 会被 retain，使用 self 会导致调用的类无法被释放。
+ (void)addStateObserverWithBlock:(StateChangeBlock)block withKey:(NSString *)key;

+ (void)removeStateChangeObserverWithKey:(NSString *)key;

+ (MQState)getCurrentState;

/**
 *  开启美洽服务
 *
 *  @warning App进入前台时，需要开启美洽服务。开发者需要在AppDelegate.m中的applicationWillEnterForeground方法中，调用此接口，用于开启美洽服务
 */
+ (void)openMeiqiaService;

/**
 *  关闭美洽服务
 *
 *  @warning App退到后台时，需要关闭美洽服务。开发者需要在AppDelegate.m中的applicationDidEnterBackground方法中，调用此接口，用于关闭美洽服务
 */
+ (void)closeMeiqiaService;

/**
 * 设置用户的设备唯一标识，在AppDelegate.m的didRegisterForRemoteNotificationsWithDeviceToken系统回调中注册deviceToken。
 * App进入后台后，美洽推送给开发者服务端的消息数据格式中，会有deviceToken的字段。
 *
 * @param deviceToken 设备唯一标识，用于推送服务;
 * @warning 初始化前后均可调用
 */
+ (void)registerDeviceToken:(NSData *)deviceToken;

/**
 @param deviceToken 去掉特殊符号和空格之后的字符串
 */
+ (void)registerDeviceTokenString:(NSString *)token;

/**
 * 初始化SDK。美洽建议开发者在AppDelegate.m中的系统回调didFinishLaunchingWithOptions中进行SDK初始化。
 * 如果成功返回一个顾客的信息，开发者可保存该clientId，绑定开发者自己的用户系统，下次使用setClientOnlineWithClientId进行上线
 *
 * @param appKey 美洽提供的AppKey
 * @param completion 如果初始化成功，将会返回clientId，并且error为nil；如果初始化失败，clientId为空，会返回error
 */
+ (void)initWithAppkey:(NSString*)appKey completion:(void (^)(NSString *clientId, NSError *error))completion;

/**
    获取本地初始化过的 app key
 */
+ (NSArray *)getLocalAppKeys;

/**
 获取当前使用的 app key
 */
+ (NSString *)getCurrentAppKey;

/**
 获取消息所对应的企业 appkey
 */
+ (NSString *)appKeyForMessage:(MQMessage *)message;

/**
 * 设置指定分配的客服或客服组。
 *
 * @param agentId                指定分配的客服id，可为空
 * @param agentGroupId           指定分配的客服组id，可为空（如果agentId和agentGroupId均未空，则随机分配一个客服）
 * @param scheduleRule           指定分配客服/客服组，该客服/客服组不在线，如何转接的接口，默认转接给企业随机一个客服
 * @warning 该接口需要在顾客上线前进行设置，设置后指定分配客服将会在顾客上线时生效
 */
+ (void)setScheduledAgentWithAgentId:(NSString *)agentId
                        agentGroupId:(NSString *)agentGroupId
                        scheduleRule:(MQScheduleRules)scheduleRule;

/**
 * 设置不指定分配的客服或客服组。
 *
*/
+ (void)setNotScheduledAgentWithAgentId:(NSString *)agentId;

/**
 * 开发者自定义当前顾客的信息，用于展示给客服。
 *
 * @param clientInfo 顾客的信息
 * @warning 需要顾客先上线，再上传顾客信息。如果开发者使用美洽的开源界面，不需要调用此接口，使用 MQChatViewManager 中的 setClientInfo 配置用户自定义信息即可。
 * @warning 如果开发者使用「开源聊天界面」的接口来上线，则需要监听 MQ_CLIENT_ONLINE_SUCCESS_NOTIFICATION「顾客成功上线」的广播（见 MQDefinition.h），再调用此接口
 */
+ (void)setClientInfo:(NSDictionary<NSString *, NSString *>*)clientInfo
           completion:(void (^)(BOOL success, NSError *error))completion;

/**
 * 开发者自定义当前顾客的信息，用于展示给客服，强制更新
 *
 * @param clientInfo 顾客的信息
 * @warning 需要顾客先上线，再上传顾客信息。如果开发者使用美洽的开源界面，不需要调用此接口，使用 MQChatViewManager 中的 setClientInfo 配置用户自定义信息即可。
 * @warning 如果开发者使用「开源聊天界面」的接口来上线，则需要监听 MQ_CLIENT_ONLINE_SUCCESS_NOTIFICATION「顾客成功上线」的广播（见 MQDefinition.h），再调用此接口
 */
+ (void)updateClientInfo:(NSDictionary<NSString *, NSString *>*)clientInfo
           completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  设置顾客的头像
 *
 *  @param avatarImage 头像Image
 *  @param completion  设置头像图片的回调
 *  @warning 需要顾客上线之后，再调用此接口，具体请监听 MQ_CLIENT_ONLINE_SUCCESS_NOTIFICATION「顾客成功上线」的广播，具体见 MQDefinition.h
 */
+ (void)setClientAvatar:(UIImage *)avatarImage
             completion:(void (^)(NSString *avatarUrl, NSError *error))completion;

/**
 * 让当前的client上线。请求成功后，该顾客将会出现在客服的对话列表中。
 *
 * @param result 上线结果，可以用作判断是否上线成功
 * @param agent 上线成功后，被分配的客服实体
 * @param messages 当前对话的消息
 * @param receiveMessageDelegate 接收消息的委托代理
 * @warning 需要初始化后才能调用；
 * @warning 建议在顾客点击「在线客服」按钮时，再调用该接口；不建议在 App 启动时调用该接口，这样会产生大量无效对话；
 */
+ (void)setCurrentClientOnlineWithSuccess:(void (^)(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages))success
                                  failure:(void (^)(NSError *error))failure
                   receiveMessageDelegate:(id<MQManagerDelegate>)receiveMessageDelegate;

/**
 * 根据美洽的顾客id，登陆美洽客服系统，并上线该顾客。请求成功后，该顾客将会出现在客服的对话列表中。
 *
 * @param clientId 美洽的顾客id
 * @param result 上线结果，可以用作判断是否上线成功。
 * @param agent 上线成功后，被分配的客服实体
 * @param messages 当前对话的消息
 * @param receiveMessageDelegate 接收消息的委托代理
 * @warning 需要初始化后才能调用；
 * @warning 建议在顾客点击「在线客服」按钮时，再调用该接口；不建议在 App 启动时调用该接口，这样会产生大量无效对话；
 */
+ (void)setClientOnlineWithClientId:(NSString *)clientId
                            success:(void (^)(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages))success
                            failure:(void (^)(NSError *error))failure
             receiveMessageDelegate:(id<MQManagerDelegate>)receiveMessageDelegate;

/**
 * 根据开发者自定义的id，登陆美洽客服系统，并上线该顾客。请求成功后，该顾客将会出现在客服的对话列表中。
 *
 * @param customizedId 开发者自定义的id，服务端查询该企业是否有该自定义id对应的client，如果存在，则用该client上线并分配对话；如果不存在，服务端生成一个新的client上线并分配对话，并将该customizedId与该新生成的client进行绑定；
 * @param result 上线结果，可以用作判断是否上线成功。
 * @param agent 上线成功后，被分配的客服实体
 * @param messages 当前对话的消息
 * @param receiveMessageDelegate 接收消息的委托代理
 * @warning 需要初始化后才能调
 * @warning customizedId不能为自增长，否则有安全隐患，建议开发者使用setClientOnlineWithClientId接口进行登录
 * @warning 建议在顾客点击「在线客服」按钮时，再调用该接口；不建议在 App 启动时调用该接口，这样会产生大量无效对话；
 */
+ (void)setClientOnlineWithCustomizedId:(NSString *)customizedId
                                success:(void (^)(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages))success
                                failure:(void (^)(NSError *error))failure
                 receiveMessageDelegate:(id<MQManagerDelegate>)receiveMessageDelegate;

/**
 *  获取当前顾客的顾客id，开发者可保存该顾客id，下次使用setClientOnlineWithClientId接口来让该顾客登陆美洽客服系统
 *
 *  @return 当前的顾客id
 *  
 */
+ (NSString *)getCurrentClientId;


/**
 当前的顾客自定义 id
 */
+ (NSString *)getCurrentCustomizedId;

/**
 *  获取当前顾客的顾客信息
 *
 *  @return 当前的顾客的信息
 *
 */
+ (NSDictionary *)getCurrentClientInfo;

/**
 * 美洽将重新初始化一个新的顾客，该顾客没有任何历史记录及用户信息。开发者可选择将该id保存并与app的用户绑定。
 *
 * @param completion 初始化新顾客的回调；success:是否创建成功成功; clientId:新顾客的id，开发者可选择将该id保存并与app的用户绑定。
 * @warning 需要在初始化后，且顾客为离线状态调用。否则success为NO，且返回当前在线顾客的clientId
 */
+ (void)createClient:(void (^)(NSString *clientId, NSError *error))completion;

/**
 * 设置顾客离线
 * @warning 需要初始化成功后才能调用
 * @warning 美洽建议：退出聊天界面时，不要调用此接口；因为：如果设置了顾客离线，则客服发送的消息将会发送给开发者的推送服务器；如果没有设置顾客离线，开发者接受即时消息的代理收到消息，并收到新消息产生的notification；开发者可以监听此notification，用于显示小红点未读标记；
 */
+ (void)setClientOffline;

/**
 * 获取当前正在接待的客服信息
 *
 * @return 客服实体
 * @warning 需要在初始化成功后且顾客在上线状态调用。如果上线后没有客服在线，将会返回nil；如果分配到客服，则返回该Agent对象。
 */
+ (MQAgent *)getCurrentAgent;

/**
 * 从服务端获取某日期之前的历史消息
 *
 * @param msgDate        获取该日期之前的历史消息，注：该日期是UTC格式的;
 * @param messagesNumber 获取消息的数量
 * @param success        回调中，messagesArray:消息数组
 * @param failure        获取失败，返回错误信息
 * @warning 需要在初始化成功后调用才有效
 */
+ (void)getServerHistoryMessagesWithUTCMsgDate:(NSDate *)msgDate
                                messagesNumber:(NSInteger)messagesNumber
                                       success:(void (^)(NSArray<MQMessage *> *messagesArray))success
                                       failure:(void (^)(NSError* error))failure;

/**
 * 从本地数据库获取历史消息
 *
 * @param msgDate        获取该日期之前的历史消息;
 * @param messagesNumber 获取消息的数量
 * @param success        回调中，messagesArray:消息数组
 * @warning 需要在初始化成功后调用才有效
 */
+ (void)getDatabaseHistoryMessagesWithMsgDate:(NSDate *)msgDate
                               messagesNumber:(NSInteger)messagesNumber
                                       result:(void (^)(NSArray<MQMessage *> *messagesArray))result;

/**
 *  下载多媒体消息的多媒体内容
 *
 *  @param messageId     消息id
 *  @param progressBlock 下载进度
 *  @param completion    完成回调
 */
+ (void)downloadMediaWithUrlString:(NSString *)urlString
                          progress:(void (^)(float progress))progressBlock
                        completion:(void (^)(NSData *mediaData, NSError *error))completion;


/**
 *  取消下载
 *
 *  @param urlString     url
 */
+ (void)cancelDownloadForUrl:(NSString *)urlString;

/**
 *  清除所有美洽的多媒体缓存
 *
 *  @param mediaSize 美洽缓存多媒体的大小，以 M 为单位
 */
+ (void)removeAllMediaDataWithCompletion:(void (^)(float mediaSize))completion;

/**
 * 发送文字消息
 *
 * @param content 消息内容。会做前后去空格处理，处理后的消息长度不能为0，否则不执行发送操作
 * @param sendedMessage 返回发送后的消息。消息是否发送成功，需根据message的sendStatus判断。
 *
 * @return 该条文字消息。此时该消息状态为发送中.
 * @warning 需要在初始化成功后，且顾客是在线状态时调用才有效
 */
+ (MQMessage *)sendTextMessageWithContent:(NSString *)content
                               completion:(void (^)(MQMessage *sendedMessage, NSError *error))completion;

/**
 * 发送图片消息。
 *
 * @param image 图片
 * @param sendedMessage 返回发送后的消息。如果发送成功，message的content为图片的网络地址。消息是否发送成功，需根据message的sendStatus判断。
 * @return 该条图片消息。此时该消息状态为发送中，message的content属性是本地图片路径
 * @warning SDK不会去限制图片大小，如果开发者需要限制图片大小，需要调整图片大小后，再使用此接口
 * @warning 需要在初始化成功后，且顾客是在线状态时调用才有效
 */
+ (MQMessage *)sendImageMessageWithImage:(UIImage *)image
                              completion:(void (^)(MQMessage *sendedMessage, NSError *error))completion;

/**
 * 发送语音消息。
 *
 * @param audio 需要发送的语音消息，格式为amr。
 * @param sendedMessage 返回发送后的消息。如果发送成功，message的content为语音的网络地址。消息是否发送成功，需根据message的sendStatus判断。
 * @return 该条语音消息。此时该消息状态为发送中，message的content属性是本地语音路径.
 * @warning 使用该接口，需要开发者提供一条amr格式的语音.
 * @warning 需要在初始化成功后，且顾客是在线状态时调用才有效
 */
+ (MQMessage *)sendAudioMessage:(NSData *)audio
                     completion:(void (^)(MQMessage *sendedMessage, NSError *error))completion;

/**
 * 将用户正在输入的内容，提供给客服查看。该接口没有调用限制，但每1秒内只会向服务器发送一次数据
 * @param content 提供给客服看到的内容
 * @warning 需要在初始化成功后，且顾客是在线状态时调用才有效
 */
+ (void)sendClientInputtingWithContent:(NSString *)content;

/**
 * 是否修改某条消息为未读
 * @param messageIds 被修改的消息id数组
 * @param isRead   该消息是否已读
 */
+ (void)updateMessageIds:(NSArray *)messageIds
         toReadStatus:(BOOL)isRead;

/**
 * 将所有消息标记为已读
 */
+ (void)markAllMessagesAsRead;

/**
 *  将数据库中某个message删除
 *
 *  @param messageId 消息id
 */
+ (void)removeMessageInDatabaseWithId:(NSString *)messageId
                           completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  将 SDK 本地数据库中的消息都删除
 */
+ (void)removeAllMessageFromDatabaseWithCompletion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  结束当前的对话
 *
 *  @param completion 结束对话后的回调
 *  @warning 美洽建议：退出聊天界面时，不要调用此接口，顾客产生的对话如果长时间没有响应，美洽后端将会结束这些超时的对话。
 *  @warning 因为结束对话后，客服在工作台将不能对已经结束的对话发送消息，顾客也就不能收到客服的回复了。一般顾客咨询的场景是：顾客在聊天界面咨询了一个问题后，通常不会在聊天界面中等待客服的回复，而是退出聊天界面去玩儿 App 的其他功能；如果退出聊天界面，就结束了该对话，那么该条对话将变成历史对话，客服在 web 工作台看不到该对话，有可能就把这条对话无视掉了。
 *  @warning 如果开发者担心系统超时结束对话的时间很慢，开发者可以建立一个 Timer，在顾客退出聊天界面后开始计时，并在顾客重新进入客服聊天界面或监听到 SDK 收到客服消息时，重置 Timer；如果 Timer 超过开发者设置的时间阈值，则可以调用结束当前对话。
 */
+ (void)endCurrentConversationWithCompletion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  顾客给当前的对话进行评价
 *
 *  @param evaluation 服务级别
 *  @param comment    评价留言
 *  @param completion 结果回调
 */
+ (void)evaluateCurrentConversationWithEvaluation:(MQConversationEvaluation)evaluation
                                          comment:(NSString *)comment
                                       completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  缓存当前的输入文字
 *
 *  @param inputtingText 输入文字
 */
+ (void)setCurrentInputtingText:(NSString *)inputtingText;

/**
 *  获取缓存的输入文字
 *
 *  @return 输入文字
 */
+ (NSString *)getPreviousInputtingText;

/**
 * 获得当前美洽SDK的版本号
 */
+ (NSString *)getMeiQiaSDKVersion;


/**
 * 获得所有未读消息，包括本地和服务端的
 */
+ (void)getUnreadMessagesWithCompletion:(void (^)(NSArray *messages, NSError *error))completion;

/**
 获得本地未读消息
 */
+ (NSArray *)getLocalUnreadeMessages;

/**
 * 当前用户是否被加入黑名单
 */
+ (BOOL)isBlacklisted;


/**
 * 请求文件的下载地址
 */
+ (void)clientDownloadFileWithMessageId:(NSString *)messageId
                                      conversatioId:(NSString *)conversationId
                                      andCompletion:(void(^)(NSString *url, NSError *error))action;

/**
 修改或增加已保存的消息中的 accessory data 中的数据
 
 @param accessoryData 字典中的数据必须是基本数据和字符串
 */
+ (void)updateMessageWithId:(NSString *)messageId forAccessoryData:(NSDictionary *)accessoryData;

/**
 对机器人的回答做评价
 @param messageId 消息 id
 */
+ (void)evaluateBotMessage:(NSString *)messageId
                  isUseful:(BOOL)isUseful
                completion:(void (^)(BOOL success, NSString *text, NSError *error))completion;

/**
 强制转人工
 */
+ (void)forceRedirectHumanAgentWithSuccess:(void (^)(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages))success
                                   failure:(void (^)(NSError *error))failure
                    receiveMessageDelegate:(id<MQManagerDelegate>)receiveMessageDelegate;

/**
 转换 emoji 别名为 Unicode
 */
+ (NSString *)convertToUnicodeWithEmojiAlias:(NSString *)text;

/**
 获取当前的客服 id
 */
+ (NSString *)getCurrentAgentId;

/**
 获取当前的客服 type: agent | admin | robot
 */
+ (NSString *)getCurrentAgentType;

/**
获取当前企业的配置信息
 */

+ (void)getEnterpriseConfigDataComplete:(void(^)(MQEnterprise *, NSError *))action;

/**
 开始显示聊天界面，如果自定义聊天界面，在聊天界面出现的时候调用，通知 SDK 进行初始化
 */
+ (void)didStartChat;

/**
 聊天结束，如果自定义聊天界面，在聊天界面消失的时候嗲用，通知 SDK 进行清理工作
 */
+ (void)didEndChat;

/* 获取客服邀请评价显示的文案
 */
+ (void)getEvaluationPromtTextComplete:(void(^)(NSString *, NSError *))action;

/**
 获取是否显示强制转接人工按钮
 */
+ (void)getIsShowRedirectHumanButtonComplete:(void(^)(BOOL, NSError *))action;

/**
 获取留言表单引导文案
 */
+ (void)getMessageFormConfigComplete:(void (^)(MQEnterpriseConfig *config, NSError *))action;

/**
 获取 ticket 类别
 */
+ (void)getTicketCategoryComplete:(void(^)(NSArray *categories))action;

/**
 获取从指定日期开始的所有工单消息
 */
+ (void)getTicketsFromDate:(NSDate *)date complete:(void(^)(NSArray *, NSError *))action;

/**
 *  提交留言表单
 *
 *  @param message 留言消息
 *  @param images 图片数组
 *  @param clientInfo 顾客的信息
 *  @param completion  提交留言表单的回调
 */
+ (void)submitMessageFormWithMessage:(NSString *)message
                              images:(NSArray *)images
                          clientInfo:(NSDictionary<NSString *, NSString *>*)clientInfo
                          completion:(void (^)(BOOL success, NSError *error))completion;

/**
    切换本地用户为指定的自定义 id 用户, 回调的 clientId 如果为 nil 的话表示刷新失败，或者该用户不存在。
 */
+ (void)refreshLocalClientWithCustomizedId:(NSString *)customizedId complete:(void(^)(NSString *clientId))action;

/**
 获取当前用户在等待队列的位置
 */
+ (void)getClientQueuePositionComplete:(void (^)(NSInteger position, NSError *error))action;

/**
 获取用户在等待队列中的位置，为 0 则表示没有在等待队列
 */
+ (int)waitingInQueuePosition;


+ (NSError *)checkGlobalError;

/**
 根据当前的用户 id， 或者自定义用户 id，首先判断需不需要显示询前表单：如果当前对话未结束，则需要显示，这时发起请求，从服务器获取表单数据，返回的结果根据用户指定的 agent token， group token（如果有），将数据过滤之后返回。
 */
+ (void)requestPreChatServeyDataIfNeedWithClientId:(NSString *)clientIdIn customizedId:(NSString *)customizedIdIn completion:(void(^)(MQPreChatData *data, NSError *error))block;

/**
 获取验证码图片和 token
 */
+ (void)getCaptchaComplete:(void(^)(NSString *token, UIImage *image))block;

/**
 获取验证码图片和 token
 */
+ (void)getCaptchaURLComplete:(void(^)(NSString *token, NSString *imageURL))block;

/**
 提交用户填写的讯前表单数据
 */
+ (void)submitPreChatForm:(NSDictionary *)formData completion:(void(^)(id, NSError *))block;

/**
 提交用户填写的留言工单
 */
+ (void)submitTicketForm:(NSString *)content userInfo:(NSDictionary *)userInfo completion:(void(^)(MQTicket *ticket, NSError *))block;


@end
