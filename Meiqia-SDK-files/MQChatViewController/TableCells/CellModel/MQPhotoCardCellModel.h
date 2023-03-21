//
//  MQPhotoCardCellModel.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"
#import "MQPhotoCardMessage.h"
#import "MQPhotoCardMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQPhotoCardCellModel : NSObject <MQCellModelProtocol>

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readonly, strong) NSString *messageId;

/**
 * @brief 用户名字，暂时没用
 */
@property (nonatomic, readonly, copy) NSString *userName;

/**
 * @brief 该cellModel的委托对象
 */
@property (nonatomic, weak) id<MQCellModelDelegate> delegate;

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief 图片image(当imagePath不存在时使用)
 */
@property (nonatomic, readonly, strong) UIImage *image;

/**
 * bubble中的imageView的frame
 */
@property (nonatomic, readonly, assign) CGRect contentImageViewFrame;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readonly, copy) NSDate *date;

/**
 * @brief 操作目标的Path
 */
@property (nonatomic, readonly, copy) NSString *targetUrl;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readonly, copy) UIImage *avatarImage;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readonly, assign) CGRect bubbleFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readonly, assign) CGRect avatarFrame;

/**
 * @brief 读取照片的指示器的frame
 */
@property (nonatomic, readonly, assign) CGRect loadingIndicatorFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readonly, assign) MQChatCellFromType cellFromType;


/**
 *  根据MQMessage内容来生成cell model
 */
- (MQPhotoCardCellModel *)initCellModelWithMessage:(MQPhotoCardMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<MQCellModelDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
