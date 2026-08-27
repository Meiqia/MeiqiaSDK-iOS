//
//  MQVoiceMessageCell.m
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import "MQVoiceMessageCell.h"
#import "MQChatFileUtil.h"
#import "MQChatViewConfig.h"
#import "MQChatAudioPlayer.h"
#import "MEIQIA_VoiceConverter.h"
#import "MQAssetUtil.h"
#import "MQVoiceCellModel.h"
#import "MQImageUtil.h"
#import "MQWindowUtil.h"

@interface MQVoiceMessageCell()<MQChatAudioPlayerDelegate>

@end

@implementation MQVoiceMessageCell {
    UIImageView *avatarImageView;
    UIImageView *bubbleImageView;
    UIActivityIndicatorView *sendingIndicator;
    UILabel *durationLabel;
    UIImageView *voiceImageView;
    UIImageView *failureImageView;
    UIActivityIndicatorView *loadingIndicator;
    MQChatAudioPlayer *audioPlayer;
    NSData *voiceData;
    NSString *messageId;
    MQVoiceCellModel *voiceCellModel;
    UIView *notPlayPointView;
    BOOL isPlaying;
    BOOL isLoadVoiceSuccess;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MQAudioPlayerDidInterruptNotification object:nil];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        isPlaying = false;
        isLoadVoiceSuccess = false;
        //初始化头像
        avatarImageView = [[UIImageView alloc] init];
        avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:avatarImageView];
        //初始化气泡
        bubbleImageView = [[UIImageView alloc] init];
        bubbleImageView.userInteractionEnabled = true;
        UITapGestureRecognizer *tapBubbleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapVoiceBubbleGesture:)];
        [bubbleImageView addGestureRecognizer:tapBubbleGesture];
        [self.contentView addSubview:bubbleImageView];
        //初始化indicator
        sendingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        sendingIndicator.hidden = YES;
        [self.contentView addSubview:sendingIndicator];
        //初始化语音时长的label
        durationLabel = [[UILabel alloc] init];
        durationLabel.textColor = [UIColor lightGrayColor];
        durationLabel.font = [UIFont systemFontOfSize:kMQCellVoiceDurationLabelFontSize];
        durationLabel.textAlignment = NSTextAlignmentCenter;
        durationLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:durationLabel];
        //初始化语音图片
        voiceImageView = [[UIImageView alloc] init];
        [bubbleImageView addSubview:voiceImageView];
        //初始化出错image
        failureImageView = [[UIImageView alloc] initWithImage:[MQChatViewConfig sharedConfig].messageSendFailureImage];
        UITapGestureRecognizer *tapFailureImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFailImage:)];
        failureImageView.userInteractionEnabled = true;
        [failureImageView addGestureRecognizer:tapFailureImageGesture];
        [self.contentView addSubview:failureImageView];
        //初始化加载数据的indicator
        loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingIndicator.hidden = YES;
        [bubbleImageView addSubview:loadingIndicator];
        //初始化未播放的小红点view
        notPlayPointView = [[UIView alloc] init];
        notPlayPointView.backgroundColor = [UIColor redColor];
        notPlayPointView.hidden = true;
        [self.contentView addSubview:notPlayPointView];
        //注册声音中断的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVoiceDisplay) name:MQAudioPlayerDidInterruptNotification object:nil];
    }
    return self;
}

#pragma 点击语音的事件
- (void)didTapVoiceBubbleGesture:(id)sender {
    if (!voiceData || !isLoadVoiceSuccess) {
        return ;
    }
    notPlayPointView.hidden = true;
    if (isPlaying) {
        [self stopVoiceDisplay];
        [[MQChatAudioPlayer sharedInstance] stopSound];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MQAudioPlayerDidInterruptNotification object:nil];
    isPlaying = true;
    [voiceImageView startAnimating];
    //由于MQChatAudioPlayer是单例，所以每次点击某个cell进行播放，都必须重新设置audioPlayer的delegate
    [MQChatAudioPlayer sharedInstance].delegate = self;
    [MQChatAudioPlayer sharedInstance].keepSessionActive = [MQChatViewConfig sharedConfig].keepAudioSessionActive;
    [MQChatAudioPlayer sharedInstance].playMode = [MQChatViewConfig sharedConfig].playMode;
    [[MQChatAudioPlayer sharedInstance] playSongWithData:voiceData];
    //通知代理点击了语音
    if (self.chatCellDelegate) {
        if ([self.chatCellDelegate respondsToSelector:@selector(didTapMessageInCell:)]) {
            [self.chatCellDelegate didTapMessageInCell:self];
        }
    }
}

