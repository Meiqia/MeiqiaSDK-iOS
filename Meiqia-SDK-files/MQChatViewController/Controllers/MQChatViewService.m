//
//  MQChatViewService.m
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/28.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//


#import "MQChatViewService.h"
#import "MQTextMessage.h"
#import "MQImageMessage.h"
#import "MQVoiceMessage.h"
#import "MQCardMessage.h"
#import "MQWithDrawMessage.h"
#import "MQBotAnswerMessage.h"
#import "MQBotMenuMessage.h"
#import "MQPhotoCardMessage.h"
#import "MQProductCardMessage.h"
#import "MQBotGuideMessage.h"
#import "MQTextCellModel.h"
#import "MQCardCellModel.h"
#import "MQImageCellModel.h"
#import "MQVoiceCellModel.h"
#import "MQBotMenuCellModel.h"
#import "MQBotAnswerCellModel.h"
#import "MQRichTextViewModel.h"
#import "MQTipsCellModel.h"
#import "MQBotGuideCellModel.h"
#import "MQEvaluationResultCellModel.h"
#import "MQMessageDateCellModel.h"
#import "MQPhotoCardCellModel.h"
#import "MQProductCardCellModel.h"
#import <UIKit/UIKit.h>
#import "MQToast.h"
#import "MEIQIA_VoiceConverter.h"
#import "MQEventCellModel.h"
#import "MQAssetUtil.h"
#import "MQBundleUtil.h"
#import "MQFileDownloadCellModel.h"
#import "MQServiceToViewInterface.h"
#import <MeiQiaSDK/MeiqiaSDK.h>
#import "MQBotMenuAnswerCellModel.h"
#import "MQWebViewBubbleCellModel.h"
#import "MQBotWebViewBubbleAnswerCellModel.h"
#import "MQCustomizedUIText.h"
#import "NSArray+MQFunctional.h"
#import "MQToast.h"
#import "NSError+MQConvenient.h"
#import "MQMessageFactoryHelper.h"
#import "MQBotMenuRichCellModel.h"
#import "MQSplitLineCellModel.h"
#import "MQVideoMessage.h"
#import "MQVideoCellModel.h"
#import "MQBotHighMenuCellModel.h"
#import "MQBotHighMenuMessage.h"

#import "MQBotMenuWebViewBubbleAnswerCellModel.h"

#import "MQBotHighMenuRichCellModel.h"

static NSInteger const kMQChatMessageMaxTimeInterval = 60;

/** 一次获取历史消息数的个数 */
static NSInteger const kMQChatGetHistoryMessageNumber = 20;

#ifdef INCLUDE_MEIQIA_SDK
@interface MQChatViewService() <MQServiceToViewInterfaceDelegate, MQCellModelDelegate>

@property (nonatomic, strong) MQServiceToViewInterface *serviceToViewInterface;

@property (nonatomic, assign) BOOL noAgentTipShowed;

@property (nonatomic, weak) NSTimer *positionCheckTimer;

@property (nonatomic, strong) NSMutableArray *cacheTextArr;

@property (nonatomic, strong) NSMutableArray *cacheImageArr;

@property (nonatomic, strong) NSMutableArray *cacheFilePathArr;

@property (nonatomic, strong) NSMutableArray *cacheVideoPathArr;

@end
#else
@interface MQChatViewService() <MQCellModelDelegate>

@end
#endif

@implementation MQChatViewService {
#ifdef INCLUDE_MEIQIA_SDK
    BOOL addedNoAgentTip;  //是否已经说明了没有客服标记
#endif
    //当前界面上显示的 message
//    NSMutableSet *currentViewMessageIdSet;
}

- (instancetype)initWithDelegate:(id<MQChatViewServiceDelegate>)delegate errorDelegate:(id<MQServiceToViewInterfaceErrorDelegate>)errorDelegate {
    if (self = [super init]) {
        self.cellModels = [[NSMutableArray alloc] init];
        addedNoAgentTip = false;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromBackground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanTimer) name:MQ_NOTIFICATION_CHAT_END object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTimer) name:MQ_NOTIFICATION_QUEUEING_BEGIN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanTimer) name:MQ_NOTIFICATION_QUEUEING_END object:nil];
        
//        currentViewMessageIdSet = [NSMutableSet new];
        
        self.delegate = delegate;
        self.errorDelegate = errorDelegate;
        
        [self addObserve];
        [self updateChatTitleWithAgent:nil state:MQStateAllocatingAgent];
    }
    return self;
}

- (void)addObserve {
    __weak typeof(self) wself = self;
    [MQManager addStateObserverWithBlock:^(MQState oldState, MQState newState, NSDictionary *value, NSError *error) {
        __strong typeof (wself) sself = wself;
        MQAgent *agent = value[@"agent"];
        
        NSString *agentType = [agent convertPrivilegeToString];
        
        [sself updateChatTitleWithAgent:agent state:newState];
        
        if (![agentType isEqualToString:@"bot"] && agentType.length > 0) {
            [sself removeBotTipCellModels];
            [sself.delegate reloadChatTableView];
        }
        
        if (newState == MQStateOffline) {
            if ([value[@"reason"] isEqualToString:@"autoconnect fail"]) {
                [sself.delegate showToastViewWithContent:@"网络故障"];
            }
        }
    } withKey:@"MQChatViewService"];
}

- (void)startTimer {
    if (!self.positionCheckTimer) {
        self.positionCheckTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkAndUpdateWaitingQueueStatus) userInfo:nil repeats:YES];
    } else {
        if (!self.positionCheckTimer.isValid) {
            [self.positionCheckTimer fire];
        }
    }
}

- (void)cleanTimer {
    if (self.positionCheckTimer.isValid) {
        [self.positionCheckTimer invalidate];
        self.positionCheckTimer = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [MQManager removeStateChangeObserverWithKey:@"MQChatViewService"];
}

//从后台返回到前台时 
- (void)backFromBackground {
    if ([MQServiceToViewInterface waitingInQueuePosition] > 0 || [MQServiceToViewInterface isBlacklisted]) {
        [self setClientOnline];
    }
}

- (MQState)clientStatus {
    return [MQManager getCurrentState];
}

#pragma 增加cellModel并刷新tableView
- (void)addCellModelAndReloadTableViewWithModel:(id<MQCellModelProtocol>)cellModel {
    if (![self.cellModels containsObject:cellModel]) {
        [self.cellModels addObject:cellModel];
        //        [self.delegate reloadChatTableView];
        //        [self.delegate scrollTableViewToBottomAnimated:YES];
        [self.delegate insertCellAtBottomForModelCount: 1];
    }
}

/**
 * 获取更多历史聊天消息
 */
- (void)startGettingHistoryMessages {
    NSDate *firstMessageDate = [self getFirstServiceCellModelDate];
    if ([MQChatViewConfig sharedConfig].enableSyncServerMessage) {// 默认开启消息同步
        [MQServiceToViewInterface getServerHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kMQChatGetHistoryMessageNumber successDelegate:self errorDelegate:self.errorDelegate];
    } else {
        [MQServiceToViewInterface getDatabaseHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kMQChatGetHistoryMessageNumber delegate:self];
    }
}

/**
 * 在开启无消息访客过滤的条件下获取历史聊天信息
 */
- (void)getMessagesWithScheduleAfterClientSendMessage {
    NSDate *firstMessageDate = [self getFirstServiceCellModelDate];
    if ([MQChatViewConfig sharedConfig].enableSyncServerMessage) {// 默认开启消息同步
        [MQServiceToViewInterface getServerHistoryMessagesAndTicketsWithMsgDate:firstMessageDate messagesNumber:kMQChatGetHistoryMessageNumber successDelegate:self errorDelegate:self.errorDelegate];
    } else {
        [MQServiceToViewInterface getDatabaseHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kMQChatGetHistoryMessageNumber delegate:self];
    }
}


/// 获取本地历史所有消息
- (void)startGettingDateBaseHistoryMessages{
    NSDate *firstMessageDate = [self getFirstServiceCellModelDate];
    [MQServiceToViewInterface getDatabaseHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kMQChatGetHistoryMessageNumber delegate:self];
}

//xlp  获取历史消息 从最后一条数据
- (void)startGettingHistoryMessagesFromLastMessage {
    NSDate *lastMessageDate = [self getLastServiceCellModelDate];

    if ([MQChatViewConfig sharedConfig].enableSyncServerMessage) {
        [MQServiceToViewInterface getServerHistoryMessagesWithMsgDate:lastMessageDate messagesNumber:kMQChatGetHistoryMessageNumber successDelegate:self errorDelegate:self.errorDelegate];
    } else {
        [MQServiceToViewInterface getDatabaseHistoryMessagesWithMsgDate:lastMessageDate messagesNumber:kMQChatGetHistoryMessageNumber delegate:self];
    }
}
/**
 *  获取最旧的cell的日期，例如text/image/voice等
 */
- (NSDate *)getFirstServiceCellModelDate {
    for (NSInteger index = 0; index < self.cellModels.count; index++) {
        id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
#pragma 开发者可在下面添加自己更多的业务cellModel 以便能正确获取历史消息
        if ([cellModel isKindOfClass:[MQTextCellModel class]] ||
            [cellModel isKindOfClass:[MQImageCellModel class]] ||
            [cellModel isKindOfClass:[MQVoiceCellModel class]] ||
            [cellModel isKindOfClass:[MQVideoCellModel class]] ||
            [cellModel isKindOfClass:[MQEventCellModel class]] ||
            [cellModel isKindOfClass:[MQFileDownloadCellModel class]] ||
            [cellModel isKindOfClass:[MQPhotoCardCellModel class]] ||
            [cellModel isKindOfClass:[MQProductCardCellModel class]] ||
            [cellModel isKindOfClass:[MQWebViewBubbleCellModel class]] ||
            [cellModel isKindOfClass:[MQBotAnswerCellModel class]] ||
            [cellModel isKindOfClass:[MQBotMenuAnswerCellModel class]] ||
            [cellModel isKindOfClass:[MQBotMenuCellModel class]] ||
            [cellModel isKindOfClass:[MQBotHighMenuCellModel class]] ||
            [cellModel isKindOfClass:[MQBotHighMenuRichCellModel class]] ||
            [cellModel isKindOfClass:[MQBotMenuWebViewBubbleAnswerCellModel class]] ||
            [cellModel isKindOfClass:[MQBotWebViewBubbleAnswerCellModel class]] ||
            [cellModel isKindOfClass:[MQBotGuideCellModel class]] ||
            [cellModel isKindOfClass:[MQEvaluationResultCellModel class]])
        {
            return [cellModel getCellDate];
        }
    }
    return [NSDate date];
}

- (NSDate *)getLastServiceCellModelDate {
    for (NSInteger index = 0; index < self.cellModels.count; index++) {
        id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
      
        if (index == self.cellModels.count - 1) {

#pragma 开发者可在下面添加自己更多的业务cellModel 以便能正确获取历史消息
            if ([cellModel isKindOfClass:[MQTextCellModel class]] ||
                [cellModel isKindOfClass:[MQImageCellModel class]] ||
                [cellModel isKindOfClass:[MQVoiceCellModel class]] ||
                [cellModel isKindOfClass:[MQVideoCellModel class]] ||
                [cellModel isKindOfClass:[MQEventCellModel class]] ||
                [cellModel isKindOfClass:[MQFileDownloadCellModel class]] ||
                [cellModel isKindOfClass:[MQPhotoCardCellModel class]] ||
                [cellModel isKindOfClass:[MQProductCardCellModel class]] ||
                [cellModel isKindOfClass:[MQWebViewBubbleCellModel class]] ||
                [cellModel isKindOfClass:[MQBotAnswerCellModel class]] ||
                [cellModel isKindOfClass:[MQBotMenuAnswerCellModel class]] ||
                [cellModel isKindOfClass:[MQBotMenuCellModel class]] ||
                [cellModel isKindOfClass:[MQBotHighMenuCellModel class]] ||
                [cellModel isKindOfClass:[MQBotHighMenuRichCellModel class]] ||
                [cellModel isKindOfClass:[MQBotMenuWebViewBubbleAnswerCellModel class]] ||
                [cellModel isKindOfClass:[MQBotWebViewBubbleAnswerCellModel class]] ||
                [cellModel isKindOfClass:[MQBotWebViewBubbleAnswerCellModel class]] ||
                [cellModel isKindOfClass:[MQBotGuideCellModel class]] ||
                [cellModel isKindOfClass:[MQEvaluationResultCellModel class]])
            {
                return [cellModel getCellDate];
            }
        }
    }
    return [NSDate date];
}

#pragma mark - 消息发送

- (void)cacheSendText:(NSString *)text {
    [self.cacheTextArr addObject:text];
}

- (void)cacheSendImage:(UIImage *)image {
    [self.cacheImageArr addObject:image];
}

- (void)cacheSendAMRFilePath:(NSString *)filePath {
    [self.cacheFilePathArr addObject:filePath];
}

- (void)cacheSendVideoFilePath:(NSString *)filePath {
    [self.cacheVideoPathArr addObject:filePath];
}

/**
 * 发送文字消息
 */
- (void)sendTextMessageWithContent:(NSString *)content {
    MQTextMessage *message = [[MQTextMessage alloc] initWithContent:content];
    message.conversionId = [MQServiceToViewInterface getCurrentConversationID] ?:@"";
    MQTextCellModel *cellModel = [[MQTextCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addConversionSplitLineWithCurrentCellModel:cellModel];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
    [MQServiceToViewInterface sendTextMessageWithContent:content messageId:message.messageId delegate:self];
}

/**
 * 发送图片消息
 */
- (void)sendImageMessageWithImage:(UIImage *)image {
    MQImageMessage *message = [[MQImageMessage alloc] initWithImage:image];
    message.conversionId = [MQServiceToViewInterface getCurrentConversationID] ?:@"";
    MQImageCellModel *cellModel = [[MQImageCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addConversionSplitLineWithCurrentCellModel:cellModel];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
#ifdef INCLUDE_MEIQIA_SDK
    [MQServiceToViewInterface sendImageMessageWithImage:image messageId:message.messageId delegate:self];
#else
    //模仿发送成功
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        [self playSendedMessageSound];
    });
#endif
}

/**
 * 以AMR格式语音文件的形式，发送语音消息
 * @param filePath AMR格式的语音文件
 */
- (void)sendVoiceMessageWithAMRFilePath:(NSString *)filePath {
    //将AMR格式转换成WAV格式，以便使iPhone能播放
    NSData *wavData = [self convertToWAVDataWithAMRFilePath:filePath];
    MQVoiceMessage *message = [[MQVoiceMessage alloc] initWithVoiceData:wavData];
    [self sendVoiceMessageWithWAVData:wavData voiceMessage:message];
    NSData *amrData = [NSData dataWithContentsOfFile:filePath];
    [MQServiceToViewInterface sendAudioMessage:amrData messageId:message.messageId delegate:self];
}

/**
 * 以WAV格式语音数据的形式，发送语音消息
 * @param wavData WAV格式的语音数据
 */
- (void)sendVoiceMessageWithWAVData:(NSData *)wavData voiceMessage:(MQVoiceMessage *)message{
    message.conversionId = [MQServiceToViewInterface getCurrentConversationID] ?:@"";
    MQVoiceCellModel *cellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addConversionSplitLineWithCurrentCellModel:cellModel];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
#ifndef INCLUDE_MEIQIA_SDK
    //模仿发送成功
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        [self playSendedMessageSound];
    });
