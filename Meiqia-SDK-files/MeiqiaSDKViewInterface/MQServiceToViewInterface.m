//
//  MQServiceToViewInterface.m
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 15/11/5.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MQServiceToViewInterface.h"
#import <MeiQiaSDK/MeiqiaSDK.h>
#import "MQBundleUtil.h"
#import "MQChatFileUtil.h"
#import "NSArray+MQFunctional.h"
#import "MQBotMessageFactory.h"
#import "MQMessageFactoryHelper.h"
#import "MQVisialMessageFactory.h"
#import "MQEventMessageFactory.h"

#pragma 该文件的作用是:开源聊天界面调用美洽 SDK 接口的中间层,目的是剥离开源界面中的美洽业务逻辑.这样就能让该聊天界面用于非美洽项目中,开发者只需要实现 'MQServiceToViewInterface'中的方法,即可将自己项目的业务逻辑和该聊天界面对接.

@interface MQServiceToViewInterface()<MQManagerDelegate>

@end

@implementation MQServiceToViewInterface

+ (void)getServerHistoryMessagesWithMsgDate:(NSDate *)msgDate
                             messagesNumber:(NSInteger)messagesNumber
                            successDelegate:(id<MQServiceToViewInterfaceDelegate>)successDelegate
                              errorDelegate:(id<MQServiceToViewInterfaceErrorDelegate>)errorDelegate
{
    //将msgDate修改成GMT时区
    [MQManager getServerHistoryMessagesWithUTCMsgDate:msgDate messagesNumber:messagesNumber success:^(NSArray<MQMessage *> *messagesArray) {
        NSArray *toMessages = [MQServiceToViewInterface convertToChatViewMessageWithMQMessages:messagesArray];
        if (successDelegate) {
            if ([successDelegate respondsToSelector:@selector(didReceiveHistoryMessages:)]) {
                [successDelegate didReceiveHistoryMessages:toMessages];
            }
        }
    } failure:^(NSError *error) {
        if (errorDelegate) {
            if ([errorDelegate respondsToSelector:@selector(getLoadHistoryMessageError)]) {
                [errorDelegate getLoadHistoryMessageError];
            }
        }
    }];
}

+ (void)getDatabaseHistoryMessagesWithMsgDate:(NSDate *)msgDate
                               messagesNumber:(NSInteger)messagesNumber
                                     delegate:(id<MQServiceToViewInterfaceDelegate>)delegate
{
    [MQManager getDatabaseHistoryMessagesWithMsgDate:msgDate messagesNumber:messagesNumber result:^(NSArray<MQMessage *> *messagesArray) {
        NSArray *toMessages = [MQServiceToViewInterface convertToChatViewMessageWithMQMessages:messagesArray];
        if (delegate) {
            if ([delegate respondsToSelector:@selector(didReceiveHistoryMessages:)]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [delegate didReceiveHistoryMessages:toMessages];
                });
            }
        }
    }];
}

+ (void)getServerHistoryMessagesAndTicketsWithMsgDate:(NSDate *)msgDate
                             messagesNumber:(NSInteger)messagesNumber
                            successDelegate:(id<MQServiceToViewInterfaceDelegate>)successDelegate
                              errorDelegate:(id<MQServiceToViewInterfaceErrorDelegate>)errorDelegate
{
    [MQManager getServerHistoryMessagesAndTicketsWithUTCMsgDate:msgDate messagesNumber:messagesNumber success:^(NSArray<MQMessage *> *messagesArray) {
        NSArray *toMessages = [MQServiceToViewInterface convertToChatViewMessageWithMQMessages:messagesArray];
        if (successDelegate) {
            if ([successDelegate respondsToSelector:@selector(didReceiveHistoryMessages:)]) {
                [successDelegate didReceiveHistoryMessages:toMessages];
            }
        }
    } failure:^(NSError *error) {
        if (errorDelegate) {
            if ([errorDelegate respondsToSelector:@selector(getLoadHistoryMessageError)]) {
                [errorDelegate getLoadHistoryMessageError];
            }
        }
    }];
}