#pragma MQChatCellProtocol
- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if (![model isKindOfClass:[MQVoiceCellModel class]]) {
        NSAssert(NO, @"传给MQVoiceMessageCell的Model类型不正确");
        return ;
    }
    MQVoiceCellModel *cellModel = (MQVoiceCellModel *)model;
    voiceCellModel = cellModel;
    messageId = [cellModel.messageId copy];
    
    //刷新头像
    if (cellModel.avatarImage) {
        avatarImageView.image = cellModel.avatarImage;
    }
    avatarImageView.frame = cellModel.avatarFrame;
    if ([MQChatViewConfig sharedConfig].enableRoundAvatar) {
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.layer.cornerRadius = cellModel.avatarFrame.size.width/2;
    }
    
    //刷新气泡
    bubbleImageView.image = cellModel.bubbleImage;
    bubbleImageView.frame = cellModel.bubbleImageFrame;
    
    //是否成功获取到语音数据
    isLoadVoiceSuccess = cellModel.isLoadVoiceSuccess;
    
    //消息图片
    if (!voiceImageView.isAnimating) {
        if (cellModel.isLoadVoiceSuccess) {
            voiceImageView.image = [MQImageUtil convertImageColorWithImage:[MQAssetUtil voiceAnimationGreen3] toColor:[MQChatViewConfig sharedConfig].outgoingMsgTextColor];
            UIImage *animationImage1 = [MQAssetUtil voiceAnimationGreen1];
            UIImage *animationImage2 = [MQAssetUtil voiceAnimationGreen2];
            UIImage *animationImage3 = [MQAssetUtil voiceAnimationGreen3];
            if (cellModel.cellFromType == MQChatCellIncoming) {
                animationImage1 = [MQAssetUtil voiceAnimationGray1];
                animationImage2 = [MQAssetUtil voiceAnimationGray2];
                animationImage3 = [MQAssetUtil voiceAnimationGray3];
                voiceImageView.image = [MQAssetUtil voiceAnimationGray3];
            }
            

            voiceImageView.animationImages = [NSArray arrayWithObjects:
                                              [MQImageUtil convertImageColorWithImage:animationImage1 toColor:[MQChatViewConfig sharedConfig].outgoingMsgTextColor],
                                              [MQImageUtil convertImageColorWithImage:animationImage2 toColor:[MQChatViewConfig sharedConfig].outgoingMsgTextColor],
                                              [MQImageUtil convertImageColorWithImage:animationImage3 toColor:[MQChatViewConfig sharedConfig].outgoingMsgTextColor],nil];
            voiceImageView.animationDuration = 1;
            voiceImageView.animationRepeatCount = 0;
        } else {
            voiceImageView.image = [MQAssetUtil voiceAnimationGreenError];
            if (cellModel.cellFromType == MQChatCellIncoming) {
                voiceImageView.image = [MQAssetUtil voiceAnimationGrayError];
            }
        }
    }
    
    //刷新语音时长label
    NSString *durationText = [NSString stringWithFormat:@"%d\"", (int)cellModel.voiceDuration];
    durationLabel.text = durationText;
    durationLabel.frame = cellModel.durationLabelFrame;
    durationLabel.hidden = true;
    
    //判断是否正在加载声音，是否显示加载数据的indicator
    loadingIndicator.frame = cellModel.loadingIndicatorFrame;
    voiceImageView.frame = cellModel.voiceImageFrame;
    if (cellModel.voiceData) {
        voiceData = cellModel.voiceData;
        voiceImageView.hidden = false;
        loadingIndicator.hidden = true;
        [loadingIndicator stopAnimating];
    } else {
        voiceImageView.hidden = true;
        loadingIndicator.hidden = false;
        [loadingIndicator startAnimating];
    }
    
    //刷新indicator
    sendingIndicator.hidden = true;
    [sendingIndicator stopAnimating];
    if (cellModel.sendStatus == MQChatMessageSendStatusSending && cellModel.cellFromType == MQChatCellOutgoing) {
        sendingIndicator.hidden = false;
        sendingIndicator.frame = cellModel.sendingIndicatorFrame;
        [sendingIndicator startAnimating];
    } else {
        durationLabel.hidden = false;
    }
    
    //刷新出错图片
    failureImageView.hidden = true;
    if (cellModel.sendStatus == MQChatMessageSendStatusFailure) {
        failureImageView.hidden = false;
        failureImageView.frame = cellModel.sendFailureFrame;
    }
    
    //未播放按钮
    if (cellModel.cellFromType == MQChatCellIncoming && !cellModel.isPlayed) {
        notPlayPointView.frame = cellModel.notPlayViewFrame;
        notPlayPointView.layer.masksToBounds = true;
        notPlayPointView.layer.cornerRadius = cellModel.notPlayViewFrame.size.width / 2;
        notPlayPointView.hidden = false;
    } else {
        notPlayPointView.hidden = true;
    }
}

