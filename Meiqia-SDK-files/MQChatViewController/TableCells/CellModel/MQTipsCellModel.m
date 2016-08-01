//
//  MQTipsCellModel.m
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import "MQTipsCellModel.h"
#import "MQChatBaseCell.h"
#import "MQTipsCell.h"
#import "MQStringSizeUtil.h"
#import "MQChatViewConfig.h"
#import "MQBundleUtil.h"



//上下两条线与cell垂直边沿的间距
static CGFloat const kMQMessageTipsLabelLineVerticalMargin = 2.0;
static CGFloat const kMQMessageTipsCellVerticalSpacing = 24.0;
static CGFloat const kMQMessageTipsCellHorizontalSpacing = 24.0;
static CGFloat const kMQMessageReplyTipsCellVerticalSpacing = 8.0;
static CGFloat const kMQMessageReplyTipsCellHorizontalSpacing = 8.0;
static CGFloat const kMQMessageTipsLineHeight = 0.5;
CGFloat const kMQMessageTipsFontSize = 13.0;

@interface MQTipsCellModel()
/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 提示文字
 */
@property (nonatomic, readwrite, copy) NSString *tipText;

/**
 * @brief 提示label的frame
 */
@property (nonatomic, readwrite, assign) CGRect tipLabelFrame;

/**
 * @brief 上线条的frame
 */
@property (nonatomic, readwrite, assign) CGRect topLineFrame;

/**
 *  是否显示上下两个线条
 */
@property (nonatomic, readwrite, assign) BOOL enableLinesDisplay;

/**
 * @brief 下线条的frame
 */
@property (nonatomic, readwrite, assign) CGRect bottomLineFrame;

/**
 * @brief 提示的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

// tip 的类型
@property (nonatomic, readwrite, assign) MQTipType tipType;

@end

@implementation MQTipsCellModel

#pragma initialize
/**
 *  根据tips内容来生成cell model
 */
- (MQTipsCellModel *)initCellModelWithTips:(NSString *)tips
                                 cellWidth:(CGFloat)cellWidth
                        enableLinesDisplay:(BOOL)enableLinesDisplay
{
    if (self = [super init]) {
        self.tipType = MQTipTypeRedirect;
        self.date = [NSDate date];
        self.tipText = tips;
        self.enableLinesDisplay = enableLinesDisplay;
        
        //tip frame
        CGFloat tipCellHoriSpacing = enableLinesDisplay ? kMQMessageTipsCellHorizontalSpacing : kMQMessageReplyTipsCellHorizontalSpacing;
        CGFloat tipCellVerSpacing = enableLinesDisplay ? kMQMessageTipsCellVerticalSpacing : kMQMessageReplyTipsCellVerticalSpacing;
        CGFloat tipsWidth = cellWidth - tipCellHoriSpacing * 2;
        CGFloat tipsHeight = [MQStringSizeUtil getHeightForText:tips withFont:[UIFont systemFontOfSize:kMQMessageTipsFontSize] andWidth:tipsWidth];
        CGRect tipLabelFrame = CGRectMake(tipCellHoriSpacing, tipCellVerSpacing, tipsWidth, tipsHeight);
        self.tipLabelFrame = tipLabelFrame;
        
        self.cellHeight = tipCellVerSpacing * 2 + tipsHeight;
        
        //上线条的frame
        CGFloat lineWidth = cellWidth;
        self.topLineFrame = CGRectMake(cellWidth/2-lineWidth/2, kMQMessageTipsLabelLineVerticalMargin, lineWidth, kMQMessageTipsLineHeight);
        
        //下线条的frame
        self.bottomLineFrame = CGRectMake(self.topLineFrame.origin.x, self.cellHeight - kMQMessageTipsLabelLineVerticalMargin - kMQMessageTipsLineHeight, lineWidth, kMQMessageTipsLineHeight);
        
        //tip的文字额外属性
        if (tips.length > 4) {
            if ([[tips substringToIndex:3] isEqualToString:@"接下来"]) {
                NSRange firstRange = [tips rangeOfString:@" "];
                NSString *subTips = [tips substringFromIndex:firstRange.location+1];
                NSRange lastRange = [subTips rangeOfString:@"为您服务"];
                NSRange agentNameRange = NSMakeRange(firstRange.location+1, lastRange.location-1);
                self.tipExtraAttributesRange = agentNameRange;
                self.tipExtraAttributes = @{
                                            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:13],
                                            NSForegroundColorAttributeName : [MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor
                                            };
            }
        }
    }
    return self;
}

/**
 *  生成留言提示的 cell，支持点击留言
 */
