//
//  MQProductCardCellModel.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2021/9/2.
//  Copyright © 2021 2020 MeiQia. All rights reserved.
//

#import "MQProductCardCellModel.h"
#import "MQServiceToViewInterface.h"
#import "MQImageUtil.h"
#import "MQProductCardMessageCell.h"
#ifndef INCLUDE_MEIQIA_SDK
#import "UIImageView+WebCache.h"
#endif

/**
 * 聊天气泡和内容的留白间距
 */
static CGFloat const kMQCellBubbleToContentSpacing = 12.0;

/**
 * 文字内容的行间隔
 */
static CGFloat const kMQCellTextContentSpacing = 5.0;

/**
 * 商品title内容的高度
 */
static CGFloat const kMQCellTitleHeigh = 20.0;

/**
 * 商品描述内容的高度
 */
static CGFloat const kMQCellDescriptionHeigh = 35.0;

/**
 * 商品销售量内容的高度
 */
static CGFloat const kMQCellSaleCountHeigh = 18.0;

/**
 * 商品链接提示内容的宽度
 */
static CGFloat const kMQCellLinkWidth = 100.0;

/**
 * 图片的高宽比,宽4高3
 */
static CGFloat const kMQCellImageRatio = 0.75;

@interface MQProductCardCellModel()

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readwrite, strong) NSString *messageId;

/**
 * @brief 图片image(当imagePath不存在时使用)
 */
@property (nonatomic, readwrite, strong) UIImage *image;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 商品的title
 */
@property (nonatomic, readwrite, copy) NSString *title;

/**
 * @brief 商品的描述内容
 */
@property (nonatomic, readwrite, copy) NSString *desc;

/**
 * @brief 商品的销售量
 */
@property (nonatomic, readwrite, assign) long saleCount;

/**
 * @brief 商品的url
 */
@property (nonatomic, readwrite, copy) NSString *productUrl;

/**
 * @brief 商品图片的url
 */
@property (nonatomic, readwrite, copy) NSString *productPictureUrl;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief bubble中的imageView的frame
 */
@property (nonatomic, readwrite, assign) CGRect contentImageViewFrame;

/**
 * @brief bubble中的商品title的frame
 */
@property (nonatomic, readwrite, assign) CGRect titleFrame;

/**
 * @brief bubble中的商品描述内容的frame
 */
@property (nonatomic, readwrite, assign) CGRect descriptionFrame;

/**
 * @brief bubble中的商品销售量的frame
 */
@property (nonatomic, readwrite, assign) CGRect saleCountFrame;

/**
 * @brief bubble中查看详情的frame
 */
@property (nonatomic, readwrite, assign) CGRect linkFrame;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 发送出错图片的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendFailureFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readwrite, assign) MQChatCellFromType cellFromType;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell中消息的会话id
 */
@property (nonatomic, readwrite, strong) NSString *conversionId;

@end

@implementation MQProductCardCellModel

#pragma initialize
/**
 *  根据MQMessage内容来生成cell model
 */