#endif
}

- (void)sendVideoMessageWithFilePath:(NSString *)filePath {
    MQVideoMessage *message = [[MQVideoMessage alloc] init];
    message.videoPath = filePath;
    message.conversionId = [MQServiceToViewInterface getCurrentConversationID] ?:@"";
    MQVideoCellModel *cellModel = [[MQVideoCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addConversionSplitLineWithCurrentCellModel:cellModel];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
#ifdef INCLUDE_MEIQIA_SDK
    [MQServiceToViewInterface sendVideoMessageWithFilePath:filePath messageId:message.messageId delegate:self];
#else
    //模仿发送成功
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        [self playSendedMessageSound];
    });
#endif
}

/**
 * 发送商品卡片消息
 * @param productCard 商品卡片的model
 */

- (void)sendProductCardWithModel:(MQProductCardMessage *)productCard
{
    MQProductCardMessage *message = [[MQProductCardMessage alloc] initWithPictureUrl:productCard.pictureUrl title:productCard.title description:productCard.desc productUrl:productCard.productUrl andSalesCount:productCard.salesCount];
    message.conversionId = [MQServiceToViewInterface getCurrentConversationID] ?:@"";
    MQProductCardCellModel *cellModel = [[MQProductCardCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addConversionSplitLineWithCurrentCellModel:cellModel];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
#ifdef INCLUDE_MEIQIA_SDK
    [MQServiceToViewInterface sendProductCardMessageWithPictureUrl:message.pictureUrl title:message.title descripation:message.desc productUrl:message.productUrl salesCount:message.salesCount messageId:message.messageId delegate:self];
#else
    //模仿发送成功
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        [self playSendedMessageSound];
    });
#endif
}

/**
  删除消息
 */

- (void)deleteMessageAtIndex:(NSInteger)index withTipMsg:(NSString *)tipMsg enableLinesDisplay:(BOOL)enable{
    NSString *messageId = [[self.cellModels objectAtIndex:index] getCellMessageId];
    [MQServiceToViewInterface removeMessageInDatabaseWithId:messageId completion:nil];
    [self.cellModels removeObjectAtIndex:index];
    [self.delegate removeCellAtIndex:index];
    if (tipMsg && tipMsg.length > 0) {
        [self addTipCellModelWithTips:tipMsg enableLinesDisplay:enable];
    }
}

/**
 * 重新发送消息
 * @param index 需要重新发送的index
 * @param resendData 重新发送的字典 [text/image/voice : data]
 */
- (void)resendMessageAtIndex:(NSInteger)index resendData:(NSDictionary *)resendData {
    //通知逻辑层删除该message数据
#ifdef INCLUDE_MEIQIA_SDK
    NSString *messageId = [[self.cellModels objectAtIndex:index] getCellMessageId];
    [MQServiceToViewInterface removeMessageInDatabaseWithId:messageId completion:nil];
    
#endif
    [self.cellModels removeObjectAtIndex:index];
    [self.delegate removeCellAtIndex:index];
    //判断删除这个model的之前的model是否为date，如果是，则删除时间cellModel
    if (index < 0 || self.cellModels.count <= index-1) {
        return;
    }
    
    id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index-1];
    if (cellModel && [cellModel isKindOfClass:[MQMessageDateCellModel class]]) {
        [self.cellModels removeObjectAtIndex:index - 1];
        [self.delegate removeCellAtIndex:index - 1];
        index --;
        
    }
    
    if (self.cellModels.count > index) {
        id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
        if (cellModel && [cellModel isKindOfClass:[MQTipsCellModel class]]) {
            [self.cellModels removeObjectAtIndex:index];
            [self.delegate removeCellAtIndex:index];
        }
    }
    
    //重新发送
    if (resendData[@"text"]) {
        [self sendTextMessageWithContent:resendData[@"text"]];
    }
    if (resendData[@"image"]) {
        [self sendImageMessageWithImage:resendData[@"image"]];
    }
    if (resendData[@"voice"]) {
        [self sendVoiceMessageWithAMRFilePath:resendData[@"voice"]];
    }
    if (resendData[@"video"]) {
        [self sendVideoMessageWithFilePath:resendData[@"video"]];
    }
    if (resendData[@"productCard"]) {
        [self sendProductCardWithModel:resendData[@"productCard"]];
    }
}

/**
 * 发送“用户正在输入”的消息
 */
- (void)sendUserInputtingWithContent:(NSString *)content {
    [MQServiceToViewInterface sendClientInputtingWithContent:content];
}

/**
 *  在尾部增加cellModel之前，先判断两个时间间隔是否过大，如果过大，插入一个MessageDateCellModel
 *
 *  @param beAddedCellModel 准备被add的cellModel
 *  @return 是否插入了时间cell
 */
- (BOOL)addMessageDateCellAtLastWithCurrentCellModel:(id<MQCellModelProtocol>)beAddedCellModel {
    id<MQCellModelProtocol> lastCellModel = [self searchOneBussinessCellModelWithIndex:self.cellModels.count-1 isSearchFromBottomToTop:true];
    NSDate *lastDate = lastCellModel ? [lastCellModel getCellDate] : [NSDate date];
    NSDate *beAddedDate = [beAddedCellModel getCellDate];
    //判断被add的cell的时间比最后一个cell的时间是否要大（说明currentCell是第一个业务cell，此时显示时间cell）
    BOOL isLastDateLargerThanNextDate = lastDate.timeIntervalSince1970 > beAddedDate.timeIntervalSince1970;
    //判断被add的cell比最后一个cell的时间间隔是否超过阈值
    BOOL isDateTimeIntervalLargerThanThreshold = beAddedDate.timeIntervalSince1970 - lastDate.timeIntervalSince1970 >= kMQChatMessageMaxTimeInterval;
    if (!isLastDateLargerThanNextDate && !isDateTimeIntervalLargerThanThreshold) {
        return false;
    }
    MQMessageDateCellModel *cellModel = [[MQMessageDateCellModel alloc] initCellModelWithDate:beAddedDate cellWidth:self.chatViewWidth];
    if ([cellModel getCellMessageId].length > 0) {
        [self.cellModels addObject:cellModel];
        [self.delegate insertCellAtBottomForModelCount: 1];
    }
    return true;
}