- (MQTipsCellModel *)initBotTipCellModelWithCellWidth:(CGFloat)cellWidth
                                              tipType:(MQTipType)tipType
{
    if (self = [super init]) {
        self.tipType = tipType;
        self.date = [NSDate date];
        if (tipType == MQTipTypeReply) {
            self.tipText = [MQBundleUtil localizedStringForKey:@"reply_tip_text"];
        } else if (tipType == MQTipTypeBotRedirect) {
            self.tipText = [MQBundleUtil localizedStringForKey:@"bot_redirect_tip_text"];
        } else if (tipType == MQTipTypeBotManualRedirect) {
            self.tipText = [MQBundleUtil localizedStringForKey:@"bot_manual_redirect_tip_text"];
        }
        self.enableLinesDisplay = false;
        
        //tip frame
        CGFloat tipsWidth = cellWidth - kMQMessageReplyTipsCellHorizontalSpacing * 2;
        CGFloat tipsHeight = [MQStringSizeUtil getHeightForText:self.tipText withFont:[UIFont systemFontOfSize:kMQMessageTipsFontSize] andWidth:tipsWidth];
        CGRect tipLabelFrame = CGRectMake(kMQMessageReplyTipsCellHorizontalSpacing, kMQMessageReplyTipsCellVerticalSpacing, tipsWidth, tipsHeight);
        self.tipLabelFrame = tipLabelFrame;
        
        self.cellHeight = kMQMessageReplyTipsCellVerticalSpacing * 2 + tipsHeight;
        
        //上线条的frame
        CGFloat lineWidth = cellWidth;
        self.topLineFrame = CGRectMake(cellWidth/2-lineWidth/2, kMQMessageTipsLabelLineVerticalMargin, lineWidth, kMQMessageTipsLineHeight);
        
        //下线条的frame
        self.bottomLineFrame = CGRectMake(self.topLineFrame.origin.x, self.cellHeight - kMQMessageTipsLabelLineVerticalMargin - kMQMessageTipsLineHeight, lineWidth, kMQMessageTipsLineHeight);
        
        //tip的文字额外属性
        NSString *tapText = tipType == MQTipTypeReply ? @"留言" : @"转人工";
        NSRange replyTextRange = [self.tipText rangeOfString:tapText];
        self.tipExtraAttributesRange = replyTextRange;
        self.tipExtraAttributes = @{
                                    NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:13],
                                    NSForegroundColorAttributeName : [MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor
                                    };
    }
    return self;
}

- (MQTipsCellModel *)initWaitingInQueueTipCellModelWithCellWidth:(CGFloat)cellWidth position:(int)position tipType:(MQTipType)tipType {
    if (self = [super init]) {
        self.tipType = tipType;
        self.date = [NSDate date];
        self.tipText = [NSString stringWithFormat:[MQBundleUtil localizedStringForKey:@"wating_in_queue_tip_text"], position];
        self.enableLinesDisplay = false;
        
        //tip frame
        CGFloat tipsWidth = cellWidth - kMQMessageReplyTipsCellHorizontalSpacing * 2;
        CGFloat tipsHeight = [MQStringSizeUtil getHeightForText:self.tipText withFont:[UIFont systemFontOfSize:kMQMessageTipsFontSize] andWidth:tipsWidth];
        CGRect tipLabelFrame = CGRectMake(kMQMessageReplyTipsCellHorizontalSpacing, kMQMessageReplyTipsCellVerticalSpacing, tipsWidth, tipsHeight);
        self.tipLabelFrame = tipLabelFrame;
        
        self.cellHeight = kMQMessageReplyTipsCellVerticalSpacing * 2 + tipsHeight;
        
        //上线条的frame
        CGFloat lineWidth = cellWidth;
        self.topLineFrame = CGRectMake(cellWidth/2-lineWidth/2, kMQMessageTipsLabelLineVerticalMargin, lineWidth, kMQMessageTipsLineHeight);
        
        //下线条的frame
        self.bottomLineFrame = CGRectMake(self.topLineFrame.origin.x, self.cellHeight - kMQMessageTipsLabelLineVerticalMargin - kMQMessageTipsLineHeight, lineWidth, kMQMessageTipsLineHeight);
        
        //tip的文字额外属性
        NSString *tapText = @"留言";
        NSRange replyTextRange = [self.tipText rangeOfString:tapText];
        self.tipExtraAttributesRange = replyTextRange;
        self.tipExtraAttributes = @{
                                    NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:13],
                                    NSForegroundColorAttributeName : [MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor
                                    };
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
    return [[MQTipsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.date;
}

- (BOOL)isServiceRelatedCell {
    return false;
}

- (NSString *)getCellMessageId {
    return @"";
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    CGFloat tipCellHoriSpacing = self.tipType == MQTipTypeRedirect ? kMQMessageTipsCellHorizontalSpacing : kMQMessageReplyTipsCellHorizontalSpacing;
    CGFloat tipCellVerSpacing = self.tipType == MQTipTypeRedirect ? kMQMessageTipsCellVerticalSpacing : kMQMessageReplyTipsCellVerticalSpacing;
    
    //tip frame
    CGFloat tipsWidth = cellWidth - tipCellHoriSpacing * 2;
    self.tipLabelFrame = CGRectMake(tipCellHoriSpacing, tipCellVerSpacing, tipsWidth, self.tipLabelFrame.size.height);
    
    //上线条的frame
    CGFloat lineWidth = cellWidth;
    self.topLineFrame = CGRectMake(cellWidth/2-lineWidth/2, kMQMessageTipsLabelLineVerticalMargin, lineWidth, kMQMessageTipsLineHeight);
    
    //下线条的frame
    self.bottomLineFrame = CGRectMake(self.topLineFrame.origin.x, self.cellHeight - kMQMessageTipsLabelLineVerticalMargin - kMQMessageTipsLineHeight, lineWidth, kMQMessageTipsLineHeight);
    
    // cell height
    self.cellHeight = self.bottomLineFrame.origin.y + self.bottomLineFrame.size.height + 0.5;
}


@end