+ (NSArray *)convertToChatViewMessageWithMQMessages:(NSArray *)messagesArray {
    //将MQMessage转换成UI能用的Message类型
    NSMutableArray *toMessages = [[NSMutableArray alloc] init];
    for (MQMessage *fromMessage in messagesArray) {
        // 这里加要单独处理欢迎语头像处理问题
        if (fromMessage.type == MQMessageTypeWelcome && [fromMessage.agentId intValue] == 0 && fromMessage.messageAvatar.length < 1) {
            fromMessage.messageAvatar = [MQServiceToViewInterface getEnterpriseConfigAvatar];
            fromMessage.messageUserName = [MQServiceToViewInterface getEnterpriseConfigName];
         }
        
        // 非顾客消息 又没有头像 补充企业头像
        else if (fromMessage.fromType != MQMessageFromTypeClient && fromMessage.messageAvatar.length < 1) {
            fromMessage.messageAvatar = [MQServiceToViewInterface getEnterpriseConfigAvatar];
            fromMessage.messageUserName = [MQServiceToViewInterface getEnterpriseConfigName];
        }
        
        MQBaseMessage *toMessage = [[MQMessageFactoryHelper factoryWithMessageAction:fromMessage.action contentType:fromMessage.contentType fromType:fromMessage.fromType] createMessage:fromMessage];
        if (toMessage) {
            [toMessages addObject:toMessage];
        }
    }
    
    return toMessages;
}


+ (void)sendTextMessageWithContent:(NSString *)content
                         messageId:(NSString *)localMessageId
                          delegate:(id<MQServiceToViewInterfaceDelegate>)delegate;
{
    [MQManager sendTextMessageWithContent:content completion:^(MQMessage *sendedMessage, NSError *error) {
        if (error) {
            [self didSendFailedWithMessage:sendedMessage localMessageId:localMessageId error:error delegate:delegate];
        } else {
            [self didSendMessage:sendedMessage localMessageId:localMessageId delegate:delegate];
        }
    }];
}

+ (void)sendImageMessageWithImage:(UIImage *)image
                        messageId:(NSString *)localMessageId
                         delegate:(id<MQServiceToViewInterfaceDelegate>)delegate;
{
    [MQManager sendImageMessageWithImage:image completion:^(MQMessage *sendedMessage, NSError *error) {
        if (error) {
            [self didSendFailedWithMessage:sendedMessage localMessageId:localMessageId error:error delegate:delegate];
        } else {
            [self didSendMessage:sendedMessage localMessageId:localMessageId delegate:delegate];
        }
    }];
}

+ (void)sendAudioMessage:(NSData *)audio
               messageId:(NSString *)localMessageId
                delegate:(id<MQServiceToViewInterfaceDelegate>)delegate
{
    [MQManager sendAudioMessage:audio completion:^(MQMessage *sendedMessage, NSError *error) {
        if (error) {
            [self didSendFailedWithMessage:sendedMessage localMessageId:localMessageId error:error delegate:delegate];
        } else {
            [self didSendMessage:sendedMessage localMessageId:localMessageId delegate:delegate];
        }
    }];
}

+ (void)sendVideoMessageWithFilePath:(NSString *)filePath messageId:(NSString *)localMessageId delegate:(id<MQServiceToViewInterfaceDelegate>)delegate {
    [MQManager sendVideoMessage:filePath completion:^(MQMessage *sendedMessage, NSError *error) {
        if (error) {
            [self didSendFailedWithMessage:sendedMessage localMessageId:localMessageId error:error delegate:delegate];
        } else {
            [self didSendMessage:sendedMessage localMessageId:localMessageId delegate:delegate];
        }
    }];
}

