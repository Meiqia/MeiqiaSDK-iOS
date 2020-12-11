//
//  MQVideoCellModel.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/23.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"
#import "MQVideoMessage.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat const kMQCellPlayBtnHeight = 60.0;

typedef void (^VideoDownloadProgress)(float progress);

@interface MQVideoCellModel : NSObject <MQCellModelProtocol>

@property (nonatomic, copy) VideoDownloadProgress progressBlock;

/**
 * @brief 该cellModel的委托对象
 */
@property (nonatomic, weak) id<MQCellModelDelegate> delegate;

/**
 * bubble中的imageView的frame
 */
@property (nonatomic, readonly, assign) CGRect contentImageViewFrame;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readonly, assign) CGRect bubbleFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readonly, assign) CGRect avatarFrame;

/**
 * @brief 播放按钮的frame
 */
@property (nonatomic, readonly, assign) CGRect playBtnFrame;

/**
 * @brief 发送失败图标的frame
 */
@property (nonatomic, readonly, assign) CGRect sendFailureFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readonly, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readonly, strong) UIImage *avatarImage;

/**
 * @brief 视频第一帧的图片
 */
@property (nonatomic, readonly, strong) UIImage *thumbnail;

/**
 * @brief 视频本地路径
 */
@property (nonatomic, readonly, copy) NSString *videoPath;

/**
 * @brief 视频服务器路径
 */
@property (nonatomic, readonly, copy) NSString *videoServerPath;

/**
 * @brief 消息的发送状态
 */
@property (nonatomic, readonly, assign) MQChatMessageSendStatus sendStatus;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readonly, assign) MQChatCellFromType cellFromType;

/**
 * @brief 是否正在下载视频
 */
@property (nonatomic, readonly, assign) BOOL isDownloading;

- (MQVideoCellModel *)initCellModelWithMessage:(MQVideoMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<MQCellModelDelegate>)delegate;

- (void)startDownloadMediaCompletion:(void (^)(NSString *mediaPath))completion;

@end

NS_ASSUME_NONNULL_END
