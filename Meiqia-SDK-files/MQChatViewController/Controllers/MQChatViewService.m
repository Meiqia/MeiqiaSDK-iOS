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
#import "MQBotAnswerMessage.h"
#import "MQBotMenuMessage.h"
#import "MQTextCellModel.h"
#import "MQImageCellModel.h"
#import "MQVoiceCellModel.h"
#import "MQBotMenuCellModel.h"
#import "MQBotAnswerCellModel.h"
#import "MQRichTextViewModel.h"
#import "MQTipsCellModel.h"
#import "MQEvaluationResultCellModel.h"
#import "MQMessageDateCellModel.h"
#import <UIKit/UIKit.h>
#import "MQToast.h"
#import "VoiceConverter.h"
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

static NSInteger const kMQChatMessageMaxTimeInterval = 60;

/** 一次获取历史消息数的个数 */
static NSInteger const kMQChatGetHistoryMessageNumber = 20;

#ifdef INCLUDE_MEIQIA_SDK
@interface MQChatViewService() <MQServiceToViewInterfaceDelegate, MQCellModelDelegate>

@property (nonatomic, strong) MQServiceToViewInterface *serviceToViewInterface;

@property (nonatomic, assign) BOOL noAgentTipShowed;

@property (nonatomic, weak) NSTimer *positionCheckTimer;

@end
#else
@interface MQChatViewService() <MQCellModelDelegate>

@end
#endif

@implementation MQChatViewService {
#ifdef INCLUDE_MEIQIA_SDK
    BOOL addedNoAgentTip;  //是否已经说明了没有客服标记
    BOOL didSetOnline;     //用来判断顾客是否尝试登陆了
#endif
    //当前界面上显示的 message
    NSMutableSet *currentViewMessageIdSet;
}

- (instancetype)init {
    if (self = [super init]) {
        self.cellModels = [[NSMutableArray alloc] init];
        addedNoAgentTip = false;
        didSetOnline    = false;
        self.isShowBotRedirectBtn = false;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketStatusChanged:) name:MQ_NOTIFICATION_SOCKET_STATUS_CHANGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromBackground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanTimer) name:MQ_NOTIFICATION_CHAT_END object:nil];
        
        self.positionCheckTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkAndUpdateWaitingQueueStatus) userInfo:nil repeats:YES];
        currentViewMessageIdSet = [NSMutableSet new];        
    }
    return self;
}