+ (void)sendProductCardMessageWithPictureUrl:(NSString *)pictureUrl title:(NSString *)title descripation:(NSString *)descripation productUrl:(NSString *)productUrl salesCount:(long)salesCount messageId:(NSString *)localMessageId delegate:(id<MQServiceToViewInterfaceDelegate>)delegate
{
    [MQManager sendProductCardMessageWithPictureUrl:pictureUrl title:title descripation:descripation productUrl:productUrl salesCount:salesCount completion:^(MQMessage *sendedMessage, NSError *error) {
        if (error) {
            [self didSendFailedWithMessage:sendedMessage localMessageId:localMessageId error:error delegate:delegate];
        } else {
            [self didSendMessage:sendedMessage localMessageId:localMessageId delegate:delegate];
        }
    }];
}

+ (void)sendClientInputtingWithContent:(NSString *)content
{
    [MQManager sendClientInputtingWithContent:content];
}

+ (void)didSendMessage:(MQMessage *)sendedMessage
        localMessageId:(NSString *)localMessageId
              delegate:(id<MQServiceToViewInterfaceDelegate>)delegate
{
    if (delegate) {
        if ([delegate respondsToSelector:@selector(didSendMessageWithNewMessageId:oldMessageId:newMessageDate:replacedContent:updateMediaPath:sendStatus:error:)]) {
            MQChatMessageSendStatus sendStatus = MQChatMessageSendStatusSuccess;
            if (sendedMessage.sendStatus == MQMessageSendStatusFailed) {
                sendStatus = MQChatMessageSendStatusFailure;
            } else if (sendedMessage.sendStatus == MQMessageSendStatusSending) {
                sendStatus = MQChatMessageSendStatusSending;
            }
            [delegate didSendMessageWithNewMessageId:sendedMessage.messageId oldMessageId:localMessageId newMessageDate:sendedMessage.createdOn replacedContent:sendedMessage.isSensitive ? sendedMessage.content : nil updateMediaPath:sendedMessage.content sendStatus:sendStatus error:nil];
        }
    }
}

+ (void)didSendFailedWithMessage:(MQMessage *)failedMessage
                  localMessageId:(NSString *)localMessageId
                           error:(NSError *)error
                        delegate:(id<MQServiceToViewInterfaceDelegate>)delegate
{
    NSLog(@"美洽SDK: 发送text消息失败\nerror = %@", error);
    if (delegate) {
        if ([delegate respondsToSelector:@selector(didSendMessageWithNewMessageId:oldMessageId:newMessageDate:replacedContent:updateMediaPath:sendStatus: error:)]) {
            [delegate didSendMessageWithNewMessageId:localMessageId oldMessageId:localMessageId newMessageDate:nil replacedContent:nil updateMediaPath:nil sendStatus:MQChatMessageSendStatusFailure error:error];
        }
    }
}

+ (void)setClientOffline
{
    [MQManager setClientOffline];
}

//+ (void)didTapMessageWithMessageId:(NSString *)messageId {
////    [MQManager updateMessage:messageId toReadStatus:YES];
//}

+ (NSString *)getCurrentAgentName {
    NSString *agentName = [MQManager getCurrentAgent].nickname;
    return agentName.length == 0 ? @"" : agentName;
}

+ (MQAgent *)getCurrentAgent {
    return [MQManager getCurrentAgent];
}

+ (MQChatAgentStatus)getCurrentAgentStatus {
    MQAgent *agent = [MQManager getCurrentAgent];
    if (!agent.isOnline) {
        return MQChatAgentStatusOffLine;
    }
    switch (agent.status) {
        case MQAgentStatusHide:
            return MQChatAgentStatusOffDuty;
            break;
        case MQAgentStatusOnline:
            return MQChatAgentStatusOnDuty;
            break;
        default:
            return MQChatAgentStatusOnDuty;
            break;
    }
    
}

