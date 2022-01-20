//
//  MQMQWebViewBubbleCellModel.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQWebViewBubbleCellModel.h"
#import "MQWebViewBubbleCell.h"
#import "MQRichTextMessage.h"
#import "MQServiceToViewInterface.h"
#import "MQImageUtil.h"

@interface MQWebViewBubbleCellModel()

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 标签签的tagList
 */
@property (nonatomic, readwrite, strong) MQTagListView *cacheTagListView;
/**
 * @brief 标签的数据源
 */
@property (nonatomic, readwrite, strong) NSArray *cacheTags;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleFrame;

/**
 * @brief 聊天气泡的image
 */
@property (nonatomic, readwrite, copy) UIImage *bubbleImage;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

@property (nonatomic, readwrite, strong) MQEmbededWebView *contentWebView;

/**
 * @brief 该cellModel的委托对象
 */
@property (nonatomic, weak) id<MQCellModelDelegate> delegate;


@property (nonatomic, strong) MQRichTextMessage *message;

@property (nonatomic, assign) CGFloat webCacheHeight;

@end

@implementation MQWebViewBubbleCellModel

- (id)initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        self.delegate = delegator;
        
        if (message.userAvatarImage) {
            self.avatarImage = message.userAvatarImage;
        } else if (message.userAvatarPath.length > 0) {
            //这里使用美洽接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
            __weak typeof(self) weakSelf = self;
#ifdef INCLUDE_MEIQIA_SDK
            [MQServiceToViewInterface downloadMediaWithUrlString:message.userAvatarPath progress:^(float progress) {
            } completion:^(NSData *mediaData, NSError *error) {
                
                if (mediaData && !error) {
                    weakSelf.avatarImage = [UIImage imageWithData:mediaData];
                } else {
                    weakSelf.avatarImage = message.fromType == MQChatMessageIncoming ? [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage : [MQChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
                }
                if (weakSelf.delegate) {
                    if ([weakSelf.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        //通知ViewController去刷新tableView
                        [weakSelf.delegate didUpdateCellDataWithMessageId:weakSelf.message.messageId];
                    }
                }
            }];
#else
            __block UIImageView *tempImageView = [UIImageView new];
            [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.userAvatarPath] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                weakSelf.avatarImage = tempImageView.image.copy;
                if (weakSelf.delegate) {
                    if ([weakSelf.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        //通知ViewController去刷新tableView
                        [weakSelf.delegate didUpdateCellDataWithMessageId:weakSelf.message.messageId];
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
        
        if (message.tags) {
            CGFloat maxWidth = cellWidth - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarDiameter - kMQCellAvatarToBubbleSpacing - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing - kMQCellBubbleMaxWidthToEdgeSpacing;
            NSMutableArray *titleArr = [NSMutableArray array];
            for (MQMessageBottomTagModel * model in message.tags) {
                [titleArr addObject:model.name];
            }
            self.cacheTagListView = [[MQTagListView alloc] initWithTitleArray:titleArr andMaxWidth:maxWidth tagBackgroundColor:[UIColor colorWithWhite:1 alpha:0] tagTitleColor:[UIColor grayColor] tagFontSize:12.0 needBorder:YES];
            self.cacheTags = message.tags;
        }
        [self configUIWithCellWidth:cellWidth];
        __weak typeof(self) weakSelf = self;
        [self.contentWebView loadHTML:message.content WithCompletion:^(CGFloat height) {
            if (weakSelf.webCacheHeight != height) {
                weakSelf.webCacheHeight = height;
                if (weakSelf.delegate) {
                    if ([weakSelf.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        //通知ViewController去刷新tableView
                        [weakSelf configUIWithCellWidth:cellWidth];
                        [weakSelf.delegate didUpdateCellDataWithMessageId:weakSelf.message.messageId];
                    }
                }
            }
        }];
    }
    return self;
}

#pragma mark - Public


#pragma mark - Private

- (void)configUIWithCellWidth:(CGFloat)cellWidth
{
    //webView的宽度
    CGFloat webViewWidth = cellWidth - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarDiameter - kMQCellAvatarToBubbleSpacing - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing - kMQCellBubbleMaxWidthToEdgeSpacing;
    //webView的高度
    CGFloat webViewHeight = self.webCacheHeight > 0 ? self.webCacheHeight : 50;
    
    //气泡高度
    CGFloat bubbleHeight = webViewHeight;
    //气泡宽度
    CGFloat bubbleWidth = webViewWidth + kMQCellBubbleToTextHorizontalLargerSpacing + kMQCellBubbleToTextHorizontalSmallerSpacing;
    
    //根据消息的来源，进行处理
    UIImage *bubbleImage = [MQChatViewConfig sharedConfig].incomingBubbleImage;
    if ([MQChatViewConfig sharedConfig].incomingBubbleColor) {
        bubbleImage = [MQImageUtil convertImageColorWithImage:bubbleImage toColor:[MQChatViewConfig sharedConfig].incomingBubbleColor];
    }
    
    //收到的消息
    //头像的frame
    if ([MQChatViewConfig sharedConfig].enableIncomingAvatar) {
        self.avatarFrame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarDiameter, kMQCellAvatarDiameter);
    } else {
        self.avatarFrame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing, 0, 0);
    }
    
    //气泡的frame
    self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kMQCellAvatarToBubbleSpacing, self.avatarFrame.origin.y, bubbleWidth, bubbleHeight);
    //气泡图片
    self.bubbleImage = [bubbleImage resizableImageWithCapInsets:[MQChatViewConfig sharedConfig].bubbleImageStretchInsets];
    
    self.contentWebView.frame = CGRectMake(kMQCellBubbleToTextHorizontalLargerSpacing, 0, webViewWidth, webViewHeight);
    
    //计算cell的高度
    self.cellHeight = self.bubbleFrame.origin.y + self.bubbleFrame.size.height + kMQCellAvatarToVerticalEdgeSpacing + (self.cacheTagListView != nil ? self.cacheTagListView.frame.size.height + kMQCellBubbleToIndicatorSpacing : 0);
}


#pragma mark - MQCellModelProtocol


- (CGFloat)getCellHeight {
    return self.cellHeight > 0 ? self.cellHeight : 0;
}

- (MQWebViewBubbleCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MQWebViewBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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
    self.message.sendStatus = sendStatus;
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
    CGFloat maxWidth = cellWidth - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarDiameter - kMQCellAvatarToBubbleSpacing - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing - kMQCellBubbleMaxWidthToEdgeSpacing;
    [self.cacheTagListView updateLayoutWithMaxWidth:maxWidth];
    [self configUIWithCellWidth:cellWidth];
}

#pragma mark - 懒加载

- (MQEmbededWebView *)contentWebView {
    if (!_contentWebView) {
        _contentWebView = [MQEmbededWebView new];
        _contentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _contentWebView;
}

@end