/**
 *  在首部增加cellModel之前，先判断两个时间间隔是否过大，如果过大，插入一个MessageDateCellModel
 *
 *  @param beInsertedCellModel 准备被insert的cellModel
 *  @return 是否插入了时间cell
 */
- (BOOL)insertMessageDateCellAtFirstWithCellModel:(id<MQCellModelProtocol>)beInsertedCellModel {
    NSDate *firstDate = [NSDate date];
    if (self.cellModels.count == 0) {
        return false;
    }
    id<MQCellModelProtocol> firstCellModel = [self.cellModels objectAtIndex:0];
    if (![firstCellModel isServiceRelatedCell]) {
        return false;
    }
    NSDate *beInsertedDate = [beInsertedCellModel getCellDate];
    firstDate = [firstCellModel getCellDate];
    //判断被insert的Cell的date和第一个cell的date的时间间隔是否超过阈值
    BOOL isDateTimeIntervalLargerThanThreshold = firstDate.timeIntervalSince1970 - beInsertedDate.timeIntervalSince1970 >= kMQChatMessageMaxTimeInterval;
    if (!isDateTimeIntervalLargerThanThreshold) {
        return false;
    }
    MQMessageDateCellModel *cellModel = [[MQMessageDateCellModel alloc] initCellModelWithDate:firstDate cellWidth:self.chatViewWidth];
    [self.cellModels insertObject:cellModel atIndex:0];
    [self.delegate insertCellAtTopForModelCount: 1];
    return true;
}

/**
 *  在尾部增加cellModel之前，先判断两个message 是否是不同会话的，插入一个MQSplitLineCellModel
 *
 *  @param beAddedCellModel 准备被add的cellModel
 *  @return 是否插入
 */
- (BOOL)addConversionSplitLineWithCurrentCellModel:(id<MQCellModelProtocol>)beAddedCellModel {
    if(![MQServiceToViewInterface haveConversation] && beAddedCellModel.getMessageConversionId.length == 0) {
        if (_cellModels.count == 0) {
            return false;
        }
        id<MQCellModelProtocol> lastCellModel;
        bool haveSplit = false;
        for (id<MQCellModelProtocol> cellModel in [_cellModels reverseObjectEnumerator]) {
            if ([cellModel isKindOfClass:[MQSplitLineCellModel class]]) {
                haveSplit = true;
            }
            if ([cellModel getMessageConversionId].length > 0) {
                lastCellModel = cellModel;
                break;
            }
        }
        
        if (lastCellModel && !haveSplit) {
            MQSplitLineCellModel *cellModel = [[MQSplitLineCellModel alloc] initCellModelWithCellWidth:self.chatViewWidth withConversionDate:[beAddedCellModel getCellDate]];
            [self.cellModels addObject:cellModel];
            [self.delegate insertCellAtBottomForModelCount: 1];
            return true;
        }
        return false;
    }
    
    MQSplitLineCellModel *cellModel = [self insertConversionSplitLineWithCellModel:beAddedCellModel withCellModels:_cellModels];
    if (cellModel) {
        [self.cellModels addObject:cellModel];
        [self.delegate insertCellAtBottomForModelCount: 1];
        return true;
    }
    return false;
}

/**
 *  判断是否需要加入不同回话的分割线
 *
 *  @param beInsertedCellModel 准备被insert的cellModel
 */
- (MQSplitLineCellModel *)insertConversionSplitLineWithCellModel:(id<MQCellModelProtocol>)beInsertedCellModel withCellModels:(NSArray *) cellModelArr {
    if (cellModelArr.count == 0) {
        return nil;
    }
    id<MQCellModelProtocol> lastCellModel;
    for (id<MQCellModelProtocol> cellModel in [cellModelArr reverseObjectEnumerator]) {
        if ([cellModel getMessageConversionId].length > 0) {
            lastCellModel = cellModel;
            break;
        }
    }
    if (!lastCellModel) {
        return nil;
    }
    
    if ([beInsertedCellModel getMessageConversionId].length > 0 && ![lastCellModel.getMessageConversionId isEqualToString:beInsertedCellModel.getMessageConversionId]) {
        MQSplitLineCellModel *cellModel1 = [[MQSplitLineCellModel alloc] initCellModelWithCellWidth:self.chatViewWidth withConversionDate:[beInsertedCellModel getCellDate]];
        return cellModel1;
    }
    return nil;
}

/**
 * 从后往前从cellModels中获取到业务相关的cellModel，即text, image, voice等；
 */
/**
 *  从cellModels中搜索第一个业务相关的cellModel，即text, image, voice等；
 *  @warning 业务相关的cellModel，必须满足协议方法isServiceRelatedCell
 *
 *  @param searchIndex             search的起始位置
 *  @param isSearchFromBottomToTop search的方向 YES：从后往前搜索  NO：从前往后搜索
 *
 *  @return 搜索到的第一个业务相关的cellModel
 */
- (id<MQCellModelProtocol>)searchOneBussinessCellModelWithIndex:(NSInteger)searchIndex isSearchFromBottomToTop:(BOOL)isSearchFromBottomToTop{
    if (self.cellModels.count <= searchIndex) {
        return nil;
    }
    id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:searchIndex];
    //判断获取到的cellModel是否是业务相关的cell，如果不是则继续往前取
    if ([cellModel isServiceRelatedCell]){
        return cellModel;
    }
    NSInteger nextSearchIndex = isSearchFromBottomToTop ? searchIndex - 1 : searchIndex + 1;
    [self searchOneBussinessCellModelWithIndex:nextSearchIndex isSearchFromBottomToTop:isSearchFromBottomToTop];
    return nil;
}

/**
 * 通知viewController更新tableView；
 */
- (void)reloadChatTableView {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(reloadChatTableView)]) {
            [self.delegate reloadChatTableView];
        }
    }
}

- (void)scrollToBottom {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(scrollTableViewToBottomAnimated:)]) {
            [self.delegate scrollTableViewToBottomAnimated: NO];
        }
    }
}

#ifndef INCLUDE_MEIQIA_SDK
/**
 * 使用MQChatViewControllerDemo的时候，调试用的方法，用于收取和上一个message一样的消息
 */
- (void)loadLastMessage {
    id<MQCellModelProtocol> lastCellModel = [self searchOneBussinessCellModelWithIndex:self.cellModels.count-1 isSearchFromBottomToTop:true];
    if (lastCellModel) {
        if ([lastCellModel isKindOfClass:[MQTextCellModel class]]) {
            MQTextCellModel *textCellModel = (MQTextCellModel *)lastCellModel;
            MQTextMessage *message = [[MQTextMessage alloc] initWithContent:[textCellModel.cellText string]];
            message.fromType = MQChatMessageIncoming;
            MQTextCellModel *newCellModel = [[MQTextCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
            [self.cellModels addObject:newCellModel];
            [self.delegate insertCellAtBottomForModelCount:1];
            
        } else if ([lastCellModel isKindOfClass:[MQImageCellModel class]]) {
            MQImageCellModel *imageCellModel = (MQImageCellModel *)lastCellModel;
            MQImageMessage *message = [[MQImageMessage alloc] initWithImage:imageCellModel.image];
            message.fromType = MQChatMessageIncoming;
            MQImageCellModel *newCellModel = [[MQImageCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
            [self.cellModels addObject:newCellModel];
            [self.delegate insertCellAtBottomForModelCount:1];
        } else if ([lastCellModel isKindOfClass:[MQVoiceCellModel class]]) {
            MQVoiceCellModel *voiceCellModel = (MQVoiceCellModel *)lastCellModel;
            MQVoiceMessage *message = [[MQVoiceMessage alloc] initWithVoiceData:voiceCellModel.voiceData];
            message.fromType = MQChatMessageIncoming;
            MQVoiceCellModel *newCellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
            [self.cellModels addObject:newCellModel];
            [self.delegate insertCellAtBottomForModelCount:1];
        }
    }
    //text message
    MQTextMessage *textMessage = [[MQTextMessage alloc] initWithContent:@"Let's Rooooooooooock~"];
    textMessage.fromType = MQChatMessageIncoming;
    MQTextCellModel *textCellModel = [[MQTextCellModel alloc] initCellModelWithMessage:textMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:textCellModel];
    [self.delegate insertCellAtBottomForModelCount:1];
    //image message
    MQImageMessage *imageMessage = [[MQImageMessage alloc] initWithImagePath:@"https://s3.cn-north-1.amazonaws.com.cn/pics.meiqia.bucket/65135e4c4fde7b5f"];
    imageMessage.fromType = MQChatMessageIncoming;
    MQImageCellModel *imageCellModel = [[MQImageCellModel alloc] initCellModelWithMessage:imageMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:imageCellModel];
    [self.delegate insertCellAtBottomForModelCount:1];
    //tip message
//        MQTipsCellModel *tipCellModel = [[MQTipsCellModel alloc] initCellModelWithTips:@"主人，您的客服离线啦~" cellWidth:self.cellWidth enableLinesDisplay:true];
//        [self.cellModels addObject:tipCellModel];
    //voice message
    MQVoiceMessage *voiceMessage = [[MQVoiceMessage alloc] initWithVoicePath:@"http://7xiy8i.com1.z0.glb.clouddn.com/test.amr"];
    voiceMessage.fromType = MQChatMessageIncoming;
    MQVoiceCellModel *voiceCellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:voiceMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:voiceCellModel];
    [self.delegate insertCellAtBottomForModelCount:1];
    // bot answer cell
    MQBotAnswerMessage *botAnswerMsg = [[MQBotAnswerMessage alloc] initWithContent:@"这个是一个机器人的回答。" subType:@"" isEvaluated:false];
    botAnswerMsg.fromType = MQChatMessageIncoming;
    MQBotAnswerCellModel *botAnswerCellmodel = [[MQBotAnswerCellModel alloc] initCellModelWithMessage:botAnswerMsg cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:botAnswerCellmodel];
    [self.delegate insertCellAtBottomForModelCount:1];
    // bot menu cell
    MQBotMenuMessage *botMenuMsg = [[MQBotMenuMessage alloc] initWithContent:@"你是不是想问下面这些问题？" menu:@[@"1. 第一个 menu，说点儿什么呢，换个行吧啦啦啦", @"2. 再来一个 menu", @"3. 最后一个 menu"]];
    botMenuMsg.fromType = MQChatMessageIncoming;
    MQBotMenuCellModel *botMenuCellModel = [[MQBotMenuCellModel alloc] initCellModelWithMessage:botMenuMsg cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:botMenuCellModel];
    [self.delegate insertCellAtBottomForModelCount: 1];
    [self playReceivedMessageSound];
}

#endif

#pragma MQCellModelDelegate

- (void)didTapHighMenuWithText:(NSString *)menuText {
    if (menuText && menuText.length > 0) {
        [self sendTextMessageWithContent: menuText];
    }
}

- (void)didUpdateCellDataWithMessageId:(NSString *)messageId {
    //获取又更新的cell的index
    NSInteger index = [self getIndexOfCellWithMessageId:messageId];
    if (index < 0 || index > self.cellModels.count - 1) {
        return;
    }
    [self updateCellWithIndex:index needToBottom:NO];
}

- (NSInteger)getIndexOfCellWithMessageId:(NSString *)messageId {
    for (NSInteger index=0; index<self.cellModels.count; index++) {
        id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
        if ([[cellModel getCellMessageId] isEqualToString:messageId]) {
            //更新该cell
            return index;
        }
    }
    return -1;
}

//通知tableView更新该indexPath的cell
- (void)updateCellWithIndex:(NSInteger)index needToBottom:(BOOL)toBottom {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didUpdateCellModelWithIndexPath:needToBottom:)]) {
            [self.delegate didUpdateCellModelWithIndexPath:indexPath needToBottom:toBottom];
        }
    }
}