+ (BOOL)isThereAgent {
    return [MQManager getCurrentAgent].agentId.length > 0;
}

+ (BOOL)haveConversation {
    return [MQManager haveConversation];
}

+(NSString *)getCurrentConversationID {
    return [MQManager getCurrentConversationID];
}

+ (void)downloadMediaWithUrlString:(NSString *)urlString
                          progress:(void (^)(float progress))progressBlock
                        completion:(void (^)(NSData *mediaData, NSError *error))completion
{
    [MQManager downloadMediaWithUrlString:urlString progress:^(float progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    } completion:^(NSData *mediaData, NSError *error) {
        if (completion) {
            completion(mediaData, error);
        }
    }];
}

+ (void)removeMessageInDatabaseWithId:(NSString *)messageId
                           completion:(void (^)(BOOL, NSError *))completion
{
    [MQManager removeMessageInDatabaseWithId:messageId completion:completion];
}

+ (NSDictionary *)getCurrentClientInfo {
    return [MQManager getCurrentClientInfo];
}

+ (void)uploadClientAvatar:(UIImage *)avatarImage
                completion:(void (^)(NSString *avatarUrl, NSError *error))completion
{
    [MQManager setClientAvatar:avatarImage completion:^(NSString *avatarUrl, NSError *error) {
        [MQChatViewConfig sharedConfig].outgoingDefaultAvatarImage = avatarImage;
        [[NSNotificationCenter defaultCenter] postNotificationName:MQChatTableViewShouldRefresh object:avatarImage];
        if (completion) {
            completion(avatarUrl, error);
        }
    }];
}

+ (void)getEnterpriseConfigInfoWithCache:(BOOL)isLoadCache complete:(void(^)(MQEnterprise *, NSError *))action {
    [MQManager getEnterpriseConfigDataWithCache:isLoadCache complete:action];
}

+ (NSString *)getEnterpriseConfigAvatar {
    return [MQManager getEnterpriseConfigAvatar];
}

+ (NSString *)getEnterpriseConfigName {
    return [MQManager getEnterpriseConfigName];
}

+ (BOOL)enableLeaveComment {
    return [MQManager enableLeaveComment];
}

+ (BOOL)allowActiveEvaluation {
    return [MQManager allowActiveEvaluation];
}

#pragma 实例方法
- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setClientOnlineWithCustomizedId:(NSString *)customizedId
                                success:(void (^)(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages, NSError *error))success
                 receiveMessageDelegate:(id<MQServiceToViewInterfaceDelegate>)receiveMessageDelegate
{
    self.serviceToViewDelegate = receiveMessageDelegate;
    [MQManager setClientOnlineWithCustomizedId:customizedId success:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
        NSArray *toMessages = [MQServiceToViewInterface convertToChatViewMessageWithMQMessages:messages];
        if (result == MQClientOnlineResultSuccess) {
            NSString *agentType = [agent convertPrivilegeToString];
            success(true, agent.nickname, agentType, toMessages, nil);
        } else if(result == MQClientOnlineResultNotScheduledAgent) {
            success(false, @"", @"", toMessages,nil);
        }
    } failure:^(NSError *error) {
        success(false, @"", @"", nil, error);
    } receiveMessageDelegate:self];
}

- (void)setClientOnlineWithClientId:(NSString *)clientId
                            success:(void (^)(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages, NSError *error))success
             receiveMessageDelegate:(id<MQServiceToViewInterfaceDelegate>)receiveMessageDelegate
{
    self.serviceToViewDelegate = receiveMessageDelegate;

    [MQManager setClientOnlineWithClientId:clientId success:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
        if (result == MQClientOnlineResultSuccess) {
            NSArray *toMessages = [MQServiceToViewInterface convertToChatViewMessageWithMQMessages:messages];
            NSString *agentType = [agent convertPrivilegeToString];
            success(true, agent.nickname, agentType, toMessages, nil);
        } else if((result == MQClientOnlineResultNotScheduledAgent) || (result == MQClientOnlineResultBlacklisted))  {
            success(false, @"", @"", nil, nil);
        }
    } failure:^(NSError *error) {
        success(false, @"初始化失败，请重新打开", @"", nil, error);
    } receiveMessageDelegate:self];
}

