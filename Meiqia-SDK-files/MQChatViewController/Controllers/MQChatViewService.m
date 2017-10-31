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
#import "NSArray+MQFunctional.h"
#import "MQToast.h"
#import "NSError+MQConvenient.h"

#import "MQBotMenuWebViewBubbleAnswerCellModel.h"

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
        
        self.positionCheckTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkAndUpdateWaitingQueueStatus) userInfo:nil repeats:YES];
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

- (void)backFromBackground {
    if ([MQServiceToViewInterface waitingInQueuePosition] > 0) {
        [self setClientOnline];
    }
}

- (MQState)clientStatus {
    return [MQManager getCurrentState];
}

#pragma 增加cellModel并刷新tableView
- (void)addCellModelAndReloadTableViewWithModel:(id<MQCellModelProtocol>)cellModel {
    [self.cellModels addObject:cellModel];
    [self.delegate insertCellAtBottomForModelCount: 1];
//    [self reloadChatTableView];
}

/**
 * 获取更多历史聊天消息
 */
- (void)startGettingHistoryMessages {
    NSDate *firstMessageDate = [self getFirstServiceCellModelDate];
    if ([MQChatViewConfig sharedConfig].enableSyncServerMessage) {
        [MQServiceToViewInterface getServerHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kMQChatGetHistoryMessageNumber successDelegate:self errorDelegate:self.errorDelegate];
    } else {
        [MQServiceToViewInterface getDatabaseHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kMQChatGetHistoryMessageNumber delegate:self];
    }
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

- (NSDate *)getLastServiceCellModelDate {
    for (NSInteger index = 0; index < self.cellModels.count; index++) {
        id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
      
        if (index == self.cellModels.count - 1) {

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
    [MQServiceToViewInterface sendTextMessageWithContent:content messageId:message.messageId delegate:self];
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
    MQVoiceCellModel *cellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
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
- (void)didUpdateCellDataWithMessageId:(NSString *)messageId {
    //获取又更新的cell的index
    NSInteger index = [self getIndexOfCellWithMessageId:messageId];
    if (index < 0 || index > self.cellModels.count - 1) {
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

- (id<MQCellModelProtocol>)createCellModelWith:(MQBaseMessage *)message {
    id<MQCellModelProtocol> cellModel = nil;
    if (![message isKindOfClass:[MQEventMessage class]]) {
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
                
//                if ([[(MQBotRichTextMessage *)message subType] isEqualToString:@"evaluate"]) {
//                    cellModel = [[MQBotWebViewBubbleAnswerCellModel alloc] initCellModelWithMessage:(MQBotRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
//                } else {
//                    cellModel = [[MQWebViewBubbleCellModel alloc] initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
//                }
                //xlp 富文本展示
                if ([(MQBotRichTextMessage *)message menu] != nil) {

                    if ([[(MQBotRichTextMessage *)message subType] isEqualToString:@"evaluate"]) {
                        cellModel = [[MQBotMenuWebViewBubbleAnswerCellModel alloc] initCellModelWithMessage:(MQBotRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                    } else {
                        cellModel = [[MQWebViewBubbleCellModel alloc] initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                    }

                } else {

                    if ([[(MQBotRichTextMessage *)message subType] isEqualToString:@"evaluate"]) {
                        cellModel = [[MQBotWebViewBubbleAnswerCellModel alloc] initCellModelWithMessage:(MQBotRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                    } else {
                        cellModel = [[MQWebViewBubbleCellModel alloc] initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                    }
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
        }
    }
    return cellModel;
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
        
         NSArray *redundentCellModels = [self.cellModels filter:^BOOL(id<MQCellModelProtocol> cellModel) {
            return [[cellModel getCellMessageId] isEqualToString:[newCellModel getCellMessageId]];
         }];
        
        if ([redundentCellModels count] > 0) {
            [self.cellModels replaceObjectAtIndex:[self.cellModels indexOfObject:[redundentCellModels firstObject]] withObject:newCellModel];
        } else {
            [newCellModels addObject:newCellModel];
        }
    }
    
    // 2. 计算新的 cell model 在列表中的位置
    NSMutableSet *positionVector = [NSMutableSet new]; // 计算位置的辅助容器，如果所有消息都为 0，放在底部，都为 1，放在顶部，两者都有，则需要重新排序。
    NSDate *firstMessageDate = [self.cellModels.firstObject getCellDate];
    NSDate *lastMessageDate = [self.cellModels.lastObject getCellDate];
    [newCellModels enumerateObjectsUsingBlock:^(id<MQCellModelProtocol> newCellModel, NSUInteger idx, BOOL * stop) {
        if ([firstMessageDate compare:[newCellModel getCellDate]] == NSOrderedDescending) {
            [positionVector addObject:@"1"];
        } else if ([lastMessageDate compare:[newCellModel getCellDate]] == NSOrderedAscending) {
            [positionVector addObject:@"0"];
        }
    }];
    
    if (positionVector.count > 1) {
        positionVector = [[NSMutableSet alloc] initWithObjects:@"2", nil];
    }
    
    __block NSUInteger position = 0; // 0: bottom, 1: top, 2: random
    
    [positionVector enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        position = [obj intValue];
    }];
    
    NSUInteger newMessageCount = newCellModels.count;
    if (newCellModels.count == 0) { return 0; }
    switch (position) {
        case 1: // top
            [self insertMessageDateCellAtFirstWithCellModel:[newCellModels firstObject]]; // 如果需要，顶部插入时间
            self.cellModels = [[newCellModels arrayByAddingObjectsFromArray:self.cellModels] mutableCopy];
            break;
        case 0: // bottom
            [self addMessageDateCellAtLastWithCurrentCellModel:[newCellModels firstObject]]; // 如果需要，底部插入时间
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
//    [self reloadChatTableView];
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
        MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initBotTipCellModelWithCellWidth:self.chatViewWidth tipType:tipType];
        [self.cellModels addObject:cellModel];
        [self.delegate insertCellAtBottomForModelCount: 1];
    }
//    [self reloadChatTableView];
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
    [self.delegate reloadChatTableView];
    MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initWaitingInQueueTipCellModelWithCellWidth:self.chatViewWidth position:position tipType:MQTipTypeWaitingInQueue];
    [self.cellModels addObject:cellModel];
//    [self reloadChatTableView];
    [self.delegate insertCellAtBottomForModelCount: 1];
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
    if (self.clientStatus == MQStateAllocatingAgent) {
        return;
    }
    
    [MQServiceToViewInterface setScheduledAgentWithAgentId:[MQChatViewConfig sharedConfig].scheduledAgentId agentGroupId:[MQChatViewConfig sharedConfig].scheduledGroupId scheduleRule:[MQChatViewConfig sharedConfig].scheduleRule];
    
    if ([MQChatViewConfig sharedConfig].MQClientId.length == 0 && [MQChatViewConfig sharedConfig].customizedId.length > 0) {
        [self onlineWithCustomizedId];
    } else {
        [self onlineWithClientId];
    }
}

- (void)onlineWithClientId {
    __weak typeof(self) weakSelf = self;
    [self.serviceToViewInterface setClientOnlineWithClientId:[MQChatViewConfig sharedConfig].MQClientId success:^(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if ([error reason].length == 0) {
            [strongSelf handleClientOnlineWithRreceivedMessages:receivedMessages completeStatus:completion];
        } else {
            [MQToast showToast:[error shortDescription] duration:2.5 window:[[UIApplication sharedApplication].windows lastObject]];
        }
    } receiveMessageDelegate:self];
}

- (void)onlineWithCustomizedId {
    __weak typeof(self) weakSelf = self;
    [self.serviceToViewInterface setClientOnlineWithCustomizedId:[MQChatViewConfig sharedConfig].customizedId success:^(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if ([error reason].length == 0) {
            [strongSelf handleClientOnlineWithRreceivedMessages:receivedMessages completeStatus:completion];
        } else {
            [MQToast showToast:[error shortDescription] duration:2.5 window:[[UIApplication sharedApplication].windows lastObject]];
        }
    } receiveMessageDelegate:self];
}

- (void)handleClientOnlineWithRreceivedMessages:(NSArray *)receivedMessages
                         completeStatus:(BOOL)completion
{
    if (receivedMessages) {
        NSInteger newCellCount = [self saveToCellModelsWithMessages:receivedMessages isInsertAtFirstIndex: NO];
        [UIView setAnimationsEnabled:NO];
        [self.delegate insertCellAtTopForModelCount: newCellCount];
        [self scrollToButton];
        [UIView setAnimationsEnabled:YES];
        [self.delegate reloadChatTableView];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollToButton]; // some image may lead the table didn't reach bottom
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
        [MQCustomizedUIText setCustomiedTextForKey:(MQUITextKeyNoAgentTip) text:enterprise.configInfo.intro];
    }];
}

- (void)checkAndUpdateWaitingQueueStatus {
    //如果之前在排队中，则继续查询
    if ([MQServiceToViewInterface waitingInQueuePosition] > 0) {
        MQInfo(@"check wating queue position")
        [MQServiceToViewInterface getClientQueuePositionComplete:^(NSInteger position, NSError *error) {
            if (position > 0) {
                [self addWaitingInQueueTipWithPosition:(int)position];
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
                    viewTitle = @"排队等待中...";
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

#pragma MQServiceToViewInterfaceDelegate
- (void)didReceiveHistoryMessages:(NSArray *)messages {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didGetHistoryMessagesWithCommitTableAdjustment:)]) {
            __weak typeof(self) wself = self;
            [self.delegate didGetHistoryMessagesWithCommitTableAdjustment:^{
                __strong typeof (wself) sself = wself;
                if (messages.count > 0) {
                    [sself saveToCellModelsWithMessages:messages isInsertAtFirstIndex:true];
                    [sself.delegate reloadChatTableView]; // 这个地方不使用 [self.delegate insertCellAtBottomForModelCount: ]; 因为需要整体重新加载之后移动 table 的偏移量
                }
            }];
        }
    }
}

- (void)handleEventMessage:(MQEventMessage *)eventMessage {
    NSString *tipString = eventMessage.tipString;
    if (tipString.length > 0) {
        if ([self respondsToSelector:@selector(didReceiveTipsContent:)]) {
            [self didReceiveTipsContent:tipString showLines:NO];
        }
    }
        
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

- (void)didReceiveNewMessages:(NSArray *)messages {
    if (messages.count == 1 && [[messages firstObject] isKindOfClass:[MQEventMessage class]]) { // Event message
        MQEventMessage *eventMessage = (MQEventMessage *)[messages firstObject];
        [self handleEventMessage:eventMessage];
    } else {
        [self handleVisualMessages:messages];
    }
    
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
                            sendStatus:(MQChatMessageSendStatus)sendStatus
{
    [self playSendedMessageSound];

    if ([MQServiceToViewInterface getCurrentAgentName].length == 0 && self.clientStatus != MQStateAllocatingAgent) {
        [self addNoAgentTip];
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateCellWithIndex:index];
    });
    
    // 将 messageId 保存到 set，用于去重
//    if (![currentViewMessageIdSet containsObject:newMessageId]) {
//        [currentViewMessageIdSet addObject:newMessageId];
//    }
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
    
    [self didReceiveNewMessages:@[textMessage]];
    
//    MQTextCellModel *textCellModel = [[MQTextCellModel alloc] initCellModelWithMessage:textMessage cellWidth:self.chatViewWidth delegate:self];
//    [self.cellModels addObject:textCellModel];
////    [self reloadChatTableView];
//    [self.delegate insertCellAtBottomForModelCount: 1];
//    [self playReceivedMessageSound];
}

/**
 强制转人工
 */
- (void)forceRedirectToHumanAgent {
    NSString *currentAgentId = [MQServiceToViewInterface getCurrentAgentId];
    [MQServiceToViewInterface setNotScheduledAgentWithAgentId:currentAgentId];
    [self setClientOnline];
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
