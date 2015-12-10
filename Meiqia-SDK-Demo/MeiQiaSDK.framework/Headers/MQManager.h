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

@protocol MQManagerDelegate <NSObject>

/**
 *  收到了客服消息
 *  @param message 客服消息
 */
- (void)didReceiveMQMessages:(NSArray<MQMessage *> *)message;

@end

/**
 * @brief 美洽SDK的配置管理类
 *
 * 开发者可以通过MQManager中提供的接口，对SDK进行配置；
 */
@interface MQManager : NSObject

/**
 *  关闭美洽推送，即客服发送消息将以即时消息发送，而不走远程推送
 *
 *  @warning App进入前台时，需要关闭美洽推送。开发者需要在AppDelegate.m中的applicationWillEnterForeground方法中，调用此接口，用于关闭美洽远程推送
 */
+ (void)closeMeiQiaRemotePushService;

/**
 *  通知美洽服务端发送消息至开发者的推送服务端，以便客服发送消息能正确发送到开发者的推送服务器
 *
 *  @warning App退到后台时，需要开启美洽推送。开发者需要在AppDelegate.m中的applicationDidEnterBackground方法中，调用此接口，用于开启美洽远程推送
 */
+ (void)openMeiQiaRemotePushService;

/**
 * 设置用户的设备唯一标识，在AppDelegate.m的didRegisterForRemoteNotificationsWithDeviceToken系统回调中注册deviceToken。
 * App进入后台后，美洽推送给开发者服务端的消息数据格式中，会有deviceToken的字段。
 *
 * @param deviceToken 设备唯一标识，用于推送服务;
 * @warning 初始化前后均可调用
 */
+ (void)registerDeviceToken:(NSData *)deviceToken;

/**
 * 初始化SDK。美洽建议开发者在AppDelegate.m中的系统回调didFinishLaunchingWithOptions中进行SDK初始化。
 * 如果成功返回一个顾客的信息，开发者可保存该clientId，绑定开发者自己的用户系统，下次使用setClientOnlineWithClientId进行上线
 *
 * @param appKey 美洽提供的AppKey
 * @param completion 如果初始化成功，将会返回clientId，并且error为nil；如果初始化失败，clientId为空，会返回error
 */
+ (void)initWithAppkey:(NSString*)appKey completion:(void (^)(NSString *clientId, NSError *error))completion;

/**
 * 设置指定分配的客服或客服组。
 *
 * @param agentToken                指定分配的客服id，可为空
 * @param agentGroupToken           指定分配的客服组id，可为空（如果agentToken和agentGroupToken均未空，则随机分配一个客服）
 * @warning 该接口需要在顾客上线前进行设置，设置后指定分配客服将会在顾客上线时生效
 */
+ (void)setScheduledAgentWithAgentToken:(NSString *)agentToken
                        agentGroupToken:(NSString *)agentGroupToken;

/**
 * 开发者自定义当前顾客的信息，用于展示给客服。
 *
 * @param clientInfo 顾客的信息
 */
+ (void)setClientInfo:(NSDictionary<NSString *, NSString *>*)clientInfo
           completion:(void (^)(BOOL success, NSError *error))completion;

/**
 * 让当前的client上线。请求成功后，该顾客将会出现在客服的对话列表中。
 *
 * @param result 上线结果，可以用作判断是否上线成功
 * @param scheduleConversation 上线成功后，被分配的对话实体
 * @param agent 上线成功后，被分配的客服实体
 * @param messages 当前对话的消息
 * @param receiveMessageDelegate 接收消息的委托代理
 * @warning 需要初始化后才能调用；
 */
+ (void)setCurrentClientOnlineWithSuccess:(void (^)(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages))success
                                  failure:(void (^)(NSError *error))failure
                      receiveMessageDelegate:(id<MQManagerDelegate>)receiveMessageDelegate;

/**
 * 根据美洽的顾客id，登陆美洽客服系统，并上线该顾客。请求成功后，该顾客将会出现在客服的对话列表中。
 *
 * @param clientId 美洽的顾客id
 * @param result 上线结果，可以用作判断是否上线成功。
 * @param scheduleConversation 上线成功后，被分配的对话实体
 * @param agent 上线成功后，被分配的客服实体
 * @param messages 当前对话的消息
 * @param receiveMessageDelegate 接收消息的委托代理
 * @warning 需要初始化后才能调用；
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
 * @param scheduleConversation 上线成功后，被分配的对话实体
 * @param agent 上线成功后，被分配的客服实体
 * @param messages 当前对话的消息
 * @param receiveMessageDelegate 接收消息的委托代理
 * @warning 需要初始化后才能调
 * @warning customizedId不能为自增长，否则有安全隐患，建议开发者使用setClientOnlineWithClientId接口进行登录
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
 * 美洽将重新初始化一个新的顾客，该顾客没有任何历史记录及用户信息。开发者可选择将该id保存并与app的用户绑定。
 *
 * @param completion 初始化新顾客的回调；success:是否创建成功成功; clientId:新顾客的id，开发者可选择将该id保存并与app的用户绑定。
 * @warning 需要在初始化后，且顾客为离线状态调用。否则success为NO，且返回当前在线顾客的clientId
 */
+ (void)createClient:(void (^)(NSString *clientId, NSError *error))completion;

/**
 * 设置顾客离线
 * @warning 需要初始化成功后才能调用
 * @warning 如果设置了顾客离线，则客服发送的消息将会发送给开发者的推送服务器；如果没有设置顾客离线，开发者接受即时消息的代理收到消息，并收到新消息产生的notification；开发者可以监听此notification，用于显示小红点未读标记；
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
 * 从服务端获取历史消息
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
 * 发送图片消息。SDK不会去压缩图片大小，如果开发者需要限制图片大小，需要压缩后，再使用此接口
 *
 * @param image 图片
 * @param sendedMessage 返回发送后的消息。如果发送成功，message的content为图片的网络地址。消息是否发送成功，需根据message的sendStatus判断。
 * @return 该条图片消息。此时该消息状态为发送中，message的content属性是本地图片路径
 * @warning 需要在初始化成功后，且顾客是在线状态时调用才有效
 */
+ (MQMessage *)sendImageMessageWithImage:(UIImage *)image
                              completion:(void (^)(MQMessage *sendedMessage, NSError *error))completion;

/**
 * 发送语音消息。使用该接口，需要开发者提供一条amr格式的语音.
 *
 * @param audio 需要发送的语音消息，格式为amr。
 * @param sendedMessage 返回发送后的消息。如果发送成功，message的content为语音的网络地址。消息是否发送成功，需根据message的sendStatus判断。
 * @return 该条语音消息。此时该消息状态为发送中，message的content属性是本地语音路径.
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
 * @param messageId 被修改的消息id
 * @param isRead   该消息是否已读
 */
+ (void)updateMessage:(NSString *)messageId toReadStatus:(BOOL)isRead;

/**
 * 结束当前的对话
 */
+ (void)endCurrentConversationWithCompletion:(void (^)(BOOL success, NSError *error))completion;

/**
 * 获得当前美洽SDK的版本号
 */
+ (NSString *)getMeiQiaSDKVersion;

@end