- (void)cleanTimer {
    if (self.positionCheckTimer.isValid) {
        [self.positionCheckTimer invalidate];
        self.positionCheckTimer = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)backFromBackground {
    if ([MQServiceToViewInterface waitingInQueuePosition] > 0) {
        [self setClientOnline];
    }
}

#ifdef INCLUDE_MEIQIA_SDK
- (void)socketStatusChanged:(NSNotification *)notification {
    static BOOL shouldHandleSocketConnectNotification = NO; //当第一次进入的时候，会收到 socket 连上的消息，但是这个时候并不应该执行重新上线的逻辑，重新上线的逻辑必须是 socket 断开之后才有必要去执行的，这个标志的作用就是在 socket 有过断开的情况才去执行。
    if ([[notification.userInfo objectForKey:MQ_NOTIFICATION_SOCKET_STATUS_CHANGE] isEqualToString:SOCKET_STATUS_CONNECTED] && shouldHandleSocketConnectNotification) {
        if ([MQServiceToViewInterface waitingInQueuePosition] > 0) {
            [self setClientOnline];
        }
        shouldHandleSocketConnectNotification = NO;
    } else if([[notification.userInfo objectForKey:MQ_NOTIFICATION_SOCKET_STATUS_CHANGE] isEqualToString:SOCKET_STATUS_DISCONNECTED]){
        shouldHandleSocketConnectNotification = YES;
    }
}
#endif

#pragma 增加cellModel并刷新tableView
- (void)addCellModelAndReloadTableViewWithModel:(id<MQCellModelProtocol>)cellModel {
    [self.cellModels addObject:cellModel];
    [self reloadChatTableView];
}

/**
 * 获取更多历史聊天消息
 */
- (void)startGettingHistoryMessages {
#ifdef INCLUDE_MEIQIA_SDK
    NSDate *firstMessageDate = [self getFirstServiceCellModelDate];
    if ([MQChatViewConfig sharedConfig].enableSyncServerMessage) {
        [MQServiceToViewInterface getServerHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kMQChatGetHistoryMessageNumber successDelegate:self errorDelegate:self.errorDelegate];
    } else {
        [MQServiceToViewInterface getDatabaseHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kMQChatGetHistoryMessageNumber delegate:self];
    }
#endif
}

/**
 *  获取最旧的cell的日期，例如text/image/voice等
 */
- (NSDate *)getFirstServiceCellModelDate {
    for (NSInteger index = 0; index < self.cellModels.count; index++) {
        id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
#pragma 开发者可在下面添加自己更多的业务cellModel，以便能正确获取历史消息
        if ([cellModel isKindOfClass:[MQTextCellModel class]] ||
            [cellModel isKindOfClass:[MQImageCellModel class]] ||
            [cellModel isKindOfClass:[MQVoiceCellModel class]] ||
            [cellModel isKindOfClass:[MQEventCellModel class]] ||
            [cellModel isKindOfClass:[MQFileDownloadCellModel class]])
        {
            return [cellModel getCellDate];
        }
    }
    return [NSDate date];
}

/**
 * 发送文字消息
 */
- (void)sendTextMessageWithContent:(NSString *)content {
    MQTextMessage *message = [[MQTextMessage alloc] initWithContent:content];
    MQTextCellModel *cellModel = [[MQTextCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
#ifdef INCLUDE_MEIQIA_SDK
    [MQServiceToViewInterface sendTextMessageWithContent:content messageId:message.messageId delegate:self];
#else
    //模仿发送成功
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof (wself) sself = wself;
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        [sself playSendedMessageSound];
        [sself reloadChatTableView];
    });
#endif
}

/**
 * 发送图片消息
 */
- (void)sendImageMessageWithImage:(UIImage *)image {
    MQImageMessage *message = [[MQImageMessage alloc] initWithImage:image];
    MQImageCellModel *cellModel = [[MQImageCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
#ifdef INCLUDE_MEIQIA_SDK
    [MQServiceToViewInterface sendImageMessageWithImage:image messageId:message.messageId delegate:self];
#else
    //模仿发送成功
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof (wself) sself = wself;
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        [sself playSendedMessageSound];
        [sself reloadChatTableView];
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
#ifdef INCLUDE_MEIQIA_SDK
    NSData *amrData = [NSData dataWithContentsOfFile:filePath];
    [MQServiceToViewInterface sendAudioMessage:amrData messageId:message.messageId delegate:self];
#endif
}

/**
 * 以WAV格式语音数据的形式，发送语音消息
 * @param wavData WAV格式的语音数据
 */
- (void)sendVoiceMessageWithWAVData:(NSData *)wavData voiceMessage:(MQVoiceMessage *)message{
    MQVoiceCellModel *cellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
#ifndef INCLUDE_MEIQIA_SDK
    //模仿发送成功
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof (wself) sself = wself;
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        [sself playSendedMessageSound];
        [sself reloadChatTableView];
    });
#endif
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
    
    // 删除界面上的 messageId set
    if (![currentViewMessageIdSet containsObject:messageId]) {
        [currentViewMessageIdSet removeObject:messageId];
    }
#endif
    [self.cellModels removeObjectAtIndex:index];
    //判断删除这个model的之前的model是否为date，如果是，则删除时间cellModel
    if (index < 0 || self.cellModels.count <= index-1) {
        return;
    }
    
    id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index-1];
    if (cellModel && [cellModel isKindOfClass:[MQMessageDateCellModel class]]) {
        // 删除界面上的 messageId set
        NSString *messageId = [[self.cellModels objectAtIndex:index-1] getCellMessageId];
        if (![currentViewMessageIdSet containsObject:messageId]) {
            [currentViewMessageIdSet removeObject:messageId];
        }
        [self.cellModels removeObjectAtIndex:index-1];
        index --;
        
    }
    
    if (self.cellModels.count > index) {
        id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
        if (cellModel && [cellModel isKindOfClass:[MQTipsCellModel class]]) {
            // 删除界面上的 messageId set
            NSString *messageId = [[self.cellModels objectAtIndex:index] getCellMessageId];
            if (![currentViewMessageIdSet containsObject:messageId]) {
                [currentViewMessageIdSet removeObject:messageId];
            }
            [self.cellModels removeObjectAtIndex:index];
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
}

/**
 * 发送“用户正在输入”的消息
 */
- (void)sendUserInputtingWithContent:(NSString *)content {
    //[MQServiceToViewInterface sendClientInputtingWithContent:content];
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
    [self.cellModels addObject:cellModel];
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
    return true;
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

- (void)scrollToButton {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(scrollTableViewToBottom)]) {
            [self.delegate scrollTableViewToBottom];
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
        } else if ([lastCellModel isKindOfClass:[MQImageCellModel class]]) {
            MQImageCellModel *imageCellModel = (MQImageCellModel *)lastCellModel;
            MQImageMessage *message = [[MQImageMessage alloc] initWithImage:imageCellModel.image];
            message.fromType = MQChatMessageIncoming;
            MQImageCellModel *newCellModel = [[MQImageCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
            [self.cellModels addObject:newCellModel];
        } else if ([lastCellModel isKindOfClass:[MQVoiceCellModel class]]) {
            MQVoiceCellModel *voiceCellModel = (MQVoiceCellModel *)lastCellModel;
            MQVoiceMessage *message = [[MQVoiceMessage alloc] initWithVoiceData:voiceCellModel.voiceData];
            message.fromType = MQChatMessageIncoming;
            MQVoiceCellModel *newCellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
            [self.cellModels addObject:newCellModel];
        }
    }
    //text message
    MQTextMessage *textMessage = [[MQTextMessage alloc] initWithContent:@"Let's Rooooooooooock~"];
    textMessage.fromType = MQChatMessageIncoming;
    MQTextCellModel *textCellModel = [[MQTextCellModel alloc] initCellModelWithMessage:textMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:textCellModel];
    //image message
    MQImageMessage *imageMessage = [[MQImageMessage alloc] initWithImagePath:@"https://s3.cn-north-1.amazonaws.com.cn/pics.meiqia.bucket/65135e4c4fde7b5f"];
    imageMessage.fromType = MQChatMessageIncoming;
    MQImageCellModel *imageCellModel = [[MQImageCellModel alloc] initCellModelWithMessage:imageMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:imageCellModel];
    //tip message
//        MQTipsCellModel *tipCellModel = [[MQTipsCellModel alloc] initCellModelWithTips:@"主人，您的客服离线啦~" cellWidth:self.cellWidth enableLinesDisplay:true];
//        [self.cellModels addObject:tipCellModel];
    //voice message
    MQVoiceMessage *voiceMessage = [[MQVoiceMessage alloc] initWithVoicePath:@"http://7xiy8i.com1.z0.glb.clouddn.com/test.amr"];
    voiceMessage.fromType = MQChatMessageIncoming;
    MQVoiceCellModel *voiceCellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:voiceMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:voiceCellModel];
    // bot answer cell
    MQBotAnswerMessage *botAnswerMsg = [[MQBotAnswerMessage alloc] initWithContent:@"这个是一个机器人的回答。" subType:@"" isEvaluated:false];
    botAnswerMsg.fromType = MQChatMessageIncoming;
    MQBotAnswerCellModel *botAnswerCellmodel = [[MQBotAnswerCellModel alloc] initCellModelWithMessage:botAnswerMsg cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:botAnswerCellmodel];
    // bot menu cell
    MQBotMenuMessage *botMenuMsg = [[MQBotMenuMessage alloc] initWithContent:@"你是不是想问下面这些问题？" menu:@[@"1. 第一个 menu，说点儿什么呢，换个行吧啦啦啦", @"2. 再来一个 menu", @"3. 最后一个 menu"]];
    botMenuMsg.fromType = MQChatMessageIncoming;
    MQBotMenuCellModel *botMenuCellModel = [[MQBotMenuCellModel alloc] initCellModelWithMessage:botMenuMsg cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:botMenuCellModel];
    
    [self reloadChatTableView];
    [self playReceivedMessageSound];
}

#endif

#pragma MQCellModelDelegate
- (void)didUpdateCellDataWithMessageId:(NSString *)messageId {
    //获取又更新的cell的index
    NSInteger index = [self getIndexOfCellWithMessageId:messageId];
    if (index < 0) {
        return;
    }
    [self updateCellWithIndex:index];
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
- (void)updateCellWithIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didUpdateCellModelWithIndexPath:)]) {
            [self.delegate didUpdateCellModelWithIndexPath:indexPath];
        }
    }
}

