 //
//  MQBotAnswerCellModel.m
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 16/4/27.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQBotAnswerCellModel.h"
#import "MQBotAnswerCell.h"
#import "MQChatBaseCell.h"
#import "MQChatFileUtil.h"
#import "MQStringSizeUtil.h"
#import <UIKit/UIKit.h>
#import "MQChatViewConfig.h"
#import "MQImageUtil.h"
#import "MEIQIA_TTTAttributedLabel.h"
#import "MQChatEmojize.h"
#import "MQServiceToViewInterface.h"

static CGFloat const kMQBotAnswerEvaluateBtnHeight = 40.0;
static CGFloat const kMQBotAnswerEvaluateUpperLineLeftOffset = 7.5;
static CGFloat const kMQBotAnswerEvaluateBubbleMinWidth = 144.0;


@interface MQBotAnswerCellModel()

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readwrite, strong) NSString *messageId;

/**
 * @brief 消息的文字
 */
@property (nonatomic, readwrite, copy) NSAttributedString *cellText;

/**
 * @brief 消息的文字属性
 */
@property (nonatomic, readwrite, copy) NSDictionary *cellTextAttributes;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片名字
 */
@property (nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief 用户名字，暂时没用
 */
@property (nonatomic, readwrite, copy) NSString *userName;

/**
 * @brief 聊天气泡的image
 */
@property (nonatomic, readwrite, copy) UIImage *bubbleImage;

/**
 * @brief 消息气泡的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleImageFrame;

/**
 * @brief 消息气泡中的文字的frame
 */
@property (nonatomic, readwrite, assign) CGRect textLabelFrame;

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
 * @brief 消息文字中，数字选中识别的字典 [number : range]
 */
@property (nonatomic, readwrite, strong) NSDictionary *numberRangeDic;

/**
 * @brief 消息文字中，url选中识别的字典 [url : range]
 */
@property (nonatomic, readwrite, strong) NSDictionary *linkNumberRangeDic;

/**
 * @brief 消息文字中，email选中识别的字典 [email : range]
 */
@property (nonatomic, readwrite, strong) NSDictionary *emailNumberRangeDic;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 「有用」「无用」上方的线条 frame
 */
@property (nonatomic, readwrite, assign) CGRect evaluateUpperLineFrame;

/**
 * @brief 「有用」「无用」中间的线条 frame
 */
@property (nonatomic, readwrite, assign) CGRect evaluateMiddleLineFrame;

/**
 * @brief 「有用」按钮的 frame
 */
@property (nonatomic, readwrite, assign) CGRect positiveBtnFrame;

/**
 * @brief 「无用」按钮的 frame
 */
@property (nonatomic, readwrite, assign) CGRect negativeBtnFrame;

/**
 * @brief 「留言」按钮的 frame
 */
@property (nonatomic, readwrite, assign) CGRect replyBtnFrame;

/**
 * @brief 「已反馈」按钮的 frame
 */
@property (nonatomic, readwrite, assign) CGRect evaluateDoneBtnFrame;

/**
 * @brief 是否已反馈标记
 */
@property (nonatomic, readwrite, assign) BOOL isEvaluated;

/**
 * @brief 消息的 sub type
 */
@property (nonatomic, readwrite, copy) NSString *messageSubType;

/**
 * @brief 普通类型的集合
 */
@property (nonatomic, readwrite, copy) NSArray *normalSubTypes;

@end

@implementation MQBotAnswerCellModel

- (MQBotAnswerCellModel *)initCellModelWithMessage:(MQBotAnswerMessage *)message
                                    cellWidth:(CGFloat)cellWidth
                                     delegate:(id<MQCellModelDelegate>)delegator
{
    if (self = [super init]) {
        self.normalSubTypes = @[@"redirect", @"manual_redirect"];
        self.messageSubType = message.subType;
        self.isEvaluated = message.isEvaluated;
        self.messageId = message.messageId;
        self.sendStatus = message.sendStatus;
        NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        contentParagraphStyle.lineSpacing = kMQTextCellLineSpacing;
        contentParagraphStyle.lineHeightMultiple = 1.0;
        contentParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        contentParagraphStyle.alignment = NSTextAlignmentLeft;
        NSMutableDictionary *contentAttributes
        = [[NSMutableDictionary alloc]
           initWithDictionary:@{
                                NSParagraphStyleAttributeName : contentParagraphStyle,
                                NSFontAttributeName : [UIFont systemFontOfSize:kMQCellTextFontSize]
                                }];
        if (message.fromType == MQChatMessageOutgoing) {
            [contentAttributes setObject:(__bridge id)[MQChatViewConfig sharedConfig].outgoingMsgTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
        } else {
            [contentAttributes setObject:(__bridge id)[MQChatViewConfig sharedConfig].incomingMsgTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
        }
        self.cellTextAttributes = [[NSDictionary alloc] initWithDictionary:contentAttributes];
        self.cellText = [[NSAttributedString alloc] initWithString:message.content ?: @"" attributes:self.cellTextAttributes];
        self.date = message.date;
        self.cellHeight = 44.0;
        self.delegate = delegator;
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
        
        //文字最大宽度
        CGFloat maxLabelWidth = cellWidth - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarDiameter - kMQCellAvatarToBubbleSpacing - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing - kMQCellBubbleMaxWidthToEdgeSpacing;
        //文字高度
        CGFloat messageTextHeight = [MQStringSizeUtil getHeightForAttributedText:self.cellText textWidth:maxLabelWidth];
        //判断文字中是否有emoji
        if ([MQChatEmojize stringContainsEmoji:[self.cellText string]]) {
            NSAttributedString *oneLineText = [[NSAttributedString alloc] initWithString:@"haha" attributes:self.cellTextAttributes];
            CGFloat oneLineTextHeight = [MQStringSizeUtil getHeightForAttributedText:oneLineText textWidth:maxLabelWidth];
            NSInteger textLines = ceil(messageTextHeight / oneLineTextHeight);
            messageTextHeight += 8 * textLines;
        }
        //文字宽度
        CGFloat messageTextWidth = [MQStringSizeUtil getWidthForAttributedText:self.cellText textHeight:messageTextHeight];
        //#warning 注：这里textLabel的宽度之所以要增加，是因为TTTAttributedLabel的bug，在文字有"."的情况下，有可能显示不出来，开发者可以帮忙定位TTTAttributedLabel的这个bug^.^
        NSRange periodRange = [message.content rangeOfString:@"."];
        if (periodRange.location != NSNotFound) {
            messageTextWidth += 8;
        }
        if (messageTextWidth > maxLabelWidth) {
            messageTextWidth = maxLabelWidth;
        }
        //气泡高度
        CGFloat bubbleHeight = messageTextHeight + kMQCellBubbleToTextVerticalSpacing * 2;
        //气泡宽度
        CGFloat bubbleWidth = messageTextWidth + kMQCellBubbleToTextHorizontalLargerSpacing + kMQCellBubbleToTextHorizontalSmallerSpacing;
        if (![self.normalSubTypes containsObject:self.messageSubType]) {
            bubbleHeight += kMQBotAnswerEvaluateBtnHeight;
            bubbleWidth = bubbleWidth < kMQBotAnswerEvaluateBubbleMinWidth ? kMQBotAnswerEvaluateBubbleMinWidth : bubbleWidth;
            messageTextWidth = bubbleWidth - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing;
        }
        
        //根据消息的来源，进行处理
        UIImage *bubbleImage = [MQChatViewConfig sharedConfig].incomingBubbleImage;
        if ([MQChatViewConfig sharedConfig].incomingBubbleColor) {
            bubbleImage = [MQImageUtil convertImageColorWithImage:bubbleImage toColor:[MQChatViewConfig sharedConfig].incomingBubbleColor];
        }
        if (message.fromType == MQChatMessageOutgoing) {
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
                self.avatarFrame = CGRectMake(cellWidth-kMQCellAvatarToHorizontalEdgeSpacing-kMQCellAvatarDiameter, kMQCellAvatarToVerticalEdgeSpacing, 0, 0);
            }
            //气泡的frame
            self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kMQCellAvatarToHorizontalEdgeSpacing-kMQCellAvatarToBubbleSpacing-bubbleWidth, kMQCellAvatarToVerticalEdgeSpacing, bubbleWidth, bubbleHeight);
            //文字的frame
            self.textLabelFrame = CGRectMake(kMQCellBubbleToTextHorizontalSmallerSpacing, kMQCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
        } else {
            //收到的消息
            self.cellFromType = MQChatCellIncoming;
            
            //头像的frame
            if ([MQChatViewConfig sharedConfig].enableIncomingAvatar) {
                self.avatarFrame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarDiameter, kMQCellAvatarDiameter);
            } else {
                self.avatarFrame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing, 0, 0);
            }
            //气泡的frame
            self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kMQCellAvatarToBubbleSpacing, self.avatarFrame.origin.y, bubbleWidth, bubbleHeight);
            //文字的frame
            self.textLabelFrame = CGRectMake(kMQCellBubbleToTextHorizontalLargerSpacing, kMQCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
        }
        
        //气泡图片
        self.bubbleImage = [bubbleImage resizableImageWithCapInsets:[MQChatViewConfig sharedConfig].bubbleImageStretchInsets];
        
        //发送消息的indicator的frame
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kMQCellIndicatorDiameter, kMQCellIndicatorDiameter)];
        self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMQCellBubbleToIndicatorSpacing-indicatorView.frame.size.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-indicatorView.frame.size.height/2, indicatorView.frame.size.width, indicatorView.frame.size.height);
        
        //发送失败的图片frame
        UIImage *failureImage = [MQChatViewConfig sharedConfig].messageSendFailureImage;
        CGSize failureSize = CGSizeMake(ceil(failureImage.size.width * 2 / 3), ceil(failureImage.size.height * 2 / 3));
        self.sendFailureFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMQCellBubbleToIndicatorSpacing-failureSize.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-failureSize.height/2, failureSize.width, failureSize.height);
        
        //匹配消息文字中的正则
        //数字正则匹配
        NSMutableDictionary *numberRegexDic = [[NSMutableDictionary alloc] init];
        for (NSString *numberRegex in [MQChatViewConfig sharedConfig].numberRegexs) {
            NSRange range = [message.content rangeOfString:numberRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [numberRegexDic setValue:[NSValue valueWithRange:range] forKey:[message.content substringWithRange:range]];
            }
        }
        self.numberRangeDic = numberRegexDic;
        //链接正则匹配
        NSMutableDictionary *linkRegexDic = [[NSMutableDictionary alloc] init];
        for (NSString *linkRegex in [MQChatViewConfig sharedConfig].linkRegexs) {
            NSRange range = [message.content rangeOfString:linkRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [linkRegexDic setValue:[NSValue valueWithRange:range] forKey:[message.content substringWithRange:range]];
            }
        }
        self.linkNumberRangeDic = linkRegexDic;
        //email正则匹配
        NSMutableDictionary *emailRegexDic = [[NSMutableDictionary alloc] init];
        for (NSString *emailRegex in [MQChatViewConfig sharedConfig].emailRegexs) {
            NSRange range = [message.content rangeOfString:emailRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [emailRegexDic setValue:[NSValue valueWithRange:range] forKey:[message.content substringWithRange:range]];
            }
        }
        self.emailNumberRangeDic = emailRegexDic;
        
        // button上线条 frame
        self.evaluateUpperLineFrame = CGRectMake(kMQBotAnswerEvaluateUpperLineLeftOffset, bubbleHeight-kMQBotAnswerEvaluateBtnHeight, bubbleWidth-kMQBotAnswerEvaluateUpperLineLeftOffset, 0.5);
        
        if ([message.subType isEqualToString:@"reply"]) {
            // 若机器人消息 sub type 为「留言」，则渲染成留言留言样式
            //「有用」button frame
            self.replyBtnFrame = CGRectMake(kMQBotAnswerEvaluateUpperLineLeftOffset, self.evaluateUpperLineFrame.origin.y, bubbleWidth-kMQBotAnswerEvaluateUpperLineLeftOffset, kMQBotAnswerEvaluateBtnHeight);
        } else if ([message.subType isEqualToString:@"evaluate"]) {
            // 若机器人消息 sub type 为「评价」，则渲染成评价消息样式
            
            //「有用」「无用」button中间线条 frame
            self.evaluateMiddleLineFrame = CGRectMake((bubbleWidth-kMQBotAnswerEvaluateUpperLineLeftOffset)/2 + kMQBotAnswerEvaluateUpperLineLeftOffset, self.evaluateUpperLineFrame.origin.y+self.evaluateUpperLineFrame.size.height, 0.5, kMQBotAnswerEvaluateBtnHeight);
            //「有用」button frame
            self.positiveBtnFrame = CGRectMake(kMQBotAnswerEvaluateUpperLineLeftOffset, self.evaluateMiddleLineFrame.origin.y, (bubbleWidth-kMQBotAnswerEvaluateUpperLineLeftOffset)/2, kMQBotAnswerEvaluateBtnHeight);
            //「无用」button frame
            self.negativeBtnFrame = CGRectMake(self.evaluateMiddleLineFrame.origin.x+self.evaluateMiddleLineFrame.size.width, self.evaluateMiddleLineFrame.origin.y, (bubbleWidth-kMQBotAnswerEvaluateUpperLineLeftOffset)/2, kMQBotAnswerEvaluateBtnHeight);
            //「已反馈」button frame
            self.evaluateDoneBtnFrame = CGRectMake(0, self.evaluateMiddleLineFrame.origin.y, bubbleWidth, kMQBotAnswerEvaluateBtnHeight);
        }
        
        //计算cell的高度
        self.cellHeight = self.bubbleImageFrame.origin.y + self.bubbleImageFrame.size.height + kMQCellAvatarToVerticalEdgeSpacing;
    }
    return self;
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
    return [[MQBotAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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

- (void)updateCellSendStatus:(MQChatMessageSendStatus)sendStatus {
    self.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.messageId = messageId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    //文字最大宽度
    CGFloat maxLabelWidth = cellWidth - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarDiameter - kMQCellAvatarToBubbleSpacing - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing - kMQCellBubbleMaxWidthToEdgeSpacing;
    //文字高度
    CGFloat messageTextHeight = [MQStringSizeUtil getHeightForAttributedText:self.cellText textWidth:maxLabelWidth];
    //判断文字中是否有emoji
    if ([MQChatEmojize stringContainsEmoji:[self.cellText string]]) {
        NSAttributedString *oneLineText = [[NSAttributedString alloc] initWithString:@"haha" attributes:self.cellTextAttributes];
        CGFloat oneLineTextHeight = [MQStringSizeUtil getHeightForAttributedText:oneLineText textWidth:maxLabelWidth];
        NSInteger textLines = ceil(messageTextHeight / oneLineTextHeight);
        messageTextHeight += 8 * textLines;
    }
    //文字宽度
    CGFloat messageTextWidth = [MQStringSizeUtil getWidthForAttributedText:self.cellText textHeight:messageTextHeight];
    //#warning 注：这里textLabel的宽度之所以要增加，是因为TTTAttributedLabel的bug，在文字有"."的情况下，有可能显示不出来，开发者可以帮忙定位TTTAttributedLabel的这个bug^.^
    NSRange periodRange = [self.cellText.string rangeOfString:@"."];
    if (periodRange.location != NSNotFound) {
        messageTextWidth += 8;
    }
    if (messageTextWidth > maxLabelWidth) {
        messageTextWidth = maxLabelWidth;
    }
    //气泡高度
    CGFloat bubbleHeight = messageTextHeight + kMQCellBubbleToTextVerticalSpacing * 2;
    //气泡宽度
    CGFloat bubbleWidth = messageTextWidth + kMQCellBubbleToTextHorizontalLargerSpacing + kMQCellBubbleToTextHorizontalSmallerSpacing;
    if (![self.normalSubTypes containsObject:self.messageSubType]) {
        bubbleHeight += kMQBotAnswerEvaluateBtnHeight;
        bubbleWidth = bubbleWidth < kMQBotAnswerEvaluateBubbleMinWidth ? kMQBotAnswerEvaluateBubbleMinWidth : bubbleWidth;
        messageTextWidth = bubbleWidth - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing;
    }

    //根据消息的来源，进行处理
    UIImage *bubbleImage = [MQChatViewConfig sharedConfig].incomingBubbleImage;
    if ([MQChatViewConfig sharedConfig].incomingBubbleColor) {
        bubbleImage = [MQImageUtil convertImageColorWithImage:bubbleImage toColor:[MQChatViewConfig sharedConfig].incomingBubbleColor];
    }
    if (self.cellFromType == MQChatMessageOutgoing) {
        //发送出去的消息
        bubbleImage = [MQChatViewConfig sharedConfig].outgoingBubbleImage;
        if ([MQChatViewConfig sharedConfig].outgoingBubbleColor) {
            bubbleImage = [MQImageUtil convertImageColorWithImage:self.bubbleImage toColor:[MQChatViewConfig sharedConfig].outgoingBubbleColor];
        }
        
        //头像的frame
        if ([MQChatViewConfig sharedConfig].enableOutgoingAvatar) {
            self.avatarFrame = CGRectMake(cellWidth-kMQCellAvatarToHorizontalEdgeSpacing-kMQCellAvatarDiameter, kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarDiameter, kMQCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(cellWidth-kMQCellAvatarToHorizontalEdgeSpacing-kMQCellAvatarDiameter, kMQCellAvatarToVerticalEdgeSpacing, 0, 0);
        }
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kMQCellAvatarToHorizontalEdgeSpacing-kMQCellAvatarToBubbleSpacing-bubbleWidth, kMQCellAvatarToVerticalEdgeSpacing, bubbleWidth, bubbleHeight);
        //文字的frame
        self.textLabelFrame = CGRectMake(kMQCellBubbleToTextHorizontalSmallerSpacing, kMQCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
    } else {
        //收到的消息
        
        //头像的frame
        if ([MQChatViewConfig sharedConfig].enableIncomingAvatar) {
            self.avatarFrame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarDiameter, kMQCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing, 0, 0);
        }
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kMQCellAvatarToBubbleSpacing, self.avatarFrame.origin.y, bubbleWidth, bubbleHeight);
        //文字的frame
        self.textLabelFrame = CGRectMake(kMQCellBubbleToTextHorizontalLargerSpacing, kMQCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
    }
    //气泡图片
    self.bubbleImage = [bubbleImage resizableImageWithCapInsets:[MQChatViewConfig sharedConfig].bubbleImageStretchInsets];
    
    
    // button上线条 frame
    self.evaluateUpperLineFrame = CGRectMake(kMQBotAnswerEvaluateUpperLineLeftOffset, bubbleHeight-kMQBotAnswerEvaluateBtnHeight, bubbleWidth-kMQBotAnswerEvaluateUpperLineLeftOffset, 0.5);
    
    if ([self.messageSubType isEqualToString:@"reply"]) {
        // 若机器人消息 sub type 为「留言」，则渲染成留言留言样式
        self.replyBtnFrame = CGRectMake(kMQBotAnswerEvaluateUpperLineLeftOffset, self.evaluateUpperLineFrame.origin.y, bubbleWidth-kMQBotAnswerEvaluateUpperLineLeftOffset, kMQBotAnswerEvaluateBtnHeight);
    } else if ([self.messageSubType isEqualToString:@"evaluate"]) {
        // 若机器人消息 sub type 为「评价」，则渲染成评价消息样式
        //「有用」「无用」button中间线条 frame
        self.evaluateMiddleLineFrame = CGRectMake((bubbleWidth-kMQBotAnswerEvaluateUpperLineLeftOffset)/2 + kMQBotAnswerEvaluateUpperLineLeftOffset, self.evaluateUpperLineFrame.origin.y+self.evaluateUpperLineFrame.size.height, 0.5, kMQBotAnswerEvaluateBtnHeight);
        //「有用」button frame
        self.positiveBtnFrame = CGRectMake(kMQBotAnswerEvaluateUpperLineLeftOffset, self.evaluateMiddleLineFrame.origin.y, (bubbleWidth-kMQBotAnswerEvaluateUpperLineLeftOffset)/2, kMQBotAnswerEvaluateBtnHeight);
        //「无用」button frame
        self.negativeBtnFrame = CGRectMake(self.evaluateMiddleLineFrame.origin.x+self.evaluateMiddleLineFrame.size.width, self.evaluateMiddleLineFrame.origin.y, (bubbleWidth-kMQBotAnswerEvaluateUpperLineLeftOffset)/2, kMQBotAnswerEvaluateBtnHeight);
        //「已反馈」button frame
        self.evaluateDoneBtnFrame = CGRectMake(0, self.evaluateMiddleLineFrame.origin.y, bubbleWidth, kMQBotAnswerEvaluateBtnHeight);
    }
}

- (void)updateOutgoingAvatarImage:(UIImage *)avatarImage {
    if (self.cellFromType == MQChatCellOutgoing) {
        self.avatarImage = avatarImage;
    }
}

- (void)didEvaluate {
    self.isEvaluated = true;
}



@end