+ (void)setScheduledAgentWithAgentId:(NSString *)agentId
                        agentGroupId:(NSString *)agentGroupId
                        scheduleRule:(MQChatScheduleRules)scheduleRule
{
    MQScheduleRules rule = 0;
    switch (scheduleRule) {
        case MQChatScheduleRulesRedirectNone:
            rule = MQScheduleRulesRedirectNone;
            break;
        case MQChatScheduleRulesRedirectGroup:
            rule = MQScheduleRulesRedirectGroup;
            break;
        case MQChatScheduleRulesRedirectEnterprise:
            rule = MQScheduleRulesRedirectEnterprise;
            break;
        default:
            break;
    }
    [MQManager setScheduledAgentWithAgentId:agentId agentGroupId:agentGroupId scheduleRule:rule];
}

+ (void)setNotScheduledAgentWithAgentId:(NSString *)agentId {
    [MQManager setNotScheduledAgentWithAgentId:agentId];
}

+ (void)deleteScheduledAgent {
    [MQChatViewConfig sharedConfig].scheduledAgentId = nil;
    [MQChatViewConfig sharedConfig].scheduledGroupId = nil;
    [MQManager deleteScheduledAgent];
}

+ (void)setScheduledProblem:(NSString *)problem {
    [MQManager setScheduledProblem:problem];
}

+ (void)setEvaluationLevel:(NSInteger)level
                   comment:(NSString *)comment
{
    MQConversationEvaluation evaluation = MQConversationEvaluationPositive;
    switch (level) {
        case 0:
            evaluation = MQConversationEvaluationNegative;
            break;
        case 1:
            evaluation = MQConversationEvaluationModerate;
            break;
        case 2:
            evaluation = MQConversationEvaluationPositive;
            break;
        default:
            break;
    }
    [MQManager evaluateCurrentConversationWithEvaluation:evaluation comment:comment completion:^(BOOL success, NSError *error) {
    }];
}

+ (void)setClientInfoWithDictionary:(NSDictionary *)clientInfo
                         completion:(void (^)(BOOL success, NSError *error))completion
{
    if (!clientInfo) {
        NSLog(@"美洽 SDK：上传自定义信息不能为空。");
        completion(false, nil);
    }
    
    if ([MQChatViewConfig sharedConfig].updateClientInfoUseOverride) {
        [MQManager updateClientInfo:clientInfo completion:completion];
    } else {
        [MQManager setClientInfo:clientInfo completion:completion];
    }
}

+ (void)updateClientInfoWithDictionary:(NSDictionary *)clientInfo
                            completion:(void (^)(BOOL success, NSError *error))completion {
    if (!clientInfo) {
        NSLog(@"美洽 SDK：上传自定义信息不能为空。");
        completion(false, nil);
    }
    [MQManager updateClientInfo:clientInfo completion:^(BOOL success, NSError *error) {
        completion(success, error);
    }];
}

+ (void)setCurrentInputtingText:(NSString *)inputtingText {
    [MQManager setCurrentInputtingText:inputtingText];
}

+ (NSString *)getPreviousInputtingText {
    return [MQManager getPreviousInputtingText];
}

+ (void)getUnreadMessagesWithCompletion:(void (^)(NSArray *messages, NSError *error))completion {
    return [MQManager getUnreadMessagesWithCompletion:completion];
}

+ (void)getUnreadMessagesWithCustomizedId:(NSString *)customizedId withCompletion:(void (^)(NSArray *, NSError *))completion {
    return [MQManager getUnreadMessagesWithCustomizedId:customizedId completion:completion];
}

