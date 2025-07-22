//
//  MQBotHighMenuRichCellModel.m
//  MQEcoboostSDK-test
//
//  Created by Cassie on 2023/9/12.
//  Copyright © 2023 MeiQia Inc. All rights reserved.
//

#import "MQBotHighMenuRichCellModel.h"
#import "MQBotHighMenuRichCell.h"
#import "MQChatViewConfig.h"
#import "MQServiceToViewInterface.h"
#import "MQImageUtil.h"
#import "MQBundleUtil.h"
#import "MQStringSizeUtil.h"
#import "TTTAttributedLabel.h"

/**
 *常见问题标题的高度
 */
static CGFloat const kMQBotHighMenuTitleHeight = 30;

@interface MQBotHighMenuRichCellModel ()

/**
 * @brief cell中问题menu的View
 */
@property (nonatomic, readwrite, strong) MQPageView *pageView;
/**
 * @brief cell中消息的id
 */
@property (nonatomic, readwrite, strong) NSString *messageId;

/**
 * @brief 用户名字，暂时没用
 */
@property (nonatomic, readwrite, copy) NSString *userName;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief 聊天气泡的image
 */
@property (nonatomic, readwrite, copy) UIImage *bubbleImage;

/**
 * @brief 消息气泡的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleImageFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readwrite, assign) MQChatCellFromType cellFromType;

/**
 * @brief 「常见问题」label frame
 */
@property (nonatomic, readwrite, assign) CGRect menuTipLabelFrame;

/**
 * @brief 「常见问题」label text
 */
@property (nonatomic, readwrite, copy) NSString *menuTipText;

/**
 * @brief 消息的文字
 */
@property (nonatomic, readwrite, copy) NSAttributedString *cellText;

/**
 * @brief 富文本
 */
@property (nonatomic, readwrite, copy) NSString *richText;

/**
 * @brief 消息的文字属性
 */
@property (nonatomic, readwrite, copy) NSDictionary *cellTextAttributes;

/**
 * @brief 消息气泡中的文字的frame
 */
@property (nonatomic, readwrite, assign) CGRect textLabelFrame;

/**
 * @brief menu的背景View的frame
 */
@property (nonatomic, readwrite, assign) CGRect menuBackFrame;

/**
 * @brief cell中消息的会话id
 */
@property (nonatomic, readwrite, strong) NSString *conversionId;

@end

@implementation MQBotHighMenuRichCellModel

