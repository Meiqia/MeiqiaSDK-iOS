//
//  MQVideoCellModel.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/23.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQVideoCellModel.h"
#import "MQVideoMessageCell.h"
#import "MQServiceToViewInterface.h"
#import "MQImageUtil.h"
#import "MQChatFileUtil.h"
#import "MQToast.h"
#import "MQBundleUtil.h"
#ifndef INCLUDE_MEIQIA_SDK
#import "UIImageView+WebCache.h"
#endif
/**
 * 聊天气泡和其中的图片垂直间距
 */
static CGFloat const kMQCellBubbleToImageSpacing = 12.0;

@interface MQVideoCellModel ()

/**
 * @brief cell的宽度
 */
@property (nonatomic, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property (nonatomic, assign) CGFloat cellHeight;

/**
 * bubble中的imageView的frame
 */
@property (nonatomic, readwrite, assign) CGRect contentImageViewFrame;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

/**
 * @brief 播放按钮的frame
 */
@property (nonatomic, readwrite, assign) CGRect playBtnFrame;

/**
 * @brief 发送失败图标的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendFailureFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readwrite, strong) UIImage *avatarImage;

/**
 * @brief 视频第一帧的图片
 */
@property (nonatomic, readwrite, strong) UIImage *thumbnail;

/**
 * @brief 视频本地路径
 */
@property (nonatomic, readwrite, copy) NSString *videoPath;

/**
 * @brief 视频服务器路径
 */
@property (nonatomic, readwrite, copy) NSString *videoServerPath;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readwrite, assign) MQChatCellFromType cellFromType;

/**
 * @brief 消息的发送状态
 */
@property (nonatomic, readwrite, assign) MQChatMessageSendStatus sendStatus;

/**
 * @brief 是否正在下载视频
 */
@property (nonatomic, readwrite, assign) BOOL isDownloading;

@property (nonatomic, strong) MQVideoMessage *message;

@end

@implementation MQVideoCellModel

#pragma initialize
/**
 *  根据MQMessage内容来生成cell model
 */
