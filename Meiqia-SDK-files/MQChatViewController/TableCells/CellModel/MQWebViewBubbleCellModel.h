//
//  MQMQWebViewBubbleCellModel.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"
#import "MQTagListView.h"
#import "MQEmbededWebView.h"

@class MQRichTextMessage;
@interface MQWebViewBubbleCellModel : NSObject <MQCellModelProtocol>

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief 标签的tagList
 */
@property (nonatomic, readonly, strong) MQTagListView *cacheTagListView;

/**
 * @brief 标签的数据源
 */
@property (nonatomic, readonly, strong) NSArray *cacheTags;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readonly, assign) CGRect bubbleFrame;

/**
 * @brief 聊天气泡的image
 */
@property (nonatomic, readonly, copy) UIImage *bubbleImage;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readonly, copy) UIImage *avatarImage;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readonly, assign) CGRect avatarFrame;


@property (nonatomic, readonly, strong) MQEmbededWebView *contentWebView;

- (id)initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator;

@end