- (MQBotHighMenuRichCellModel *)initCellModelWithMessage:(MQBotHighMenuMessage *)message cellWidth:(CGFloat)cellWidth delegate:(nonnull id<MQCellModelDelegate>)delegate {
    if (self = [super init]) {
        self.messageId = message.messageId;
        self.conversionId = message.conversionId;
        self.sendStatus = message.sendStatus;
        
        self.menuTipText = [MQBundleUtil localizedStringForKey:@"bot_menu_problem_tip_text"];
        //文字最大宽度
        CGFloat maxLabelWidth = cellWidth - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarDiameter - kMQCellAvatarToBubbleSpacing - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing - kMQCellBubbleMaxWidthToEdgeSpacing;
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
        if (message.richContent && message.richContent.length > 0) {
            NSString *str = [NSString stringWithFormat:@"<head><style>img{width:%f !important;height:auto}p{font-size:%fpx}</style></head>%@",maxLabelWidth,kMQCellTextFontSize,message.richContent];
                NSAttributedString *attributeString=[[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
            self.cellText = attributeString;
        } else {
            self.cellText = [[NSAttributedString alloc] initWithString:message.content attributes:self.cellTextAttributes];
        }
        self.richText = message.richContent;
        self.date = message.date;
        self.cellHeight = 44.0;
        self.delegate = delegate;
        
        self.avatarImage = [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage;
        if (message.fromType == MQChatMessageOutgoing) {
            self.avatarImage = [MQChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
        }
        
        if (message.userAvatarImage) {
            self.avatarImage = message.userAvatarImage;
        } else if (message.userAvatarPath.length > 0) {
            self.avatarPath = message.userAvatarPath;
            //这里使用美洽接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略

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
        }
        
        //文字高度
        CGFloat messageTextHeight = [MQStringSizeUtil getHeightForAttributedText:self.cellText textWidth:maxLabelWidth];
        
        // 对于富文本，使用更精确的高度计算和适度的缓冲
        if (message.richContent && message.richContent.length > 0) {
            // 使用 boundingRectWithSize 获取更精确的高度
            CGSize constraintSize = CGSizeMake(maxLabelWidth, CGFLOAT_MAX);
            CGRect textRect = [self.cellText boundingRectWithSize:constraintSize
                                                         options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                         context:nil];
            CGFloat preciseHeight = ceil(textRect.size.height);
            
            // 智能判断是否需要额外高度
            CGFloat maxHeight = MAX(messageTextHeight, preciseHeight);
            CGFloat minHeight = MIN(messageTextHeight, preciseHeight);
            CGFloat heightDiff = maxHeight - minHeight;
            
            // NSLog(@"🔍 富文本高度分析 - MQStringSizeUtil: %.1f, boundingRect: %.1f, 差异: %.1f, 最大高度: %.1f", 
            //       messageTextHeight, preciseHeight, heightDiff, maxHeight);
            
            // 根据设备特征动态调整缓冲
            CGFloat buffer = 0.0;
            // 已验证 iPhone 11、iPhone 12、iPhone 14 Pro、iPhone 15 Pro、iPhone 16、iPhone 16 Pro Max、iPhone Xs
            
            // 获取设备信息
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            NSString *deviceModel = [[UIDevice currentDevice] model];
            
            // NSLog(@"📱 设备信息 - 屏幕: %.0fx%.0f, 设备: %@", screenWidth, screenHeight, deviceModel);
            
            // 基于设备特征动态计算缓冲
            CGFloat deviceScale = [UIScreen mainScreen].scale;
            CGFloat widthRatio = screenWidth / 390.0; // 以iPhone 12为基准
            CGFloat heightRatio = screenHeight / 844.0; // 以iPhone 12为基准
            
            // 根据设备比例和屏幕密度动态调整
            if (widthRatio >= 0.98 && widthRatio <= 1.02) {
                // iPhone 12, 13, 14 等标准尺寸设备
                buffer = 8.0;
                // NSLog(@"📏 标准屏设备(比例: %.2f) - 添加缓冲: %.1f", widthRatio, buffer);
            } else {
                // 其他设备（iPhone XS、Pro Max系列等）
                buffer = -10.0;
                // NSLog(@"📏 非标准屏设备(比例: %.2f) - 减少缓冲: %.1f", widthRatio, buffer);
            }
            
            // 根据屏幕密度微调（3x屏幕可能需要更精确的调整）
            if (deviceScale >= 3.0) {
                buffer *= 0.8; // 高密度屏幕稍微减少缓冲
                // NSLog(@"📏 高密度屏幕(%.1fx) - 调整缓冲: %.1f", deviceScale, buffer);
            }
            
            messageTextHeight = maxHeight + buffer;
            // NSLog(@"📏 最终高度: %.1f (最大高度: %.1f + 缓冲: %.1f)", messageTextHeight, maxHeight, buffer);
        }
        
        //文字宽度
        CGFloat messageTextWidth = [MQStringSizeUtil getWidthForAttributedText:self.cellText textHeight:messageTextHeight];
        NSRange periodRange = [message.content rangeOfString:@"."];
        if (periodRange.location != NSNotFound) {
            messageTextWidth += 8;
        }
        if (messageTextWidth > maxLabelWidth) {
            messageTextWidth = maxLabelWidth;
        }
        
        // menu的「常见问题」tip的高度
        CGFloat menuTipHeight = kMQBotHighMenuTitleHeight;
        
        // menu的「常见问题」page的高度
        CGFloat menuPageHeight = message.pageMaxSize * (kMQPageItemYMargin + kMQPageItemContentHeight) + kMQPageBottomButtonHeight;
        if (message.menuList.count > 1) {
            menuPageHeight += kMQPageLineHeight + kMQPageScrollMenuViewHeight;
        }
        
        //气泡高度
        CGFloat bubbleHeight = messageTextHeight + kMQCellBubbleToTextVerticalSpacing * 2;  // 修复：添加上下垂直间距
        //气泡宽度
        CGFloat bubbleWidth = messageTextWidth + kMQCellBubbleToTextHorizontalLargerSpacing + kMQCellBubbleToTextHorizontalSmallerSpacing;
        
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
            
            self.textLabelFrame = CGRectMake(kMQCellBubbleToTextHorizontalSmallerSpacing, kMQCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
            //气泡的frame
            self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kMQCellAvatarToHorizontalEdgeSpacing-kMQCellAvatarToBubbleSpacing-bubbleWidth, kMQCellAvatarToVerticalEdgeSpacing, bubbleWidth, bubbleHeight);
            
        } else {
            //收到的消息
            self.cellFromType = MQChatCellIncoming;
            
            //头像的frame
            if ([MQChatViewConfig sharedConfig].enableIncomingAvatar) {
                self.avatarFrame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarDiameter, kMQCellAvatarDiameter);
            } else {
                self.avatarFrame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing, 0, 0);
            }
            
            self.textLabelFrame = CGRectMake(kMQCellBubbleToTextHorizontalLargerSpacing, kMQCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
            //气泡的frame
            self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kMQCellAvatarToBubbleSpacing, self.avatarFrame.origin.y, bubbleWidth, bubbleHeight);
        }
        
        //tip的frame
        self.menuBackFrame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, CGRectGetMaxY(self.bubbleImageFrame) + 2 * kMQCellBubbleToTextVerticalSpacing, cellWidth - 2 * kMQCellAvatarToHorizontalEdgeSpacing, menuPageHeight + menuTipHeight + kMQCellBubbleToTextVerticalSpacing);
        self.menuTipLabelFrame = CGRectMake(kMQCellBubbleToTextHorizontalSmallerSpacing, kMQCellBubbleToTextVerticalSpacing, CGRectGetWidth(self.menuBackFrame) - 2 * kMQCellBubbleToTextHorizontalSmallerSpacing, menuTipHeight);
        
        
        __weak typeof(self) weakSelf = self;
        self.pageView = [[MQPageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.menuTipLabelFrame), CGRectGetMaxY(self.menuTipLabelFrame), CGRectGetWidth(self.menuTipLabelFrame), menuPageHeight) dataArr:message.menuList pageMaxSize:(int)message.pageMaxSize block:^(NSString * _Nonnull content) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didTapHighMenuWithText:)]) {
                [weakSelf.delegate didTapHighMenuWithText:content];
            }
        }];
        
        //气泡图片
        self.bubbleImage = [bubbleImage resizableImageWithCapInsets:[MQChatViewConfig sharedConfig].bubbleImageStretchInsets];
        
        //计算cell的高度
        self.cellHeight = CGRectGetMaxY(self.menuBackFrame) + kMQCellAvatarToVerticalEdgeSpacing;
        
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
    return [[MQBotHighMenuRichCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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

- (void)updateCellConversionId:(NSString *)conversionId {
    self.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
}

@end