#pragma AMR to WAV转换
- (NSData *)convertToWAVDataWithAMRFilePath:(NSString *)amrFilePath {
    NSString *tempPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    tempPath = [tempPath stringByAppendingPathComponent:@"record.wav"];
    [VoiceConverter amrToWav:amrFilePath wavSavePath:tempPath];
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
    //欢迎消息
    MQTextMessage *welcomeMessage = [[MQTextMessage alloc] initWithContent:[MQChatViewConfig sharedConfig].chatWelcomeText];
    welcomeMessage.fromType = MQChatMessageIncoming;
    welcomeMessage.userName = [MQChatViewConfig sharedConfig].agentName;
    welcomeMessage.userAvatarImage = [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage;
    welcomeMessage.sendStatus = MQChatMessageSendStatusSuccess;
    MQTextCellModel *cellModel = [[MQTextCellModel alloc] initCellModelWithMessage:welcomeMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:cellModel];
    [self reloadChatTableView];
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

#pragma 开发者可将自定义的message添加到此方法中
/**
 *  将消息数组中的消息转换成cellModel，并添加到cellModels中去;
 *
 *  @param newMessages             消息实体array
 *  @param isInsertAtFirstIndex 是否将messages插入到顶部
 *
 *  @return 返回转换为cell的个数
 */
- (NSInteger)saveToCellModelsWithMessages:(NSArray *)newMessages isInsertAtFirstIndex:(BOOL)isInsertAtFirstIndex{
    //去重
    NSMutableArray *messages = [NSMutableArray new];
    for (MQBaseMessage *message in newMessages) {
        if (![currentViewMessageIdSet containsObject:message.messageId]) {
            [messages addObject:message];
            [currentViewMessageIdSet addObject:message.messageId];
        } else {
            //判断是否重新刷新重复的消息
            if (messages.count == 0) {
                continue;
            }
            for (NSInteger index=0; index<self.cellModels.count; index++) {
                id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
                if ([message.messageId isEqualToString:[cellModel getCellMessageId]]) {
                    //找到重复的消息 cell 并删除
                    [self.cellModels removeObjectAtIndex:index];
                    //判断被删除的 cell 上下是否都是 时间戳 cell
                    if (self.cellModels.count > index) {
                        id<MQCellModelProtocol> lastCellModel = [self.cellModels objectAtIndex:index];
                        if (self.cellModels.count == index + 1 && [lastCellModel isKindOfClass:[MQMessageDateCellModel class]]) {
                            [self.cellModels removeObjectAtIndex:index];
                        } else if (self.cellModels.count > index + 1) {
                            id<MQCellModelProtocol> nextCellModel = [self.cellModels objectAtIndex:index + 1];
                            if ([lastCellModel isKindOfClass:[MQMessageDateCellModel class]] && [nextCellModel isKindOfClass:[MQMessageDateCellModel class]]) {
                                [self.cellModels removeObjectAtIndex:index];
                            }
                        }
                    }
                    break;
                }
            }
            [messages addObject:message];
        }
    }
    if (messages.count == 0) {
        return 0;
    }
    NSInteger cellNumber = 0;
    NSMutableArray *historyMessages = [[NSMutableArray alloc] initWithArray:messages];
    if (isInsertAtFirstIndex) {
        //如果是历史消息，则将历史消息插入到cellModels的首部
        [historyMessages removeAllObjects];
        for (MQBaseMessage *message in messages) {
            [historyMessages insertObject:message atIndex:0];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [MQServiceToViewInterface updateMessageIds:[historyMessages valueForKey:@"messageId"] toReadStatus:YES];
    });
    
    for (MQBaseMessage *message in historyMessages) {
        id<MQCellModelProtocol> cellModel;
        if ([message isKindOfClass:[MQTextMessage class]]) {
            cellModel = [[MQTextCellModel alloc] initCellModelWithMessage:(MQTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQImageMessage class]]) {
            cellModel = [[MQImageCellModel alloc] initCellModelWithMessage:(MQImageMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQVoiceMessage class]]) {
            cellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:(MQVoiceMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQFileDownloadMessage class]]) {
            cellModel = [[MQFileDownloadCellModel alloc] initCellModelWithMessage:(MQFileDownloadMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQRichTextMessage class]]) {
            if ([message isKindOfClass:[MQBotRichTextMessage class]]) {
                if ([[(MQBotRichTextMessage *)message subType] isEqualToString:@"evaluate"]) {
                    cellModel = [[MQBotWebViewBubbleAnswerCellModel alloc] initCellModelWithMessage:(MQBotRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                } else {
                    cellModel = [[MQWebViewBubbleCellModel alloc] initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                }
            } else {
                cellModel = [[MQRichTextViewModel alloc] initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
            }
        }else if ([message isKindOfClass:[MQBotAnswerMessage class]]) {
            if ([(MQBotAnswerMessage *)message menu] == nil) {
                cellModel = [[MQBotAnswerCellModel alloc] initCellModelWithMessage:(MQBotAnswerMessage *)message cellWidth:self.chatViewWidth delegate:self];
            } else {
                cellModel = [[MQBotMenuAnswerCellModel alloc] initCellModelWithMessage:(MQBotAnswerMessage *)message cellWidth:self.chatViewWidth delegate:self];
            }
        } else if ([message isKindOfClass:[MQBotMenuMessage class]]) {
            cellModel = [[MQBotMenuCellModel alloc] initCellModelWithMessage:(MQBotMenuMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQEventMessage class]]) {
            MQEventMessage *eventMessage = (MQEventMessage *)message;
            if (eventMessage.eventType == MQChatEventTypeInviteEvaluation) {
                if (!isInsertAtFirstIndex) {
                    //如果收到新评价消息，且当前不是正在录音状态，则显示评价 alertView
                    if (self.delegate) {
                        if ([self.delegate respondsToSelector:@selector(showEvaluationAlertView)] && [self.delegate respondsToSelector:@selector(isChatRecording)]) {
                            if (![self.delegate isChatRecording]) {
                                [self.delegate showEvaluationAlertView];
                            }
                        }
                    }
                }
            } else if (eventMessage.eventType == MQChatEventTypeInitConversation) {
                //
                [self checkAndUpdateWaitingQueueStatus];
            } else if (eventMessage.eventType == MQChatEventTypeClientEvaluation) {

            } else if (eventMessage.eventType == MQChatEventTypeQueueingRemoved) {
//                [MQServiceToViewInterface getCurrentAgent].agentId = @"";
//                [self setClientOnline];
            } else if (eventMessage.eventType == MQChatEventTypeQueueingAdd) {
                [self checkAndUpdateWaitingQueueStatus];
            } else if (eventMessage.eventType == MQChatEventTypeAgentUpdate) {
                //客服状态发生改变
                [self updateChatTitleWithAgent:[MQServiceToViewInterface getCurrentAgent]];
            } else if ([MQChatViewConfig sharedConfig].enableEventDispaly) {
                if (eventMessage.eventType == MQChatEventTypeAgentInputting) {
                    if (self.delegate) {
                        if ([self.delegate respondsToSelector:@selector(showToastViewWithContent:)]) {
                            [self.delegate showToastViewWithContent:@"客服正在输入..."];
                        }
                    }
                } else {
                    cellModel = [[MQEventCellModel alloc] initCellModelWithMessage:eventMessage cellWidth:self.chatViewWidth];
                }
            }
        }
        if (cellModel) {
            if (isInsertAtFirstIndex) {
                BOOL isInsertDateCell = [self insertMessageDateCellAtFirstWithCellModel:cellModel];
                if (isInsertDateCell) {
                    cellNumber ++;
                }
                [self.cellModels insertObject:cellModel atIndex:0];
                cellNumber ++;
            } else {
                BOOL isAddDateCell = [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
                if (isAddDateCell) {
                    cellNumber ++;
                }
                [self.cellModels addObject:cellModel];
                cellNumber ++;
            }
        }
    }
    //如果没有更多消息，则在顶部增加 date cell
    if (isInsertAtFirstIndex && messages.count < kMQChatGetHistoryMessageNumber) {
        MQBaseMessage *firstMessage = [messages firstObject];
        MQMessageDateCellModel *cellModel = [[MQMessageDateCellModel alloc] initCellModelWithDate:firstMessage.date cellWidth:self.chatViewWidth];
        [self.cellModels insertObject:cellModel atIndex:0];
        cellNumber ++;
    }
    [self reloadChatTableView];
    return cellNumber;
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
//    NSRange attribuitedRange = NSMakeRange(5, levelText.length);
//    levelText = [NSString stringWithFormat:@"你给出了 %@\n%@", levelText, comment];
//    NSDictionary<NSString *, id> *tipExtraAttributes = @{
//                                                         NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:13],
//                                                         NSForegroundColorAttributeName : levelColor
//                                                         };
    MQEvaluationResultCellModel *cellModel = [[MQEvaluationResultCellModel alloc] initCellModelWithEvaluation:level comment:comment cellWidth:self.chatViewWidth];
//    MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initCellModelWithTips:levelText cellWidth:self.chatViewWidth enableLinesDisplay:false];
//    cellModel.tipExtraAttributesRange = attribuitedRange;
//    cellModel.tipExtraAttributes = tipExtraAttributes;
    [self.cellModels addObject:cellModel];
    [self reloadChatTableView];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(scrollTableViewToBottom)]) {
            [self.delegate scrollTableViewToBottom];
        }
    }
}

- (void)addTipCellModelWithTips:(NSString *)tips enableLinesDisplay:(BOOL)enableLinesDisplay {
    MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initCellModelWithTips:tips cellWidth:self.chatViewWidth enableLinesDisplay:enableLinesDisplay];
    [self.cellModels addObject:cellModel];
    [self reloadChatTableView];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(scrollTableViewToBottom)]) {
            [self.delegate scrollTableViewToBottom];
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
    } else {
        MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initBotTipCellModelWithCellWidth:self.chatViewWidth tipType:tipType];
        [self.cellModels addObject:cellModel];
    }
    [self reloadChatTableView];
    [self scrollToButton];
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
    [self removeWaitingInQueueCellModels];
    MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initWaitingInQueueTipCellModelWithCellWidth:self.chatViewWidth position:position tipType:MQTipTypeWaitingInQueue];
    [self.cellModels addObject:cellModel];
    [self reloadChatTableView];
    [self scrollToButton];
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