- (MQProductCardCellModel *)initCellModelWithMessage:(MQProductCardMessage *)message
                                           cellWidth:(CGFloat)cellWidth
                                            delegate:(id<MQCellModelDelegate>)delegate
{
    if (self = [super init]) {
        self.cellWidth = cellWidth;
        self.delegate = delegate;
        self.sendStatus = message.sendStatus;
        self.productPictureUrl = message.pictureUrl;
        self.messageId = message.messageId;
        self.conversionId = message.conversionId;
        self.date = message.date;
        self.title = message.title;
        self.productUrl = message.productUrl;
        self.desc = message.desc;
        self.saleCount = message.salesCount;
        self.avatarPath = @"";
        self.cellHeight = 44.0;
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
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
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
        
        //内容图片
        if (message.pictureUrl.length > 0) {
            
            //默认cell高度为图片显示的最大高度
            self.cellHeight = cellWidth / 2;
            
            //                [self setModelsWithContentImage:[MQChatViewConfig sharedConfig].incomingBubbleImage cellFromType:message.fromType cellWidth:cellWidth];
            
            //这里使用美洽接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_MEIQIA_SDK
            [MQServiceToViewInterface downloadMediaWithUrlString:message.pictureUrl progress:^(float progress) {
            } completion:^(NSData *mediaData, NSError *error) {
                if (mediaData && !error) {
                    self.image = [UIImage imageWithData:mediaData];
                    [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                } else {
                    self.image = [MQChatViewConfig sharedConfig].imageLoadErrorImage;
                    [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
#else
            //非美洽SDK用户，使用了SDWebImage来做图片缓存
            __block UIImageView *tempImageView = [[UIImageView alloc] init];
            [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.pictureUrl] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (image) {
                    self.image = tempImageView.image.copy;
                    [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                } else {
                    self.image = [MQChatViewConfig sharedConfig].imageLoadErrorImage;
                    [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
#endif
        } else {
            self.image = [MQChatViewConfig sharedConfig].imageLoadErrorImage;
            [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
        }
    } else {
        [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
    }
    return self;
}

//根据气泡中的图片生成其他model
- (void)setModelsWithContentImage:(UIImage *)contentImage
                          cellFromType:(MQChatMessageFromType)cellFromType
                        cellWidth:(CGFloat)cellWidth
{
    //限定图片的最大直径
    CGFloat maxContentImageWide = ceil(cellWidth / 2);  //限定图片的最大直径
    
    //图片宽度固定
    CGFloat imageWidth = maxContentImageWide;
    CGFloat imageHeight = imageWidth * kMQCellImageRatio;
    
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
        
        //商品图片的frame
        self.contentImageViewFrame = CGRectMake(kMQCellBubbleToContentSpacing, kMQCellBubbleToContentSpacing, imageWidth, imageHeight);
        //商品title的frame
        self.titleFrame = CGRectMake(kMQCellBubbleToContentSpacing, kMQCellBubbleToContentSpacing + CGRectGetMaxY(self.contentImageViewFrame), imageWidth, kMQCellTitleHeigh);
        //商品描述内容的frame
        self.descriptionFrame = CGRectMake(kMQCellBubbleToContentSpacing, kMQCellTextContentSpacing + CGRectGetMaxY(self.titleFrame), imageWidth, kMQCellDescriptionHeigh);
        //商品销量的frame
        self.saleCountFrame = CGRectMake(kMQCellBubbleToContentSpacing, kMQCellTextContentSpacing + CGRectGetMaxY(self.descriptionFrame), imageWidth / 2.0, kMQCellSaleCountHeigh);
        //商品详情链接提示的frame
        self.linkFrame = CGRectMake(kMQCellBubbleToContentSpacing + imageWidth - kMQCellLinkWidth , CGRectGetMinY(self.saleCountFrame), kMQCellLinkWidth, kMQCellSaleCountHeigh);
        
        //气泡的frame
        self.bubbleFrame = CGRectMake(cellWidth - self.avatarFrame.size.width - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarToBubbleSpacing - imageWidth - 2 * kMQCellBubbleToContentSpacing,
                                      kMQCellAvatarToVerticalEdgeSpacing,
                                      imageWidth + 2 * kMQCellBubbleToContentSpacing,
                                      imageHeight + kMQCellBubbleToContentSpacing * 3 + kMQCellTextContentSpacing * 2 + kMQCellTitleHeigh + kMQCellDescriptionHeigh + kMQCellSaleCountHeigh);
    } else {
        //收到的消息
        self.cellFromType = MQChatCellIncoming;
        
        //头像的frame
        if ([MQChatViewConfig sharedConfig].enableIncomingAvatar) {
            self.avatarFrame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarDiameter, kMQCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }
        //商品图片的frame
        self.contentImageViewFrame = CGRectMake(kMQCellBubbleToContentSpacing, kMQCellBubbleToContentSpacing, imageWidth, imageHeight);
        //商品title的frame
        self.titleFrame = CGRectMake(kMQCellBubbleToContentSpacing, kMQCellBubbleToContentSpacing, imageWidth, kMQCellTitleHeigh);
        //商品描述内容的frame
        self.descriptionFrame = CGRectMake(kMQCellBubbleToContentSpacing, kMQCellTextContentSpacing, imageWidth, kMQCellDescriptionHeigh);
        //商品销量的frame
        self.saleCountFrame = CGRectMake(kMQCellBubbleToContentSpacing, kMQCellTextContentSpacing, imageWidth / 2.0, kMQCellSaleCountHeigh);
        //商品详情链接提示的frame
        self.linkFrame = CGRectMake(kMQCellBubbleToContentSpacing + imageWidth - kMQCellLinkWidth , kMQCellTextContentSpacing, kMQCellLinkWidth, kMQCellSaleCountHeigh);
        //气泡的frame
        self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kMQCellAvatarToBubbleSpacing,
                                      self.avatarFrame.origin.y,
                                      imageWidth + 2 * kMQCellBubbleToContentSpacing,
                                      imageHeight + kMQCellBubbleToContentSpacing * 3 + kMQCellTextContentSpacing * 2 + kMQCellTitleHeigh + kMQCellDescriptionHeigh + kMQCellSaleCountHeigh);
    }
    
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
    return self.cellHeight > 0 ? self.cellHeight : 0;
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (MQChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MQProductCardMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.date;
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (NSString *)getCellMessageId {
    return self.messageId;
}

- (NSString *)getMessageConversionId {
    return self.conversionId;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.messageId = messageId;
}

- (void)updateCellSendStatus:(MQChatMessageSendStatus)sendStatus {
    self.sendStatus = sendStatus;
}

- (void)updateCellConversionId:(NSString *)conversionId {
    self.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    [self setModelsWithContentImage:self.image cellFromType:(MQChatMessageFromType)self.cellFromType cellWidth:cellWidth];
}


@end