/**
 *  开始播放声音
 */
//- (void)playVoice {
//    [voiceImageView startAnimating];
//    //关闭键盘通知
//    [[NSNotificationCenter defaultCenter] postNotificationName:MQChatViewKeyboardResignFirstResponderNotification object:nil];
//}

/**
 *  停止播放声音
 */
- (void)stopVoiceDisplay {
    [voiceImageView stopAnimating];
    isPlaying = false;
}

#pragma MQChatAudioPlayerDelegate
- (void)MQAudioPlayerBeiginLoadVoice {
    
}

- (void)MQAudioPlayerBeiginPlay {
    
}

- (void)MQAudioPlayerDidFinishPlay {
    [self stopVoiceDisplay];
}

#pragma 点击发送失败消息 重新发送事件
- (void)tapFailImage:(id)sender {
    NSData *retryVoiceData = [voiceData copy];
    NSString *retryMessageId = [messageId copy];
    MQVoiceCellModel *retryCellModel = voiceCellModel;
    if (retryVoiceData.length == 0 || !retryCellModel) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [MQWindowUtil presentAlertWithTitle:@"重新发送吗？" message:nil cancelTitle:@"取消" confirmTitle:@"确定" sourceView:self handler:^(BOOL confirmed) {
        if (confirmed) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf resendFailedVoiceData:retryVoiceData messageId:retryMessageId cellModel:retryCellModel];
        }
    }];
}

- (void)resendFailedVoiceData:(NSData *)retryVoiceData messageId:(NSString *)retryMessageId cellModel:(MQVoiceCellModel *)retryCellModel {
    __weak id<MQChatCellDelegate> weakDelegate = self.chatCellDelegate;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileIdentifier = [NSUUID UUID].UUIDString;
        NSString *wavPath = [documentPath stringByAppendingPathComponent:[fileIdentifier stringByAppendingPathExtension:@"wav"]];
        NSString *amrPath = [documentPath stringByAppendingPathComponent:[fileIdentifier stringByAppendingPathExtension:@"amr"]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager createFileAtPath:wavPath contents:retryVoiceData attributes:nil]) {
            return;
        }
        [MEIQIA_VoiceConverter wavToAmr:wavPath amrSavePath:amrPath];
        [fileManager removeItemAtPath:wavPath error:nil];
        BOOL amrExists = [fileManager fileExistsAtPath:amrPath];
        unsigned long long amrSize = [[[fileManager attributesOfItemAtPath:amrPath error:nil] objectForKey:NSFileSize] unsignedLongLongValue];
        if (!amrExists || amrSize == 0) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            id<MQChatCellDelegate> delegate = weakDelegate;
            NSMutableDictionary *resendData = [@{@"voice" : amrPath, @"messageModel" : retryCellModel} mutableCopy];
            if (retryMessageId.length > 0) {
                resendData[@"messageId"] = retryMessageId;
            }
            [delegate resendMessageInCell:nil resendData:resendData];
        });
    });
}




@end