#pragma 顾客上线的逻辑
//上线
- (void)setClientOnline {
    if (self.clientStatus == MQClientStatusOnlining || self.clientStatus == MQClientStatusPendingOnPreChatForm) {
        return;
    }
    
    self.clientStatus = MQClientStatusOnlining;
    
    [MQServiceToViewInterface setScheduledAgentWithAgentId:[MQChatViewConfig sharedConfig].scheduledAgentId agentGroupId:[MQChatViewConfig sharedConfig].scheduledGroupId scheduleRule:[MQChatViewConfig sharedConfig].scheduleRule];
    
    if ([MQChatViewConfig sharedConfig].MQClientId.length == 0 && [MQChatViewConfig sharedConfig].customizedId.length > 0) {
        [self onlineWithCustomizedId];
    } else {
        [self onlineWithClientId];
    }
}

- (void)onlineWithClientId {
    __weak typeof(self) weakSelf = self;
    [self.serviceToViewInterface setClientOnlineWithClientId:[MQChatViewConfig sharedConfig].MQClientId success:^(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        [strongSelf handleClientOnlineWithAgentName:agentName agentType:agentType receivedMessages:receivedMessages completeStatus:completion];
    } receiveMessageDelegate:self];
}

- (void)onlineWithCustomizedId {
    __weak typeof(self) weakSelf = self;
    [self.serviceToViewInterface setClientOnlineWithCustomizedId:[MQChatViewConfig sharedConfig].customizedId success:^(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        [strongSelf handleClientOnlineWithAgentName:agentName agentType:agentType receivedMessages:receivedMessages completeStatus:completion];
    } receiveMessageDelegate:self];
}