#pragma AMR to WAV转换
- (NSData *)convertToWAVDataWithAMRFilePath:(NSString *)amrFilePath {
    NSString *tempPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    tempPath = [tempPath stringByAppendingPathComponent:@"record.wav"];
    [MEIQIA_VoiceConverter amrToWav:amrFilePath wavSavePath:tempPath];
    NSData *wavData = [NSData dataWithContentsOfFile:tempPath];
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
    return wavData;
}

#pragma 更新cellModel中的frame
- (void)updateCellModelsFrame {
    for (id<MQCellModelProtocol> cellModel in self.cellModels) {
        [cellModel updateCellFrameWithCellWidth:self.chatViewWidth];
    }
}

#pragma 欢迎语
- (void)sendLocalWelcomeChatMessage {
    if (![MQChatViewConfig sharedConfig].enableChatWelcome) {
        return ;
    }
    //消息时间
    MQMessageDateCellModel *dateCellModel = [[MQMessageDateCellModel alloc] initCellModelWithDate:[NSDate date] cellWidth:self.chatViewWidth];
    [self.cellModels addObject:dateCellModel];
    [self.delegate insertCellAtBottomForModelCount:1];
    //欢迎消息
    MQTextMessage *welcomeMessage = [[MQTextMessage alloc] initWithContent:[MQChatViewConfig sharedConfig].chatWelcomeText];
    welcomeMessage.fromType = MQChatMessageIncoming;
    welcomeMessage.userName = [MQChatViewConfig sharedConfig].agentName;
    welcomeMessage.userAvatarImage = [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage;
    welcomeMessage.sendStatus = MQChatMessageSendStatusSuccess;
    MQTextCellModel *cellModel = [[MQTextCellModel alloc] initCellModelWithMessage:welcomeMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:cellModel];
    [self.delegate insertCellAtBottomForModelCount: 1];
}

#pragma 点击了某个cell
- (void)didTapMessageCellAtIndex:(NSInteger)index {
    id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
    if ([cellModel isKindOfClass:[MQVoiceCellModel class]]) {
        MQVoiceCellModel *voiceCellModel = (MQVoiceCellModel *)cellModel;
        [voiceCellModel setVoiceHasPlayed];
//        #ifdef INCLUDE_MEIQIA_SDK
//        [MQServiceToViewInterface didTapMessageWithMessageId:[cellModel getCellMessageId]];
//#endif
    }
}

#pragma 讯前表单选择的问题
- (void)selectedFormProblem:(NSString *)content {
    if (content && content.length > 0) {
        [MQServiceToViewInterface setScheduledProblem:content];
    }
}

#pragma 播放声音
- (void)playReceivedMessageSound {
    if (![MQChatViewConfig sharedConfig].enableMessageSound || [MQChatViewConfig sharedConfig].incomingMsgSoundFileName.length == 0) {
        return;
    }
    [MQChatFileUtil playSoundWithSoundFile:[MQAssetUtil resourceWithName:[MQChatViewConfig sharedConfig].incomingMsgSoundFileName]];
}

- (void)playSendedMessageSound {
    if (![MQChatViewConfig sharedConfig].enableMessageSound || [MQChatViewConfig sharedConfig].outgoingMsgSoundFileName.length == 0) {
        return;
    }
    [MQChatFileUtil playSoundWithSoundFile:[MQAssetUtil resourceWithName:[MQChatViewConfig sharedConfig].outgoingMsgSoundFileName]];
}

#pragma mark - create model
- (id<MQCellModelProtocol>)createCellModelWith:(MQBaseMessage *)message {
    id<MQCellModelProtocol> cellModel = nil;
    if (![message isKindOfClass:[MQEventMessage class]]) {
        if ([message isKindOfClass:[MQTextMessage class]]) {
            cellModel = [[MQTextCellModel alloc] initCellModelWithMessage:(MQTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQImageMessage class]]) {
            cellModel = [[MQImageCellModel alloc] initCellModelWithMessage:(MQImageMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQVoiceMessage class]]) {
            cellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:(MQVoiceMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQVideoMessage class]]) {
            cellModel = [[MQVideoCellModel alloc] initCellModelWithMessage:(MQVideoMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQFileDownloadMessage class]]) {
            cellModel = [[MQFileDownloadCellModel alloc] initCellModelWithMessage:(MQFileDownloadMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQRichTextMessage class]]) {
            
            if ([message isKindOfClass:[MQBotRichTextMessage class]]) {
                if ([(MQBotRichTextMessage *)message menu] != nil) {
                    if ([[(MQBotRichTextMessage *)message subType] isEqualToString:@"evaluate"]) {
                        MQBotMenuWebViewBubbleAnswerCellModel *cellModel = [[MQBotMenuWebViewBubbleAnswerCellModel alloc] initCellModelWithMessage:(MQBotRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                        cellModel.needShowFeedback = [MQServiceToViewInterface enableBotEvaluateFeedback];
                        return cellModel;
                    }
                } else {
                    if ([[(MQBotRichTextMessage *)message subType] isEqualToString:@"evaluate"]) {
                        MQBotWebViewBubbleAnswerCellModel *cellModel = [[MQBotWebViewBubbleAnswerCellModel alloc] initCellModelWithMessage:(MQBotRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                        cellModel.needShowFeedback = [MQServiceToViewInterface enableBotEvaluateFeedback];
                        return cellModel;
                    }
                }
            }
            // 原富文本模型用webviewBubble代替
            cellModel = [[MQWebViewBubbleCellModel alloc] initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
            
        } else if ([message isKindOfClass:[MQBotAnswerMessage class]]) {
            
            if ([(MQBotAnswerMessage *)message menu] == nil) {
                cellModel = [[MQBotAnswerCellModel alloc] initCellModelWithMessage:(MQBotAnswerMessage *)message cellWidth:self.chatViewWidth delegate:self];
            } else {
                cellModel = [[MQBotMenuAnswerCellModel alloc] initCellModelWithMessage:(MQBotAnswerMessage *)message cellWidth:self.chatViewWidth delegate:self];
            }
        } else if ([message isKindOfClass:[MQBotMenuMessage class]]) {
//            cellModel = [[MQBotMenuRichCellModel alloc] initCellModelWithMessage:(MQBotMenuMessage *)message cellWidth:self.chatViewWidth delegate:self];
            
            cellModel = [[MQBotMenuCellModel alloc] initCellModelWithMessage:(MQBotMenuMessage *)message cellWidth:self.chatViewWidth delegate:self];
            
        } else if ([message isKindOfClass:[MQBotHighMenuMessage class]]) {
            NSString *richText = [(MQBotHighMenuMessage *)message richContent];
            if (richText.length > 0) {
                cellModel = [[MQBotHighMenuRichCellModel alloc] initCellModelWithMessage:(MQBotHighMenuMessage *)message cellWidth:self.chatViewWidth delegate:self];
            }else {
                cellModel = [[MQBotHighMenuCellModel alloc] initCellModelWithMessage:(MQBotHighMenuMessage *)message cellWidth:self.chatViewWidth delegate:self];
            }
        } else if ([message isKindOfClass:[MQBotGuideMessage class]]) {
            cellModel = [[MQBotGuideCellModel alloc] initCellModelWithMessage:(MQBotGuideMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQCardMessage class]]) {
            cellModel = [[MQCardCellModel alloc] initCellModelWithMessage:(MQCardMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQWithDrawMessage class]]) {
            // 消息撤回
            MQWithDrawMessage *withDrawMessage = (MQWithDrawMessage *)message;
            cellModel = [[MQTipsCellModel alloc] initCellModelWithTips:withDrawMessage.content cellWidth:self.chatViewWidth enableLinesDisplay:NO];
        } else if ([message isKindOfClass:[MQPhotoCardMessage class]]) {
            cellModel = [[MQPhotoCardCellModel alloc] initCellModelWithMessage:(MQPhotoCardMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQProductCardMessage class]]) {
            cellModel = [[MQProductCardCellModel alloc] initCellModelWithMessage:(MQProductCardMessage *)message cellWidth:self.chatViewWidth delegate:self];
        }
    }
    return cellModel;
}

#pragma mark - 消息保存到cellmodel中
/**
 *  将消息数组中的消息转换成cellModel，并添加到cellModels中去;
 *
 *  @param newMessages             消息实体array
 *  @param isInsertAtFirstIndex 是否将messages插入到顶部
 *
 *  @return 返回转换为cell的个数
 */
- (NSInteger)saveToCellModelsWithMessages:(NSArray *)newMessages isInsertAtFirstIndex:(BOOL)isInsertAtFirstIndex {
    
    NSMutableArray *newCellModels = [NSMutableArray new];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [MQServiceToViewInterface updateMessageIds:[newMessages valueForKey:@"messageId"] toReadStatus:YES];
    });
    
    // 1. 如果相同 messaeg Id 的 cell model 存在，则替换，否则追加
    for (MQBaseMessage *message in newMessages) {
        id<MQCellModelProtocol> newCellModel = [self createCellModelWith:message];
        
        if (!newCellModel) { // EventMessage 不会生成 cell model
            continue;
        }
        
//        // 如果富文本为空，不显示
//        if ([newCellModel isKindOfClass:[MQWebViewBubbleCellModel class]]) {
//            MQRichTextMessage *richMessage = (MQRichTextMessage *)message;
//            if ([richMessage.content isEqual:[NSNull null]] || richMessage.content.length == 0) {
//                NSLog(@"--- 空的富文本");
//                continue;
//            }
//        }
        
         NSArray *redundentCellModels = [self.cellModels filter:^BOOL(id<MQCellModelProtocol> cellModel) {
            return [[cellModel getCellMessageId] isEqualToString:[newCellModel getCellMessageId]];
         }];
        
        if ([redundentCellModels count] > 0) {
            [self.cellModels replaceObjectAtIndex:[self.cellModels indexOfObject:[redundentCellModels firstObject]] withObject:newCellModel];
        } else {
            MQSplitLineCellModel *splitLineCellModel = [self insertConversionSplitLineWithCellModel:newCellModel withCellModels:newCellModels];
            if (splitLineCellModel) {
                [newCellModels addObject:splitLineCellModel];
            }
            [newCellModels addObject:newCellModel];
        }
    }
    
    // 2. 计算新的 cell model 在列表中的位置
    NSMutableSet *positionVector = [NSMutableSet new]; // 计算位置的辅助容器，如果所有消息都为 0，放在底部，都为 1，放在顶部，两者都有，则需要重新排序。
    NSDate *firstMessageDate = [self.cellModels.firstObject getCellDate];
    NSDate *lastMessageDate = [self.cellModels.lastObject getCellDate];
    [newCellModels enumerateObjectsUsingBlock:^(id<MQCellModelProtocol> newCellModel, NSUInteger idx, BOOL * stop) {
        if (![newCellModel isKindOfClass:[MQSplitLineCellModel class]]) {
            if ([firstMessageDate compare:[newCellModel getCellDate]] == NSOrderedDescending) {
                [positionVector addObject:@"1"];
            } else if ([lastMessageDate compare:[newCellModel getCellDate]] == NSOrderedAscending) {
                [positionVector addObject:@"0"];
            }
        }
    }];
    
    if (positionVector.count > 1) {
        positionVector = [[NSMutableSet alloc] initWithObjects:@"2", nil];
    }
    
    __block NSUInteger position = 0; // 0: bottom, 1: top, 2: random
    
    [positionVector enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        position = [obj intValue];
    }];
    
    if (newCellModels.count == 0) { return 0; }
    // 判断是否需要添加分割线
    if (position == 1) {
        id <MQCellModelProtocol> currentFirstCellModel;
        for (id<MQCellModelProtocol> cellModel in self.cellModels) {
            if ([cellModel getMessageConversionId].length > 0) {
                currentFirstCellModel = cellModel;
                break;
            }
        }
        if (!currentFirstCellModel) {
            MQSplitLineCellModel *splitLineCellModel = [self insertConversionSplitLineWithCellModel:currentFirstCellModel withCellModels:newCellModels];
            if (splitLineCellModel) {
                [newCellModels addObject:splitLineCellModel];
            }
        }
    } else if (position == 0) {
        MQSplitLineCellModel *splitLineCellModel = [self insertConversionSplitLineWithCellModel:[newCellModels firstObject] withCellModels:self.cellModels];
        if (splitLineCellModel) {
            [newCellModels insertObject:splitLineCellModel atIndex:0];
        }
    }
    NSUInteger newMessageCount = newCellModels.count;
    switch (position) {
        case 1: // top
            [self insertMessageDateCellAtFirstWithCellModel:[newCellModels firstObject]]; // 如果需要，顶部插入时间
            self.cellModels = [[newCellModels arrayByAddingObjectsFromArray:self.cellModels] mutableCopy];
            break;
        case 0: // bottom
            [self addMessageDateCellAtLastWithCurrentCellModel:[newCellModels firstObject]];// 如果需要，底部插入时间
            [self.cellModels addObjectsFromArray:newCellModels];
            break;
        default:
            [self.cellModels addObjectsFromArray:newCellModels];// 退出后会被重新排序，这种情况只可能出现在聊天过程中 socket 断开后，轮询后台消息，会比自己发的消息早，但是应该放到前面。
            break;
    }
    
    return newMessageCount;
}

/**
 *  发送用户评价
 */
- (void)sendEvaluationLevel:(NSInteger)level comment:(NSString *)comment {
    //生成评价结果的 cell
    MQEvaluationType levelType = MQEvaluationTypePositive;
    switch (level) {
        case 0:
            levelType = MQEvaluationTypeNegative;
            break;
        case 1:
            levelType = MQEvaluationTypeModerate;
            break;
        case 2:
            levelType = MQEvaluationTypePositive;
            break;
        default:
            break;
    }
    [self showEvaluationCellWithLevel:levelType comment:comment];
#ifdef INCLUDE_MEIQIA_SDK
    [MQServiceToViewInterface setEvaluationLevel:level comment:comment];
#endif
}

//显示用户评价的 cell
- (void)showEvaluationCellWithLevel:(MQEvaluationType)level comment:(NSString *)comment{
    MQEvaluationResultCellModel *cellModel = [[MQEvaluationResultCellModel alloc] initCellModelWithEvaluation:level comment:comment cellWidth:self.chatViewWidth];
    [self.cellModels addObject:cellModel];
    [self.delegate insertCellAtBottomForModelCount: 1];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(scrollTableViewToBottomAnimated:)]) {
            [self.delegate scrollTableViewToBottomAnimated: YES];
        }
    }
}