+ (NSArray *)getLocalUnreadMessages {
    return [MQManager getLocalUnreadeMessages];
}

+ (BOOL)isBlacklisted {
    return [MQManager isBlacklisted];
}

+ (void)clearReceivedFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if ([fileManager fileExistsAtPath:DIR_RECEIVED_FILE isDirectory:&isDir]) {
        NSError *error;
        [fileManager removeItemAtPath:DIR_RECEIVED_FILE error:&error];
        if (error) {
            NSLog(@"Fail to clear received files: %@",error.localizedDescription);
        }
    }
}

+ (void)updateMessageWithId:(NSString *)messageId forAccessoryData:(NSDictionary *)accessoryData {
    [MQManager updateMessageWithId:messageId forAccessoryData:accessoryData];
}

+ (void)updateMessageIds:(NSArray *)messageIds toReadStatus:(BOOL)isRead {
    [MQManager updateMessageIds:messageIds toReadStatus:isRead];
}

+ (void)markAllMessagesAsRead {
    [MQManager markAllMessagesAsRead];
}

+ (BOOL)getEnterpriseConfigWithdrawToastStatus {
    return [MQManager getEnterpriseConfigWithdrawToastStatus];
}

+ (void)prepareForChat {
    [MQManager didStartChat];
}

+ (void)completeChat {
    [MQManager didEndChat];
}

+ (void)refreshLocalClientWithCustomizedId:(NSString *)customizedId complete:(void(^)(NSString *clientId))action {
    [MQManager refreshLocalClientWithCustomizedId:customizedId complete:action];
}

+ (void)clientDownloadFileWithMessageId:(NSString *)messageId
                          conversatioId:(NSString *)conversationId
                          andCompletion:(void(^)(NSString *url, NSError *error))action {
    [MQManager clientDownloadFileWithMessageId:messageId conversatioId:conversationId andCompletion:action];
}

+ (void)cancelDownloadForUrl:(NSString *)urlString {
    [MQManager cancelDownloadForUrl:urlString];
}

+ (BOOL)enableBotEvaluateFeedback {
    return [MQManager enableBotEvaluateFeedback];
}

+ (void)evaluateBotMessage:(NSString *)messageId
                  isUseful:(BOOL)isUseful
                completion:(void (^)(BOOL success, NSString *text, NSError *error))completion
{
    [MQManager evaluateBotMessage:messageId isUseful:isUseful completion:completion];
}

+ (void)collectionBotOperationWithMessageId:(NSString *)messageId
                             operationIndex:(int)index
{
    [MQManager collectionBotOperationWithMessageId:messageId operationIndex:index];
}

#pragma mark - MQManagerDelegate

- (void)didReceiveMQMessages:(NSArray<MQMessage *> *)messages {
    if (!self.serviceToViewDelegate) {
        return;
    }
    
    if ([self.serviceToViewDelegate respondsToSelector:@selector(didReceiveNewMessages:)]) {
        [self.serviceToViewDelegate didReceiveNewMessages:[MQServiceToViewInterface convertToChatViewMessageWithMQMessages:messages]];
    }
}

- (void)didScheduleResult:(MQClientOnlineResult)onLineResult withResultMessages:(NSArray<MQMessage *> *)message{
    if ([self.serviceToViewDelegate respondsToSelector:@selector(didScheduleResult:withResultMessages:)]) {
        [self.serviceToViewDelegate didScheduleResult:onLineResult withResultMessages:message];
    }
}