- (void)handleClientOnlineWithAgentName:(NSString *)agentName
                              agentType:(NSString *)agentType
                       receivedMessages:(NSArray *)receivedMessages
                         completeStatus:(BOOL)completion
{
    // 设置顾客已上线
    didSetOnline = true;
    
    // 设置顾客的状态
    self.clientStatus = MQClientStatusOnline;
    
    // 查看客服的状态
    MQChatAgentStatus agentStatus = [MQServiceToViewInterface getCurrentAgentStatus];
    if (!completion) {
        //没有分配到客服
        agentName = [MQBundleUtil localizedStringForKey: agentName && agentName.length > 0 ? agentName : @"no_agent_title"];
        agentStatus = MQChatAgentStatusOffLine;
    }
    
    // 获取企业的配置
    __weak typeof(self) wself = self;
    
    [MQServiceToViewInterface getIsShowRedirectHumanButtonComplete:^(BOOL isShow, NSError *error) {
        __strong typeof (wself) sself = wself;
        sself.isShowBotRedirectBtn = isShow;
        [sself updateChatTitleWithAgent:[MQServiceToViewInterface getCurrentAgent]];
    }];
    
    // 若是分配到了人工客服，则清除当前界面的「转人工」「留言」的 tipCell
    if (![agentType isEqualToString:@"bot"] && agentType.length > 0) {
        [self removeBotTipCellModels];
    }
    
    //更新客服聊天界面标题
    [self updateChatTitleWithAgent:[MQServiceToViewInterface getCurrentAgent]];
    
    //上传顾客信息
    [self setCurrentClientInfoWithCompletion:^(BOOL success) {
        //获取顾客信息
        __strong typeof (wself) sself = wself;
        [sself getClientInfo];
    }];
    
    
    // 判断是否是机器人客服，来改变右上角按钮
    agentType = completion ? agentType : @"";
    if ([self.delegate respondsToSelector:@selector(changeNavReightBtnWithAgentType:)]) {
        [self.delegate changeNavReightBtnWithAgentType:agentType];
    }
    
    if (receivedMessages) {
        [self saveToCellModelsWithMessages:receivedMessages isInsertAtFirstIndex:false];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof (wself) sself = wself;
        [sself scrollToButton];
    });
    
    [self afterClientOnline];
}