- (void)addTipCellModelWithTips:(NSString *)tips enableLinesDisplay:(BOOL)enableLinesDisplay {
    MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initCellModelWithTips:tips cellWidth:self.chatViewWidth enableLinesDisplay:enableLinesDisplay];
    [self.cellModels addObject:cellModel];
    [self.delegate insertCellAtBottomForModelCount: 1];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(scrollTableViewToBottomAnimated:)]) {
            [self.delegate scrollTableViewToBottomAnimated: YES];
        }
    }
}

// 增加留言提示的 cell model
- (void)addTipCellModelWithType:(MQTipType)tipType {
    // 判断当前是否是机器人客服
    if ([MQServiceToViewInterface getCurrentAgent].privilege != MQAgentPrivilegeBot) {
        return;
    }
    // 判断 table 中是否出现「转人工」或「留言」，如果出现过，并不在最后一个 cell，则将之移到底部
    MQTipsCellModel *tipModel = nil;
    if (tipType == MQTipTypeReply || tipType == MQTipTypeBotRedirect || tipType == MQTipTypeBotManualRedirect) {
        for (id<MQCellModelProtocol> model in self.cellModels) {
            if ([model isKindOfClass:[MQTipsCellModel class]]) {
                MQTipsCellModel *cellModel = (MQTipsCellModel *)model;
                if (cellModel.tipType == tipType) {
                    tipModel = cellModel;
                    break;
                }
            }
        }
    }
    if (tipModel) {
        // 将目标 model 移到最底部
        [self.cellModels removeObject:tipModel];
        [self.cellModels addObject:tipModel];
        [self.delegate reloadChatTableView];
    } else {
        MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initBotTipCellModelWithCellWidth:self.chatViewWidth tipType:tipType showLeaveCommentBtn:[MQServiceToViewInterface enableLeaveComment]];
        [self.cellModels addObject:cellModel];
        [self.delegate insertCellAtBottomForModelCount: 1];
    }
    [self scrollToBottom];
}

// 清除当前界面的「转人工」「留言」的 tipCell
- (void)removeBotTipCellModels {
    NSMutableArray *newCellModels = [NSMutableArray new];
    for (id<MQCellModelProtocol> model in self.cellModels) {
        if ([model isKindOfClass:[MQTipsCellModel class]]) {
            MQTipsCellModel *cellModel = (MQTipsCellModel *)model;
            if (cellModel.tipType == MQTipTypeReply || cellModel.tipType == MQTipTypeBotRedirect || cellModel.tipType == MQTipTypeBotManualRedirect) {
                continue;
            }
        }
        [newCellModels addObject:model];
    }
    self.cellModels = newCellModels;
}

- (void)addWaitingInQueueTipWithPosition:(int)position {
    [MQServiceToViewInterface getEnterpriseConfigInfoWithCache:YES complete:^(MQEnterprise *enterPrise, NSError *error) {
        if (enterPrise.configInfo.queueStatus) {
            [self removeWaitingInQueueCellModels];
            [self reloadChatTableView];
            MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initWaitingInQueueTipCellModelWithCellWidth:self.chatViewWidth withIntro:enterPrise.configInfo.queueIntro ticketIntro:enterPrise.configInfo.queueTicketIntro position:position tipType:MQTipTypeWaitingInQueue showLeaveCommentBtn:[MQServiceToViewInterface enableLeaveComment]];
            [self.cellModels addObject:cellModel];
            [self.delegate insertCellAtBottomForModelCount: 1];
            [self scrollToBottom];
        }
    }];
}

// 更新排队位置
- (void)updateWaitingInQueueTipWithPosition:(int)position {
    for (id<MQCellModelProtocol> model in [self.cellModels reverseObjectEnumerator]) {
        if ([model isKindOfClass:[MQTipsCellModel class]]) {
            MQTipsCellModel *cellModel = (MQTipsCellModel *)model;
            if (cellModel.tipType == MQTipTypeWaitingInQueue && position != [cellModel getCurrentQueuePosition]) {
                [cellModel updateQueueTipPosition:position];
                [self reloadChatTableView];
                return;
            }
        }
    }
}

/// 清除当前界面的排队中「留言」的 tipCell
- (void)removeWaitingInQueueCellModels {
    NSMutableArray *newCellModels = [NSMutableArray new];
    for (id<MQCellModelProtocol> model in self.cellModels) {
        if ([model isKindOfClass:[MQTipsCellModel class]]) {
            MQTipsCellModel *cellModel = (MQTipsCellModel *)model;
            if (cellModel.tipType == MQTipTypeWaitingInQueue) {
                continue;
            }
        }
        [newCellModels addObject:model];
    }
    self.cellModels = newCellModels;
}

#ifdef INCLUDE_MEIQIA_SDK

#pragma mark - 顾客上线的逻辑
//上线
- (void)setClientOnline {
    if (self.clientStatus == MQStateAllocatingAgent) {
        return;
    }
    // [MQChatViewConfig sharedConfig].scheduleRule 默认为0，不限制分配规则
    [MQServiceToViewInterface setScheduledAgentWithAgentId:[MQChatViewConfig sharedConfig].scheduledAgentId agentGroupId:[MQChatViewConfig sharedConfig].scheduledGroupId scheduleRule:[MQChatViewConfig sharedConfig].scheduleRule];
    
    if ([MQChatViewConfig sharedConfig].MQClientId.length == 0 && [MQChatViewConfig sharedConfig].customizedId.length > 0) {
        [self onlineWithCustomizedId];
    } else {
        [self onlineWithClientId];
    }
    
//    // 每次上线，手动刷新一次等待提醒
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self checkAndUpdateWaitingQueueStatus];
//    });

}