- (MQVideoCellModel *)initCellModelWithMessage:(MQVideoMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegate {
    if (self = [super init]) {
        self.cellWidth = cellWidth;
        self.delegate  = delegate;
        self.message = message;
        self.videoPath = message.videoPath;
        self.videoServerPath = message.videoUrl;
        self.sendStatus = message.sendStatus;
        self.isDownloading = false;
        self.cellFromType = message.fromType == MQChatMessageIncoming ? MQChatCellIncoming : MQChatCellOutgoing;
        if (message.userAvatarImage) {
            self.avatarImage = message.userAvatarImage;
        } else if (message.userAvatarPath.length > 0) {
            self.avatarPath = message.userAvatarPath;
            //这里使用美洽接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_MEIQIA_SDK
            [MQServiceToViewInterface downloadMediaWithUrlString:message.userAvatarPath progress:^(float progress) {
            } completion:^(NSData *mediaData, NSError *error) {
                if (mediaData && !error) {
                    self.avatarImage = [UIImage imageWithData:mediaData];
                } else {
                    self.avatarImage = message.fromType == MQChatMessageIncoming ? [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage : [MQChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        //通知ViewController去刷新tableView
                        [self.delegate didUpdateCellDataWithMessageId:self.message.messageId];
                    }
                }
            }];
#else
            __block UIImageView *tempImageView = [UIImageView new];
            [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.userAvatarPath] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                self.avatarImage = tempImageView.image.copy;
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        //通知ViewController去刷新tableView
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
#endif
        } else {
            self.avatarImage = [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage;
            if (message.fromType == MQChatMessageOutgoing) {
                self.avatarImage = [MQChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
            }
        }
        
        // 判断是否缓存了视频
        if (message.videoPath.length > 0 && [MQChatFileUtil fileExistsAtPath:message.videoPath isDirectory:false]) {
            //默认cell高度为图片显示的最大高度
            self.cellHeight = cellWidth / 2;
            self.thumbnail = [MQChatFileUtil getLocationVideoPreViewImage:[NSURL fileURLWithPath:message.videoPath]];
            [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
        } else if (message.thumbnailUrl.length > 0) {
            //这里使用美洽接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_MEIQIA_SDK
            [MQServiceToViewInterface downloadMediaWithUrlString:message.thumbnailUrl progress:^(float progress) {
            } completion:^(NSData *mediaData, NSError *error) {
                if (mediaData && !error) {
                    self.thumbnail = [UIImage imageWithData:mediaData];
                    [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
                } else {
                    self.thumbnail = [MQChatViewConfig sharedConfig].imageLoadErrorImage;
                    [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        [self.delegate didUpdateCellDataWithMessageId:self.message.messageId];
                    }
                }
            }];
#else
            //非美洽SDK用户，使用了SDWebImage来做图片缓存
            __block UIImageView *tempImageView = [[UIImageView alloc] init];
            [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.thumbnailUrl] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (image) {
                    self.thumbnail = tempImageView.image.copy;
                    [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
                } else {
                    self.thumbnail = [MQChatViewConfig sharedConfig].imageLoadErrorImage;
                    [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
#endif
        } else {
            self.thumbnail = [MQChatViewConfig sharedConfig].imageLoadErrorImage;
            [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
        }
    }
    return self;
}

- (void)startDownloadMediaCompletion:(void (^)(NSString * _Nonnull))completion {
#ifdef INCLUDE_MEIQIA_SDK
    __weak typeof(self) weakSelf = self;
    [MQServiceToViewInterface downloadMediaWithUrlString:self.videoServerPath progress:^(float progress) {
        if (!weakSelf.isDownloading && progress != 1) {
            weakSelf.isDownloading = YES;
            if (weakSelf.delegate) {
                if ([weakSelf.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                    [weakSelf.delegate didUpdateCellDataWithMessageId:weakSelf.message.messageId];
                }
            }
        }
        weakSelf.progressBlock(progress);
    } completion:^(NSData *mediaData, NSError *error) {
        if (mediaData) {
            NSString *mediaPath = [MQChatFileUtil getVideoCachePathWithServerUrl:weakSelf.videoServerPath];
            if (![MQChatFileUtil fileExistsAtPath:mediaPath isDirectory:NO]) {
                [[NSFileManager defaultManager] createFileAtPath:mediaPath contents:mediaData attributes:nil];
            }
            weakSelf.message.videoPath = mediaPath;
            if (!weakSelf.isDownloading) {
                completion(mediaPath);
            }
        } else {
            [MQToast showToast:[MQBundleUtil localizedStringForKey:@"display_video_expired"] duration:1.5 window:[UIApplication sharedApplication].keyWindow];
        }
        weakSelf.isDownloading = NO;
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                [self.delegate didUpdateCellDataWithMessageId:self.message.messageId];
            }
        }
    }];
#else
    //非美洽SDK用户
    
#endif
}

//根据气泡中的图片生成其他model
- (void)setModelsWithContentImage:(UIImage *)contentImage
                          cellFromType:(MQChatMessageFromType)cellFromType
                        cellWidth:(CGFloat)cellWidth
{
    //限定图片的最大直径
    CGFloat maxContentImageWide = ceil(cellWidth / 2);  //限定图片的最大直径
    CGSize contentImageSize = contentImage ? contentImage.size : CGSizeMake(40, 30);

    //先限定图片宽度来计算高度
    CGFloat imageWidth = contentImageSize.width < maxContentImageWide ? contentImageSize.width : maxContentImageWide;
    CGFloat imageHeight = imageWidth * contentImageSize.height/contentImageSize.width;

    //根据消息的来源，进行处理
    UIImage *bubbleImage = [MQChatViewConfig sharedConfig].incomingBubbleImage;
    if ([MQChatViewConfig sharedConfig].incomingBubbleColor) {
        bubbleImage = [MQImageUtil convertImageColorWithImage:bubbleImage toColor:[MQChatViewConfig sharedConfig].incomingBubbleColor];
    }

    if (cellFromType == MQChatMessageOutgoing) {
        //发送出去的消息
        self.cellFromType = MQChatCellOutgoing;
        bubbleImage = [MQChatViewConfig sharedConfig].outgoingBubbleImage;
        if ([MQChatViewConfig sharedConfig].outgoingBubbleColor) {
            bubbleImage = [MQImageUtil convertImageColorWithImage:bubbleImage toColor:[MQChatViewConfig sharedConfig].outgoingBubbleColor];
        }
        //头像的frame
        if ([MQChatViewConfig sharedConfig].enableOutgoingAvatar) {
            self.avatarFrame = CGRectMake(cellWidth-kMQCellAvatarToHorizontalEdgeSpacing-kMQCellAvatarDiameter, kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarDiameter, kMQCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }

        //content内容
        self.contentImageViewFrame = CGRectMake(kMQCellBubbleToImageSpacing, kMQCellBubbleToImageSpacing, imageWidth, imageHeight);
        //气泡的frame
        self.bubbleFrame = CGRectMake(
                                           cellWidth - self.avatarFrame.size.width - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarToBubbleSpacing - imageWidth - 2 * kMQCellBubbleToImageSpacing,
                                           kMQCellAvatarToVerticalEdgeSpacing,
                                           imageWidth + 2 * kMQCellBubbleToImageSpacing,
                                           imageHeight + kMQCellBubbleToImageSpacing * 2);
    } else {
        //收到的消息
        self.cellFromType = MQChatCellIncoming;
        //头像的frame
        if ([MQChatViewConfig sharedConfig].enableIncomingAvatar) {
            self.avatarFrame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarDiameter, kMQCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }
        self.contentImageViewFrame = CGRectMake(kMQCellBubbleToImageSpacing, kMQCellBubbleToImageSpacing, imageWidth, imageHeight);
        //气泡的frame
        self.bubbleFrame = CGRectMake(
                                           self.avatarFrame.origin.x+self.avatarFrame.size.width+kMQCellAvatarToBubbleSpacing,
                                           self.avatarFrame.origin.y,
                                           imageWidth + kMQCellBubbleToImageSpacing * 2,
                                           imageHeight + kMQCellBubbleToImageSpacing * 2);
    }

    //playbtn的frame
    self.playBtnFrame = CGRectMake(self.bubbleFrame.size.width/2-kMQCellPlayBtnHeight/2, self.bubbleFrame.size.height/2-kMQCellPlayBtnHeight/2, kMQCellPlayBtnHeight, kMQCellPlayBtnHeight);
    
    //发送消息的indicator的frame
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kMQCellIndicatorDiameter, kMQCellIndicatorDiameter)];
    self.sendingIndicatorFrame = CGRectMake(self.bubbleFrame.origin.x-kMQCellBubbleToIndicatorSpacing-indicatorView.frame.size.width, self.bubbleFrame.origin.y+self.bubbleFrame.size.height/2-indicatorView.frame.size.height/2, indicatorView.frame.size.width, indicatorView.frame.size.height);
    
    //发送失败的图片frame
    UIImage *failureImage = [MQChatViewConfig sharedConfig].messageSendFailureImage;
    CGSize failureSize = CGSizeMake(ceil(failureImage.size.width * 2 / 3), ceil(failureImage.size.height * 2 / 3));
    self.sendFailureFrame = CGRectMake(self.bubbleFrame.origin.x-kMQCellBubbleToIndicatorSpacing-failureSize.width, self.bubbleFrame.origin.y+self.bubbleFrame.size.height/2-failureSize.height/2, failureSize.width, failureSize.height);

    //计算cell的高度
    self.cellHeight = self.bubbleFrame.origin.y + self.bubbleFrame.size.height + kMQCellAvatarToVerticalEdgeSpacing;

}

#pragma MQCellModelProtocol
- (CGFloat)getCellHeight {
    return self.cellHeight;
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (MQChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MQVideoMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.message.date;
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (NSString *)getCellMessageId {
    return self.message.messageId;
}

- (NSString *)getMessageConversionId {
    return self.message.conversionId;
}

- (void)updateCellSendStatus:(MQChatMessageSendStatus)sendStatus {
    self.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.message.messageId = messageId;
}

- (void)updateCellConversionId:(NSString *)conversionId {
    self.message.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.message.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    [self setModelsWithContentImage:self.thumbnail cellFromType:(MQChatMessageFromType)self.cellFromType cellWidth:cellWidth];
}

- (void)updateMediaServerPath:(NSString *)serverPath {
    self.videoPath = [MQChatFileUtil getVideoCachePathWithServerUrl:serverPath];
}

@end