- (void)afterClientOnline {
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
    
    [MQServiceToViewInterface getEnterpriseConfigInfoComplete:^(MQEnterprise *enterprise, NSError *e) {
        [MQCustomizedUIText setCustomiedTextForKey:(MQUITextKeyNoAgentTip) text:enterprise.configInfo.intro];
    }];
}

- (void)checkAndUpdateWaitingQueueStatus {
    //如果之前在排队中，则继续查询
    if ([MQServiceToViewInterface waitingInQueuePosition] > 0) {
        MQInfo(@"check wating queue position")
        __weak typeof(self) wself = self;
        [MQServiceToViewInterface getClientQueuePositionComplete:^(NSInteger position, NSError *error) {
            __strong typeof(wself)sself = wself;
            if (position > 0) {
                [sself addWaitingInQueueTipWithPosition:(int)position];
                MQInfo(@"now you are at %d in waiting queue", (int)position);
            } else {
                [sself removeWaitingInQueueCellModels];
                [sself removeBotTipCellModels];
                [sself reloadChatTableView];
            }
            [sself updateChatTitleWithAgent:[MQServiceToViewInterface getCurrentAgent]];
        }];
    } else {
        [self removeBotTipCellModels];
        [self removeWaitingInQueueCellModels];
        [self reloadChatTableView];
        [self updateChatTitleWithAgent:[MQServiceToViewInterface getCurrentAgent]];
        [self.positionCheckTimer invalidate];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendPreSendMessages];
        });
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
    if ([MQServiceToViewInterface getCurrentAgentStatus] == MQChatAgentStatusOnDuty) {
        for (id messageContent in [MQChatViewConfig sharedConfig].preSendMessages) {
            if ([messageContent isKindOfClass:NSString.class]) {
                [self sendTextMessageWithContent:messageContent];
            } else if ([messageContent isKindOfClass:UIImage.class]) {
                [self sendImageMessageWithImage:messageContent];
            }
        }
        
        [MQChatViewConfig sharedConfig].preSendMessages = nil;
    }
}