//强制转人工
- (void)forceRedirectHumanAgentWithSuccess:(void (^)(BOOL completion, NSString *agentName, NSArray *receivedMessages))success
                                   failure:(void (^)(NSError *error))failure
                    receiveMessageDelegate:(id<MQServiceToViewInterfaceDelegate>)receiveMessageDelegate
{
    self.serviceToViewDelegate = receiveMessageDelegate;
    
    [MQManager forceRedirectHumanAgentWithSuccess:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
        NSArray *toMessages = [MQServiceToViewInterface convertToChatViewMessageWithMQMessages:messages];
        if (result == MQClientOnlineResultSuccess) {
            success(true, agent.nickname, toMessages);
        } else if(result == MQClientOnlineResultNotScheduledAgent) {
            success(false, @"", toMessages);
        }
    } failure:^(NSError *error) {
        
    } receiveMessageDelegate:self];
}

/**
 转换 emoji 别名为 Unicode
 */
+ (NSString *)convertToUnicodeWithEmojiAlias:(NSString *)text {
    return [MQManager convertToUnicodeWithEmojiAlias:text];
}

+ (NSString *)getCurrentAgentId {
    return [MQManager getCurrentAgentId];
}

+ (NSString *)getCurrentAgentType {
    return [MQManager getCurrentAgentType];
}

+ (void)getEvaluationPromtTextComplete:(void (^)(NSString *, NSError *))action {
    [MQManager getEvaluationPromtTextComplete:action];
}

+ (void)getIsShowRedirectHumanButtonComplete:(void (^)(BOOL, NSError *))action {
    [MQManager getIsShowRedirectHumanButtonComplete:action];
}

+ (void)getMessageFormConfigComplete:(void (^)(MQEnterpriseConfig *config, NSError *))action {
    [MQManager getMessageFormConfigComplete:action];
}

+ (void)getTicketCategoryComplete:(void(^)(NSArray *categories))action {
    [MQManager getTicketCategoryComplete:action];
}

+ (void)submitMessageFormWithMessage:(NSString *)message clientInfo:(NSDictionary<NSString *,NSString *> *)clientInfo completion:(void (^)(BOOL, NSError *))completion {
    [MQManager submitTicketForm:message userInfo:clientInfo completion:^(MQTicket *ticket, NSError *e) {
        if (e) {
            completion(NO, e);
        } else {
            completion(YES, nil);
        }
    }];
}

+ (int)waitingInQueuePosition {
    return [MQManager waitingInQueuePosition];
}

+ (void)getClientQueuePositionComplete:(void (^)(NSInteger position, NSError *error))action {
    return [MQManager getClientQueuePositionComplete:action];
}

+ (void)requestPreChatServeyDataIfNeedCompletion:(void(^)(MQPreChatData *data, NSError *error))block {
    NSString *clientId = [MQChatViewConfig sharedConfig].MQClientId;
    NSString *customId = [MQChatViewConfig sharedConfig].customizedId;

    [MQManager requestPreChatServeyDataIfNeedWithClientId:clientId customizedId:customId completion:block];
}

+ (void)getCaptchaComplete:(void(^)(NSString *token, UIImage *image))block {
    [MQManager getCaptchaComplete:block];
}

+ (void)getCaptchaWithURLComplete:(void (^)(NSString *token, NSString *url))block {
    [MQManager getCaptchaURLComplete:block];
}

+ (void)submitPreChatForm:(NSDictionary *)formData completion:(void(^)(id,NSError *))block {
    [MQManager submitPreChatForm:formData completion:block];
}

+ (NSError *)checkGlobalError {
    return [MQManager checkGlobalError];
}

+ (void)openMQGroupNotificationServiceWithDelegate:(id<MQGroupNotificationDelegate>)delegate {
    [MQManager openMQGroupNotificationServiceWithDelegate:delegate];
}

+ (void)insertMQGroupNotificationToConversion:(MQGroupNotification *)notification {
    [MQManager insertMQGroupNotificationToConversion:notification];
}

+ (BOOL)currentOpenVisitorNoMessage {
    return [MQManager currentOpenVisitorNoMessage];
}

+ (BOOL)currentHideHistoryConversation {
    return [MQManager currentHideHistoryConversation];
}

@end