// 连接客服上线
- (void)onlineWithClientId {
    __weak typeof(self) weakSelf = self;
    NSDate *msgDate = [NSDate date];

    [self.serviceToViewInterface setClientOnlineWithClientId:[MQChatViewConfig sharedConfig].MQClientId success:^(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if ([error reason].length == 0) {
            [strongSelf removeScheduledAgentWithType:agentType];
            if (receivedMessages.count <= 0) {
                [MQManager getDatabaseHistoryMessagesWithMsgDate:msgDate messagesNumber:0 result:^(NSArray<MQMessage *> *messagesArray) {
                    NSArray *toMessages = [strongSelf convertToChatViewMessageWithMQMessages:messagesArray];
                    [strongSelf handleClientOnlineWithRreceivedMessages:toMessages completeStatus:completion];
                }];
            }else{
                [strongSelf handleClientOnlineWithRreceivedMessages:receivedMessages completeStatus:completion];
            }
        } else {
            [MQToast showToast:[error shortDescription] duration:2.0 window:[[UIApplication sharedApplication].windows lastObject]];
        }
    } receiveMessageDelegate:self];
}

- (void)removeScheduledAgentWithType:(NSString *)agentType {
    if (![agentType isEqualToString:@"bot"]) {
        [MQServiceToViewInterface deleteScheduledAgent];
    }
}

#pragma mark - message转为UI类型
- (NSArray *)convertToChatViewMessageWithMQMessages:(NSArray *)messagesArray {
    //将MQMessage转换成UI能用的Message类型
    NSMutableArray *toMessages = [[NSMutableArray alloc] init];
    for (MQMessage *fromMessage in messagesArray) {
        // 这里加要单独处理欢迎语头像处理问题
        if (fromMessage.type == MQMessageTypeWelcome && [fromMessage.agentId intValue] == 0 && fromMessage.messageAvatar.length < 1) {
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


- (void)onlineWithCustomizedId {
    __weak typeof(self) weakSelf = self;
    NSDate *msgDate = [NSDate date];

    [self.serviceToViewInterface setClientOnlineWithCustomizedId:[MQChatViewConfig sharedConfig].customizedId success:^(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if ([error reason].length == 0) {
            [strongSelf removeScheduledAgentWithType:agentType];
            if (receivedMessages.count <= 0) {
                [MQManager getDatabaseHistoryMessagesWithMsgDate:msgDate messagesNumber:0 result:^(NSArray<MQMessage *> *messagesArray) {
                    NSArray *toMessages = [strongSelf convertToChatViewMessageWithMQMessages:messagesArray];
                    [strongSelf handleClientOnlineWithRreceivedMessages:toMessages completeStatus:completion];
                }];
            }else{
                [strongSelf handleClientOnlineWithRreceivedMessages:receivedMessages completeStatus:completion];
            }
        } else {
            [MQToast showToast:[error shortDescription] duration:2.5 window:[[UIApplication sharedApplication].windows lastObject]];
        }    } receiveMessageDelegate:self];
}

- (void)handleClientOnlineWithRreceivedMessages:(NSArray *)receivedMessages
                         completeStatus:(BOOL)completion
{
    if (receivedMessages) {
        NSInteger newCellCount = [self saveToCellModelsWithMessages:receivedMessages isInsertAtFirstIndex: NO];
        [UIView setAnimationsEnabled:NO];
        [self.delegate insertCellAtTopForModelCount: newCellCount];
        [self scrollToBottom];
        [UIView setAnimationsEnabled:YES];
        // 判断是否有需要移除的营销机器人引导按钮
        [self checkNeedRemoveBotGuideMessageWithForceReload: YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollToBottom]; // some image may lead the table didn't reach bottom
        });
    }
    
    [self afterClientOnline];
}

- (void)afterClientOnline {
    __weak typeof(self) wself = self;
    //上传顾客信息
    [self setCurrentClientInfoWithCompletion:^(BOOL success) {
        //获取顾客信息
        __strong typeof (wself) sself = wself;
        [sself getClientInfo];
    }];
    
    [self sendPreSendMessages];
    
    int position = [MQServiceToViewInterface waitingInQueuePosition];
    if (position > 0) {
        [self addWaitingInQueueTipWithPosition:position];
        MQInfo(@"now you are at %d in waiting queue", position);
    }
    
    NSError * error = [MQServiceToViewInterface checkGlobalError];
    if (error) {
        if (error.code == MQErrorCodeBotFailToRedirectToHuman) {
            [self addTipCellModelWithType:MQTipTypeReply];
        }
    }
    
    [MQServiceToViewInterface getEnterpriseConfigInfoWithCache:YES complete:^(MQEnterprise *enterprise, NSError *e) {
        [MQCustomizedUIText setCustomiedTextForKey:(MQUITextKeyNoAgentTip) text:enterprise.configInfo.ticketConfigInfo.intro];
    }];
}

- (void)checkAndUpdateWaitingQueueStatus {
    //如果之前在排队中，则继续查询
    if ([MQServiceToViewInterface waitingInQueuePosition] > 0) {
        MQInfo(@"check wating queue position")
        [MQServiceToViewInterface getClientQueuePositionComplete:^(NSInteger position, NSError *error) {
            if (position > 0) {
                [self updateWaitingInQueueTipWithPosition:(int)position];
                MQInfo(@"now you are at %d in waiting queue", (int)position);
            } else {
                [self removeWaitingInQueueCellModels];
                [self removeBotTipCellModels];
                [self reloadChatTableView];
            }
        }];
    } else {
        [self removeBotTipCellModels];
        [self removeWaitingInQueueCellModels];
        [self reloadChatTableView];
        [self.positionCheckTimer invalidate];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendPreSendMessages];
        });
    }
}

/**
 * 判断是否需要动态的移除营销机器人的消息
 * @param forceReload 是否需要强制刷新UI
 */
- (void)checkNeedRemoveBotGuideMessageWithForceReload:(BOOL)forceReload {
    // 专门处理营销机器人的引导语需要动态删除的需求
    id<MQCellModelProtocol> lastCellModel = [self.cellModels lastObject];
    NSArray *tempCellModels = [self.cellModels copy];
    BOOL needRemoveMessage = NO;
    for (id<MQCellModelProtocol> tempModel in tempCellModels) {
        if ([tempModel isKindOfClass:[MQBotGuideCellModel class]]) {
            if (tempModel != lastCellModel) {
                [self.cellModels removeObject:tempModel];
                needRemoveMessage = true;
            } else {
                if (![[tempModel getMessageConversionId] isEqualToString:[MQServiceToViewInterface getCurrentConversationID]]) {
                    [self.cellModels removeObject:tempModel];
                    needRemoveMessage = true;
                }
            }
        }
    }
    
    if (needRemoveMessage || forceReload) {
       [self reloadChatTableView];
    }
}


#define kSaveTextDraftIfNeeded @"kSaveTextDraftIfNeeded"
- (void)saveTextDraftIfNeeded:(UITextField *)tf {
    if (tf.text.length) {
        [[NSUserDefaults standardUserDefaults]setObject:tf.text forKey:kSaveTextDraftIfNeeded];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

- (void)fillTextDraftToFiledIfExists:(UITextField *)tf {
    NSString *string = [[NSUserDefaults standardUserDefaults]objectForKey:kSaveTextDraftIfNeeded];
    if (string.length) {
        tf.text = string;
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:kSaveTextDraftIfNeeded];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

- (void)sendPreSendMessages {
//    if ([MQServiceToViewInterface getCurrentAgentStatus] == MQChatAgentStatusOnDuty) {
        for (id messageContent in [MQChatViewConfig sharedConfig].preSendMessages) {
            if ([messageContent isKindOfClass:NSString.class]) {
                [self sendTextMessageWithContent:messageContent];
            } else if ([messageContent isKindOfClass:UIImage.class]) {
                [self sendImageMessageWithImage:messageContent];
            } else if ([messageContent isKindOfClass:MQProductCardMessage.class]) {
                [self sendProductCardWithModel:messageContent];
            }
        }
        
        [MQChatViewConfig sharedConfig].preSendMessages = nil;
//    }
}

//获取顾客信息
- (void)getClientInfo {
    NSDictionary *localClientInfo = [MQChatViewConfig sharedConfig].clientInfo;
    NSDictionary *remoteClientInfo = [MQServiceToViewInterface getCurrentClientInfo];
    NSString *avatarPath = [localClientInfo objectForKey:@"avatar"];
    if ([avatarPath length] == 0) {
        avatarPath = remoteClientInfo[@"avatar"];
        if (avatarPath.length == 0) {
            return;
        }
    }
    
    [MQServiceToViewInterface downloadMediaWithUrlString:avatarPath progress:nil completion:^(NSData *mediaData, NSError *error) {
        if (mediaData) {
            [MQChatViewConfig sharedConfig].outgoingDefaultAvatarImage = [UIImage imageWithData:mediaData];
            [self refreshOutgoingAvatarWithImage:[MQChatViewConfig sharedConfig].outgoingDefaultAvatarImage];
        }
    }];
}

//上传顾客信息
- (void)setCurrentClientInfoWithCompletion:(void (^)(BOOL success))completion
{
    //1. 如果用户自定义了头像，上传
    //2. 上传用户的其他自定义信息
    [self setClientAvartarIfNeededComplete:^{
        if ([MQChatViewConfig sharedConfig].clientInfo) {
            [MQServiceToViewInterface setClientInfoWithDictionary:[MQChatViewConfig sharedConfig].clientInfo completion:^(BOOL success, NSError *error) {
                completion(success);
            }];
        } else {
            completion(true);
        }
    }];
}

- (void)setClientAvartarIfNeededComplete:(void(^)(void))completion {
    if ([MQChatViewConfig sharedConfig].shouldUploadOutgoingAvartar) {
        [MQServiceToViewInterface uploadClientAvatar:[MQChatViewConfig sharedConfig].outgoingDefaultAvatarImage completion:^(NSString *avatarUrl, NSError *error) {
            NSMutableDictionary *userInfo = [[MQChatViewConfig sharedConfig].clientInfo mutableCopy];
            if (!userInfo) {
                userInfo = [NSMutableDictionary new];
            }
            [userInfo setObject:avatarUrl forKey:@"avatar"];
            [MQChatViewConfig sharedConfig].shouldUploadOutgoingAvartar = NO;
            completion();
        }];
    } else {
        completion();
    }
}


- (void)updateChatTitleWithAgent:(MQAgent *)agent state:(MQState)state {
    MQChatAgentStatus agentStatus = [self getAgentStatus:agent];
    NSString *viewTitle = @"";
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didScheduleClientWithViewTitle:agentStatus:)]) {
            switch (state) {
                case MQStateAllocatingAgent:
                    viewTitle = [MQBundleUtil localizedStringForKey:@"wait_agent"];
                    agentStatus = MQChatAgentStatusNone;
                    break;
                case MQStateUnallocatedAgent:
                case MQStateBlacklisted:
                case MQStateOffline:
                    viewTitle = [MQBundleUtil localizedStringForKey:@"no_agent_title"];
                    agentStatus = MQChatAgentStatusNone;
                    break;
                case MQStateQueueing:
                    viewTitle = [MQBundleUtil localizedStringForKey:@"waiting_title"];;
                    agentStatus = MQChatAgentStatusNone;
                    break;
                case MQStateAllocatedAgent:
                    viewTitle = agent.nickname;
                    break;
                case MQStateInitialized:
                case MQStateUninitialized:
                    viewTitle = [MQBundleUtil localizedStringForKey:@"wait_agent"];
                    agentStatus = MQChatAgentStatusNone;
                    break;
            }
            
            [self.delegate didScheduleClientWithViewTitle:viewTitle agentStatus:agentStatus];
        }
        
        if ([self.delegate respondsToSelector:@selector(changeNavReightBtnWithAgentType:hidden:)]) {
            NSString *agentType = @"";
            switch (agent.privilege) {
                case MQAgentPrivilegeAdmin:
                    agentType = @"admin";
                    break;
                case MQAgentPrivilegeAgent:
                    agentType = @"agent";
                    break;
                case MQAgentPrivilegeBot:
                    agentType = @"bot";
                    break;
                case MQAgentPrivilegeNone:
                    agentType = @"";
                    break;
                default:
                    break;
            }
            
            [self.delegate changeNavReightBtnWithAgentType:agentType hidden:(state != MQStateAllocatedAgent)];
        }
    }
}