//获取顾客信息
- (void)getClientInfo {
    NSDictionary *clientInfo = [MQServiceToViewInterface getCurrentClientInfo];
    if ([[clientInfo objectForKey:@"avatar"] length] == 0) {
        return ;
    }
    
    [MQServiceToViewInterface downloadMediaWithUrlString:[clientInfo objectForKey:@"avatar"] progress:^(float progress) {
    } completion:^(NSData *mediaData, NSError *error) {
        [MQChatViewConfig sharedConfig].outgoingDefaultAvatarImage = [UIImage imageWithData:mediaData];
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


- (NSString *)noAgentTitle {
    if ([MQServiceToViewInterface waitingInQueuePosition] > 0) {
        return @"排队等待中...";
    }
    return [MQBundleUtil localizedStringForKey:@"no_agent_title"];
}

- (void)updateChatTitleWithAgent:(MQAgent *)agent {
    MQChatAgentStatus agentStatus = [self getAgentStatus:agent];
    NSString *viewTitle = agent.nickname.length == 0 ? [self noAgentTitle] : agent.nickname;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didScheduleClientWithViewTitle:agentStatus:)]) {
            [self.delegate didScheduleClientWithViewTitle:viewTitle agentStatus:agentStatus];
        }
        
        if ([self.delegate respondsToSelector:@selector(changeNavReightBtnWithAgentType:)]) {
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
            [self.delegate changeNavReightBtnWithAgentType:agentType];
        }
    }
}

- (MQChatAgentStatus)getAgentStatus:(MQAgent *)agent {
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

- (void)addNoAgentTip {
    if (!self.noAgentTipShowed && ![MQServiceToViewInterface isBlacklisted] && [MQServiceToViewInterface waitingInQueuePosition] == 0) {
        self.noAgentTipShowed = YES;
        [self addTipCellModelWithTips:[MQBundleUtil localizedStringForKey:@"no_agent_tips"] enableLinesDisplay:true];
    }
}

#pragma MQServiceToViewInterfaceDelegate
- (void)didReceiveHistoryMessages:(NSArray *)messages {
    if (!didSetOnline) {
        return;
    }
    NSInteger cellNumber = 0;
    NSInteger messageNumber = 0;
    if (messages.count > 0) {
        cellNumber = [self saveToCellModelsWithMessages:messages isInsertAtFirstIndex:true];
        messageNumber = messages.count;
    }
    //如果没有获取更多的历史消息，则也需要通知界面取消刷新indicator
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didGetHistoryMessagesWithCellNumber:isLoadOver:)]) {
            [self.delegate didGetHistoryMessagesWithCellNumber:cellNumber isLoadOver:messageNumber < kMQChatGetHistoryMessageNumber];
        }
    }
}

