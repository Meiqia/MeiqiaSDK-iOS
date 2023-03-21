//
//  MQBotHighMenuCellModel.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/12/28.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"
#import "MQBotHighMenuMessage.h"
#import "MQPageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQBotHighMenuCellModel : NSObject <MQCellModelProtocol>

/**
 * @brief 该cellModel的委托对象
 */
@property (nonatomic, weak) id<MQCellModelDelegate> delegate;

/**
 * @brief cell中问题menu的View
 */
@property (nonatomic, readonly, strong) MQPageView *pageView;

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readonly, strong) NSString *messageId;

/**
 * @brief 用户名字，暂时没用
 */
@property (nonatomic, readonly, copy) NSString *userName;

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readonly, assign) CGFloat cellWidth;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readonly, copy) NSDate *date;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readonly, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readonly, copy) UIImage *avatarImage;

/**
 * @brief 聊天气泡的image
 */
@property (nonatomic, readonly, copy) UIImage *bubbleImage;

/**
 * @brief 消息气泡的frame
 */
@property (nonatomic, readonly, assign) CGRect bubbleImageFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readonly, assign) CGRect avatarFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readonly, assign) MQChatCellFromType cellFromType;

/**
 * @brief 「常见问题」label frame
 */
@property (nonatomic, readonly, assign) CGRect menuTipLabelFrame;

/**
 * @brief 「常见问题」label text
 */
@property (nonatomic, readonly, copy) NSString *menuTipText;

/**
 * @brief 消息的发送状态
 */
@property (nonatomic, assign) MQChatMessageSendStatus sendStatus;

/**
 * @brief 消息的文字
 */
@property (nonatomic, readonly, copy) NSAttributedString *cellText;

/**
 * @brief 消息气泡中的文字的frame
 */
@property (nonatomic, readonly, assign) CGRect textLabelFrame;

/**
 * @brief menu的背景View的frame
 */
@property (nonatomic, readonly, assign) CGRect menuBackFrame;

/**
 *  根据MQMessage内容来生成cell model
 */
- (MQBotHighMenuCellModel *)initCellModelWithMessage:(MQBotHighMenuMessage *)message
                                       cellWidth:(CGFloat)cellWidth
                                        delegate:(id<MQCellModelDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
