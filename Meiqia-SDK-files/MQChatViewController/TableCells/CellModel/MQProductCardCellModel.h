//
//  MQProductCardCellModel.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2021/9/2.
//  Copyright © 2021 2020 MeiQia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"
#import "MQProductCardMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQProductCardCellModel : NSObject <MQCellModelProtocol>

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readonly, strong) NSString *messageId;

/**
 * @brief 该cellModel的委托对象
 */
@property (nonatomic, weak) id<MQCellModelDelegate> delegate;

/**
 * @brief 图片image
 */
@property (nonatomic, readonly, strong) UIImage *image;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readonly, copy) NSDate *date;

/**
 * @brief 商品的title
 */
@property (nonatomic, readonly, copy) NSString *title;

/**
 * @brief 商品的描述内容
 */
@property (nonatomic, readonly, copy) NSString *desc;

/**
 * @brief 商品的销售量
 */
@property (nonatomic, readonly, assign) long saleCount;

/**
 * @brief 商品的url
 */
@property (nonatomic, readonly, copy) NSString *productUrl;

/**
 * @brief 商品图片的url
 */
@property (nonatomic, readonly, copy) NSString *productPictureUrl;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readonly, copy) UIImage *avatarImage;

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief bubble中的imageView的frame
 */
@property (nonatomic, readonly, assign) CGRect contentImageViewFrame;

/**
 * @brief bubble中的商品title的frame
 */
@property (nonatomic, readonly, assign) CGRect titleFrame;

/**
 * @brief bubble中的商品描述内容的frame
 */
@property (nonatomic, readonly, assign) CGRect descriptionFrame;

/**
 * @brief bubble中的商品销售量的frame
 */
@property (nonatomic, readonly, assign) CGRect saleCountFrame;

/**
 * @brief bubble中查看详情的frame
 */
@property (nonatomic, readonly, assign) CGRect linkFrame;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readonly, assign) CGRect bubbleFrame;

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
 * @brief 消息的发送状态
 */
@property (nonatomic, assign) MQChatMessageSendStatus sendStatus;

/**
 *  根据MQMessage内容来生成cell model
 */
- (MQProductCardCellModel *)initCellModelWithMessage:(MQProductCardMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<MQCellModelDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