- (void)didReceiveNewMessages:(NSArray *)messages {

    //转换message to cellModel，并缓存
    if (messages.count == 0 || !didSetOnline) {
        return;
    } else if ([self saveToCellModelsWithMessages:messages isInsertAtFirstIndex:false] == 0) {
        return;
    }
    //eventMessage不响铃声
    if (messages.count > 1 || ![[messages firstObject] isKindOfClass:[MQEventMessage class]]) {
        [self playReceivedMessageSound];
    }
    //更新界面title
    [self updateChatTitleWithAgent:[MQServiceToViewInterface getCurrentAgent]];
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
            __weak typeof(self)wself = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong typeof(wself)sself = wself;
                [sself forceRedirectToHumanAgent];
            });
        }
        //渲染手段转人工
        if ([((MQBotAnswerMessage *)[messages firstObject]).subType isEqualToString:@"manual_redirect"]) {
            [self addTipCellModelWithType:MQTipTypeBotManualRedirect];
        }
    }
    //等待 0.1 秒，等待 tableView 更新后再滑动到底部，优化体验
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof (wself) sself = wself;
        if (sself.delegate && isRefreshView) {
            if ([sself.delegate respondsToSelector:@selector(didReceiveMessage)]) {
                [sself.delegate didReceiveMessage];
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
    [self updateChatTitleWithAgent:[MQServiceToViewInterface getCurrentAgent]];
}

- (void)didSendMessageWithNewMessageId:(NSString *)newMessageId
                          oldMessageId:(NSString *)oldMessageId
                        newMessageDate:(NSDate *)newMessageDate
                            sendStatus:(MQChatMessageSendStatus)sendStatus
{
    [self playSendedMessageSound];
    //如果新的messageId和旧的messageId不同，且是发送成功状态，则表明肯定是分配成功的
    if (![newMessageId isEqualToString:oldMessageId] && sendStatus == MQChatMessageSendStatusSuccess) {
        NSString *agentName = [MQServiceToViewInterface getCurrentAgentName];
        if (agentName.length > 0) {
            [self updateChatTitleWithAgent:[MQServiceToViewInterface getCurrentAgent]];
        }
    }
    if ([MQServiceToViewInterface getCurrentAgentName].length == 0 && self.clientStatus != MQClientStatusOnlining) {
        [self addNoAgentTip];
        [self updateChatTitleWithAgent:[MQServiceToViewInterface getCurrentAgent]];
    }
    NSInteger index = [self getIndexOfCellWithMessageId:oldMessageId];
    if (index < 0) {
        return;
    }
    id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
    [cellModel updateCellMessageId:newMessageId];
    [cellModel updateCellSendStatus:sendStatus];
    if (newMessageDate) {
        [cellModel updateCellMessageDate:newMessageDate];
    }
    
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof (wself) sself = wself;
        [sself updateCellWithIndex:index];
    });
    
    // 将 messageId 保存到 set，用于去重
    if (![currentViewMessageIdSet containsObject:newMessageId]) {
        [currentViewMessageIdSet addObject:newMessageId];
    }
    
    // 根据 agentType 来改变状态
    NSString *agentType = [MQServiceToViewInterface getCurrentAgentType];
    if ([self.delegate respondsToSelector:@selector(changeNavReightBtnWithAgentType:)]) {
        [self.delegate changeNavReightBtnWithAgentType:agentType];
    }
}

#endif

/**
 *  刷新所有的本机用户的头像
 */
- (void)refreshOutgoingAvatarWithImage:(UIImage *)avatarImage {
    for (NSInteger index=0; index<self.cellModels.count; index++) {
        id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
        if ([cellModel respondsToSelector:@selector(updateOutgoingAvatarImage:)]) {
            [cellModel updateOutgoingAvatarImage:avatarImage];
        }
    }
    [self reloadChatTableView];
}

- (void)dismissingChatViewController {
#ifdef INCLUDE_MEIQIA_SDK
    [MQServiceToViewInterface setClientOffline];
#endif
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
            if ([cellModel respondsToSelector:@selector(didEvaluate)]) {
                [cellModel didEvaluate];
            }
            
        }
    }
}

/**
 生成本地的消息，不发送网络请求
 */
- (void)createLocalTextMessageWithText:(NSString *)text {
    //text message
    MQTextMessage *textMessage = [[MQTextMessage alloc] initWithContent:text];
    textMessage.fromType = MQChatMessageIncoming;
    MQTextCellModel *textCellModel = [[MQTextCellModel alloc] initCellModelWithMessage:textMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:textCellModel];
    [self reloadChatTableView];
    [self playReceivedMessageSound];
}

/**
 强制转人工
 */
- (void)forceRedirectToHumanAgent {
#ifdef INCLUDE_MEIQIA_SDK
    NSString *currentAgentId = [MQServiceToViewInterface getCurrentAgentId];
    [MQServiceToViewInterface setNotScheduledAgentWithAgentId:currentAgentId];
    [self setClientOnline];
#endif
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


@end