- (MQChatAgentStatus)getAgentStatus:(MQAgent *)agent {
    if (!agent.isOnline) {
        return MQChatAgentStatusOffLine;
    }
    
    if (agent.privilege == MQAgentPrivilegeBot) {
        return MQChatAgentStatusOnDuty;
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

- (void)addNoAgentTip {
    if (!self.noAgentTipShowed && ![MQServiceToViewInterface isBlacklisted] && [MQServiceToViewInterface waitingInQueuePosition] == 0) {
        self.noAgentTipShowed = YES;
        [self addTipCellModelWithTips:[MQBundleUtil localizedStringForKey:@"no_agent_tips"] enableLinesDisplay:true];
    }
}

- (BOOL)haveSendMessage {
    for (id<MQCellModelProtocol> cellModel in [self.cellModels reverseObjectEnumerator]) {
        if (!([MQServiceToViewInterface getCurrentConversationID] && [[cellModel getMessageConversionId] isEqualToString:[MQServiceToViewInterface getCurrentConversationID]])) {
            return NO;
        }
        if ([cellModel isKindOfClass:[MQTextCellModel class]] || [cellModel isKindOfClass:[MQVoiceCellModel class]] || [cellModel isKindOfClass:[MQVideoCellModel class]] || [cellModel isKindOfClass:[MQImageCellModel class]] || [cellModel isKindOfClass:[MQProductCardCellModel class]]) {
            BOOL status = (MQChatCellFromType)[cellModel performSelector:@selector(cellFromType)] == MQChatCellOutgoing;
            if (status) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - MQServiceToViewInterfaceDelegate

// 进入页面从服务器或者数据库获取历史消息
- (void)didReceiveHistoryMessages:(NSArray *)messages {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didGetHistoryMessagesWithCommitTableAdjustment:)]) {
            __weak typeof(self) wself = self;
            [self.delegate didGetHistoryMessagesWithCommitTableAdjustment:^{
                __strong typeof (wself) sself = wself;
                if (messages.count > 0) {
                    [sself saveToCellModelsWithMessages:messages isInsertAtFirstIndex:true];
                    // 判断是否有需要移除的营销机器人引导按钮
                    [sself checkNeedRemoveBotGuideMessageWithForceReload: YES];
                }
            }];
        }
    }
}

// 分配客服成功
- (void)didScheduleResult:(MQClientOnlineResult) onLineResult withResultMessages:(NSArray<MQMessage *> *)message {
    
    if ([self.delegate respondsToSelector:@selector(needToDisplayLeaveComment:)]) {
        [self.delegate needToDisplayLeaveComment:onLineResult == MQClientOnlineResultNotScheduledAgent && [MQServiceToViewInterface waitingInQueuePosition] < 1 && ![MQServiceToViewInterface enableLeaveComment]];
    }
    
    // 让UI显示历史消息成功了再发送
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.cacheTextArr.count > 0) {
            for (NSString *text in self.cacheTextArr) {
                [self sendTextMessageWithContent:text];
            }
            [self.cacheTextArr removeAllObjects];
        }
        
        if (self.cacheImageArr.count > 0) {
            for (UIImage *image in self.cacheImageArr) {
                [self sendImageMessageWithImage:image];
            }
            [self.cacheImageArr removeAllObjects];
        }
        
        if (self.cacheFilePathArr.count > 0) {
            for (NSString *path in self.cacheFilePathArr) {
                [self sendVoiceMessageWithAMRFilePath:path];
            }
            [self.cacheFilePathArr removeAllObjects];
        }
        
        if (self.cacheVideoPathArr.count > 0) {
            for (NSString *path in self.cacheVideoPathArr) {
                [self sendVideoMessageWithFilePath:path];
            }
            [self.cacheVideoPathArr removeAllObjects];
        }
    });
    
}

#pragma mark - handle message
- (void)handleEventMessage:(MQEventMessage *)eventMessage {
    // 撤回消息 
    if (eventMessage.eventType == MQChatEventTypeWithdrawMsg) {
        [self.cellModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id<MQCellModelProtocol> cellModel = obj;
            NSString *cellMessageId =  [cellModel getCellMessageId];
            if (cellMessageId && cellMessageId.integerValue == eventMessage.messageId.integerValue) {
                [MQManager updateMessageWithDrawWithId:cellMessageId withIsWithDraw:YES];
                [self.cellModels removeObjectAtIndex:idx];
                [self.delegate removeCellAtIndex:idx];
                
                if ([MQServiceToViewInterface getEnterpriseConfigWithdrawToastStatus]) {
                    MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initCellModelWithTips:@"客服撤回了一条消息" cellWidth:self.chatViewWidth enableLinesDisplay:NO];
                    [self.cellModels insertObject:cellModel atIndex:idx];
                    [self.delegate insertCellAtCurrentIndex:idx modelCount:1];
                }
            }

        }];
        
    }
    NSString *tipString = eventMessage.tipString;
    if (tipString.length > 0) {
        if ([self respondsToSelector:@selector(didReceiveTipsContent:)]) {
            [self didReceiveTipsContent:tipString showLines:NO];
        }
    }
    
    // 客服邀请评价、客服主动结束会话
    if (eventMessage.eventType == MQChatEventTypeInviteEvaluation) {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(showEvaluationAlertView)] && [self.delegate respondsToSelector:@selector(isChatRecording)]) {
                if (![self.delegate isChatRecording]) {
                    [self.delegate showEvaluationAlertView];
                }
            }
        }
    }
}

- (void)handleVisualMessages:(NSArray *)messages {
    NSInteger newCellCount = [self saveToCellModelsWithMessages:messages isInsertAtFirstIndex:false];
    [self playReceivedMessageSound];
    BOOL needsResort = NO;

    // find earliest message
    MQBaseMessage *earliest = [messages reduce:[messages firstObject] step:^id(MQBaseMessage *current, MQBaseMessage *element) {
        return [[earliest date] compare:[element date]] == NSOrderedDescending ? element : current;
    }];
    
    if ([[earliest date] compare:[[self.cellModels lastObject] getCellDate]] == NSOrderedAscending) {
        needsResort = YES;
    }
    
    if (needsResort) {
        [self.cellModels sortUsingComparator:^NSComparisonResult(id<MQCellModelProtocol>  _Nonnull obj1,  id<MQCellModelProtocol> _Nonnull obj2) {
            return [[obj1 getCellDate] compare:[obj2 getCellDate]];
        }];
    }
    [self.delegate insertCellAtBottomForModelCount:newCellCount];
}

- (void)onceLoadHistoryAndRefreshWithSendMsg:(NSString *)message{
//    [self afterClientOnline];
    [self sendTextMessageWithContent:message];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDate *msgDate = [NSDate date];
        [MQManager getDatabaseHistoryMessagesWithMsgDate:msgDate messagesNumber:0 result:^(NSArray<MQMessage *> *messagesArray) {
            if (self.cellModels) {
                [self.cellModels removeAllObjects];
            }
            NSArray *receivedMessages = [self convertToChatViewMessageWithMQMessages:messagesArray];
            if (receivedMessages) {
                [self saveToCellModelsWithMessages:receivedMessages isInsertAtFirstIndex: NO];
                // 判断是否有需要移除的营销机器人引导按钮
                [self checkNeedRemoveBotGuideMessageWithForceReload: YES];
                
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [self scrollToBottom];
//                });
            }
            
        }];
    });

}

#pragma mark - viewInface delegate

