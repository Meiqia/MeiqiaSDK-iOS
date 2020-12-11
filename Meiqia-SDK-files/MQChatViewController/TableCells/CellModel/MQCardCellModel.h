//
//  MQCardCellModel.h
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/25.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"
#import "MQCardMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQCardCellModel : NSObject <MQCellModelProtocol>

@property (nonatomic, strong) NSArray *cardData;

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readonly, strong) NSString *messageId;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readonly, copy) NSDate *date;

/**
 * @brief 该cellModel的委托对象
 */
@property (nonatomic, weak) id<MQCellModelDelegate> delegate;

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readonly, assign) CGFloat cellWidth;

/**
 * @brief 消息的文字
 */
@property (nonatomic, readonly, copy) NSAttributedString *cellText;

/**
 * @brief 消息的文字属性
 */
@property (nonatomic, readonly, copy) NSDictionary *cellTextAttributes;

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
 * @brief 消息气泡中的文字的frame
 */
@property (nonatomic, readonly, assign) CGRect textLabelFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readonly, assign) CGRect avatarFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readonly, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 发送出错图片的frame
 */
@property (nonatomic, readonly, assign) CGRect sendFailureFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readonly, assign) MQChatCellFromType cellFromType;

/**
 * @brief 消息文字中，数字选中识别的字典 [number : range]
 */
@property (nonatomic, readonly, strong) NSDictionary *numberRangeDic;

/**
 * @brief 消息文字中，url选中识别的字典 [url : range]
 */
@property (nonatomic, readonly, strong) NSDictionary *linkNumberRangeDic;

/**
 * @brief 消息文字中，email选中识别的字典 [email : range]
 */
@property (nonatomic, readonly, strong) NSDictionary *emailNumberRangeDic;

/**
 * @brief 消息的发送状态
 */
@property (nonatomic, assign) MQChatMessageSendStatus sendStatus;


- (MQCardCellModel *)initCellModelWithMessage:(MQCardMessage *)message
cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator;

@end

NS_ASSUME_NONNULL_END