- (void)didReceiveNewMessages:(NSArray *)messages {
    if (messages.count == 1 && [[messages firstObject] isKindOfClass:[MQEventMessage class]]) { // Event message
        MQEventMessage *eventMessage = (MQEventMessage *)[messages firstObject];
        if (eventMessage.eventType == MQChatEventTypeRedirectFail) {
            //转人工失败
            [self addTipCellModelWithType:MQTipTypeReply];
        } else {
            [self handleEventMessage:eventMessage];
        }
    } else {
        [self handleVisualMessages:messages];
    }
    // 判断是否有需要移除的营销机器人引导按钮
    [self checkNeedRemoveBotGuideMessageWithForceReload: NO];
    
    //通知界面收到了消息
    BOOL isRefreshView = true;
    if (![MQChatViewConfig sharedConfig].enableEventDispaly && [[messages firstObject] isKindOfClass:[MQEventMessage class]]) {
        isRefreshView = false;
    } else {
        if (messages.count == 1 && [[messages firstObject] isKindOfClass:[MQEventMessage class]]) {
            MQEventMessage *eventMessage = [messages firstObject];
            if (eventMessage.eventType == MQChatEventTypeAgentInputting) {
                isRefreshView = false;
            }
        }
    }
    
    //若收到 socket 消息为机器人
    if ([messages count] == 1 && [[messages firstObject] isKindOfClass:[MQBotAnswerMessage class]]) {
        //调用强制转人工方法
        if ([((MQBotAnswerMessage *)[messages firstObject]).subType isEqualToString:@"redirect"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self forceRedirectToHumanAgent];
            });
        }
        //渲染手动转人工
        if ([((MQBotAnswerMessage *)[messages firstObject]).subType isEqualToString:@"manual_redirect"]) {
            [self addTipCellModelWithType:MQTipTypeBotManualRedirect];
        }
    }
    
    // 处理开启了新对话，移除排队
    if ([messages count] == 1 && [[messages firstObject] isKindOfClass:[MQEventMessage class]]) {
        //渲染手动转人工
        if (((MQEventMessage *)[messages firstObject]).eventType == MQChatEventTypeInitConversation) {
            [self checkAndUpdateWaitingQueueStatus];
        }
    }
    
    //等待 0.1 秒，等待 tableView 更新后再滑动到底部，优化体验
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.delegate && isRefreshView) {
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage)]) {
                [self.delegate didReceiveMessage];
            }
        }
    });
}

- (void)didReceiveTipsContent:(NSString *)tipsContent {
    [self didReceiveTipsContent:tipsContent showLines:YES];
}

- (void)didReceiveTipsContent:(NSString *)tipsContent showLines:(BOOL)show {
    MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initCellModelWithTips:tipsContent cellWidth:self.chatViewWidth enableLinesDisplay:show];
    [self addCellModelAfterReceivedWithCellModel:cellModel];
}

- (void)addCellModelAfterReceivedWithCellModel:(id<MQCellModelProtocol>)cellModel {
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self didReceiveMessageWithCellModel:cellModel];
}

- (void)didReceiveMessageWithCellModel:(id<MQCellModelProtocol>)cellModel {
    [self addCellModelAndReloadTableViewWithModel:cellModel];
    [self playReceivedMessageSound];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didReceiveMessage)]) {
            [self.delegate didReceiveMessage];
        }
    }
}

- (void)didRedirectWithAgentName:(NSString *)agentName {
    //[self updateChatTitleWithAgent:[MQServiceToViewInterface getCurrentAgent]];
}

- (void)didSendMessageWithNewMessageId:(NSString *)newMessageId
                          oldMessageId:(NSString *)oldMessageId
                        newMessageDate:(NSDate *)newMessageDate
                       replacedContent:(NSString *)replacedContent
                       updateMediaPath:(NSString *)mediaPath
                            sendStatus:(MQChatMessageSendStatus)sendStatus
                                 error:(NSError *)error
{
    [self playSendedMessageSound];

    // 判断是否开启了无消息访客过滤，开启的话要做留言提示处理
    if (([MQServiceToViewInterface getCurrentAgentName].length == 0 && self.clientStatus != MQStateAllocatingAgent)
        || [MQServiceToViewInterface currentOpenVisitorNoMessage]) {
        [self addNoAgentTip];
    }
    NSInteger index = [self getIndexOfCellWithMessageId:oldMessageId];
    if (index < 0) {
        return;
    }
    id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
    if ([cellModel respondsToSelector:@selector(updateCellMessageId:)]) {
        [cellModel updateCellMessageId:newMessageId];
    }
    if ([cellModel respondsToSelector:@selector(updateCellSendStatus:)]) {
        [cellModel updateCellSendStatus:sendStatus];
    }
    
    BOOL needSplitLine = NO;
    if (cellModel.getMessageConversionId.length < 1) {
        if ([cellModel respondsToSelector:@selector(updateCellConversionId:)]) {
            [cellModel updateCellConversionId:[MQServiceToViewInterface getCurrentConversationID]];
        }
    } else {
        if (cellModel.getMessageConversionId != [MQServiceToViewInterface getCurrentConversationID]) {
            needSplitLine = YES;
            if ([cellModel respondsToSelector:@selector(updateCellConversionId:)]) {
                [cellModel updateCellConversionId:[MQServiceToViewInterface getCurrentConversationID]];
            }
        }
    }
    if (newMessageDate) {
        if ([cellModel respondsToSelector:@selector(updateCellMessageDate:)]) {
            [cellModel updateCellMessageDate:newMessageDate];
        }
    }
    if (replacedContent) {
        if ([cellModel respondsToSelector:@selector(updateSensitiveState:cellText:)]) {
            [cellModel updateSensitiveState:YES cellText:replacedContent];
        }
    }
    
    if (mediaPath) {
        if ([cellModel respondsToSelector:@selector(updateMediaServerPath:)]) {
            [cellModel updateMediaServerPath:mediaPath];
        }
    }
    
    // 消息发送完成，刷新单行cell
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (needSplitLine) {
            MQSplitLineCellModel *cellModel1 = [[MQSplitLineCellModel alloc] initCellModelWithCellWidth:self.chatViewWidth withConversionDate:newMessageDate];
            [self.cellModels replaceObjectAtIndex:index withObject:cellModel1];
            // 首条消息重复问题
//            [self.cellModels addObject:cellModel];
            [self reloadChatTableView];
            [self scrollToBottom];
        } else {
            [self updateCellWithIndex:index needToBottom:YES];
        }
    });
    
    // 将 messageId 保存到 set，用于去重
//    if (![currentViewMessageIdSet containsObject:newMessageId]) {
//        [currentViewMessageIdSet addObject:newMessageId];
//    }
    if (error && error.userInfo.count > 0 && [error.userInfo valueForKey:@"NSLocalizedDescription"] && [[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:@"file upper limit!!"]) {
        [MQToast showToast:[MQBundleUtil localizedStringForKey:@"file_upload_limit"] duration:2 window:[UIApplication sharedApplication].keyWindow];
    }
    
    // 判断是否有触发排队
    int position = [MQServiceToViewInterface waitingInQueuePosition];
    if (position > 0) {
        [self addWaitingInQueueTipWithPosition:position];
        MQInfo(@"now you are at %d in waiting queue", position);
    }
}

#endif

/**
 *  刷新所有的本机用户的头像
 */
- (void)refreshOutgoingAvatarWithImage:(UIImage *)avatarImage {
    NSMutableArray *indexsToReload = [NSMutableArray new];
    for (NSInteger index=0; index<self.cellModels.count; index++) {
        id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
        if ([cellModel respondsToSelector:@selector(updateOutgoingAvatarImage:)]) {
            [cellModel updateOutgoingAvatarImage:avatarImage];
            [indexsToReload addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
}

- (void)dismissingChatViewController {
    [MQServiceToViewInterface setClientOffline];
}

- (NSString *)getPreviousInputtingText {
#ifdef INCLUDE_MEIQIA_SDK
    return [MQServiceToViewInterface getPreviousInputtingText];
#else
    return @"";
#endif
}

- (void)setCurrentInputtingText:(NSString *)inputtingText {
    [MQServiceToViewInterface setCurrentInputtingText:inputtingText];
}

- (void)evaluateBotAnswer:(BOOL)isUseful messageId:(NSString *)messageId {
    /**
     对机器人消息做评价，分两步：
        1、调用评价接口；
        2、生成正在转接的本地消息；
        3、调用强制转接接口；
     */
    [MQServiceToViewInterface evaluateBotMessage:messageId
                                        isUseful:isUseful
                                      completion:^(BOOL success, NSString *text, NSError *error) {
                                          // 根据企业的消息反馈，渲染一条消息气泡
                                          if (text.length > 0) {
                                              [self createLocalTextMessageWithText:text];
                                          }
                                          // 若用户点击「无用」，生成转人工的状态
                                          MQAgent *agent = [MQServiceToViewInterface getCurrentAgent];
                                          if (!isUseful && agent.privilege == MQAgentPrivilegeBot) {
                                              // 生成转人工的状态
                                              [self addTipCellModelWithType:MQTipTypeBotRedirect];
                                          }
                                      }];
    // 改变 botAnswerCellModel 的值
    for (id<MQCellModelProtocol> cellModel in self.cellModels) {
        if ([[cellModel getCellMessageId] isEqualToString:messageId]) {
            if ([cellModel respondsToSelector:@selector(didEvaluate:)]) {
                [cellModel didEvaluate:isUseful];
            }
            
        }
    }
}

- (void)collectionOperationIndex:(int)index messageId:(NSString *)messageId {
    // 现在只采集机器人消息的操作
    [MQServiceToViewInterface collectionBotOperationWithMessageId:messageId operationIndex:index];
}

/**
 生成本地的消息，不发送网络请求
 */
- (void)createLocalTextMessageWithText:(NSString *)text {
    //text message
    MQAgent *agent = [MQServiceToViewInterface getCurrentAgent];
    MQTextMessage *textMessage = [[MQTextMessage alloc] initWithContent:text];
    textMessage.fromType = MQChatMessageIncoming;
    if (agent) {
        textMessage.userName = agent.nickname;
        textMessage.userAvatarPath = agent.avatarPath;
    }
    
    [self didReceiveNewMessages:@[textMessage]];
    
}

/**
 强制转人工
 */
- (void)forceRedirectToHumanAgent {
    NSString *currentAgentId = [MQServiceToViewInterface getCurrentAgentId];
    [MQServiceToViewInterface setNotScheduledAgentWithAgentId:currentAgentId];
    [self setClientOnline];
    [self removeBotTipCellModels];
    [self reloadChatTableView];
    
}

#pragma mark - lazyload
#ifdef INCLUDE_MEIQIA_SDK
- (MQServiceToViewInterface *)serviceToViewInterface {
    if (!_serviceToViewInterface) {
        _serviceToViewInterface = [MQServiceToViewInterface new];
    }
    return _serviceToViewInterface;
}

#endif

-(NSMutableArray *)cacheTextArr {
    if (!_cacheTextArr) {
        _cacheTextArr = [NSMutableArray new];
    }
    return _cacheTextArr;
}

-(NSMutableArray *)cacheImageArr {
    if (!_cacheImageArr) {
        _cacheImageArr = [NSMutableArray new];
    }
    return _cacheImageArr;
}

-(NSMutableArray *)cacheFilePathArr {
    if (!_cacheFilePathArr) {
        _cacheFilePathArr = [NSMutableArray new];
    }
    return _cacheFilePathArr;
}

- (NSMutableArray *)cacheVideoPathArr {
    if (!_cacheVideoPathArr) {
        _cacheVideoPathArr = [NSMutableArray new];
    }
    return _cacheVideoPathArr;
}

@end
