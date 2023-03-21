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
static CGFloat const kMQMessageTipsBottomBtnHeight = 40.0;
static CGFloat const kMQMessageTipsBottomBtnHorizontalSpacing = 25.0;
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
 * @brief 提示文字的额外属性
 */
@property (nonatomic, readwrite, strong) NSArray<NSDictionary<NSString *, id> *> *tipExtraAttributes;

/**
 * @brief 提示文字的额外属性的 range 的数组
 */
@property (nonatomic, readwrite, strong) NSArray<NSValue *> *tipExtraAttributesRanges;

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
 * 下线条的frame
 */
@property (nonatomic, readwrite, assign) CGRect bottomLineFrame;

/**
 * 底部留言的btn的frame
 */
@property (nonatomic, readwrite, assign) CGRect bottomBtnFrame;

/**
 *  底部bottom提示文字
 */
@property (nonatomic, readwrite, copy) NSString *bottomBtnTitle;

/**
 * @brief 提示的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

// tip 的类型
@property (nonatomic, readwrite, assign) MQTipType tipType;

// 排队的引导提示文案
@property (nonatomic, readwrite, copy) NSString *queueIntro;

// 排队的留言引导提示文案
@property (nonatomic, readwrite, copy) NSString *queueTicketIntro;

// tip 的类型
@property (nonatomic, readwrite, assign) int queuePosition;

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
                NSRange lastRange = [subTips rangeOfString:@"为你服务"];
                NSRange agentNameRange = NSMakeRange(firstRange.location+1, lastRange.location-1);
                self.tipExtraAttributesRanges = @[[NSValue valueWithRange:agentNameRange]];
                self.tipExtraAttributes = @[@{
                                                NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:13],
                                                NSForegroundColorAttributeName : [MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor
                                                }];
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
                                  showLeaveCommentBtn:(BOOL)showBtn
{
    if (self = [super init]) {
        self.tipType = tipType;
        self.date = [NSDate date];
        if (tipType == MQTipTypeReply) {
            self.tipText = [NSString stringWithFormat:@"%@%@",[MQBundleUtil localizedStringForKey:@"reply_tip_text"], showBtn ? [MQBundleUtil localizedStringForKey:@"reply_tip_leave"] : @""];
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
        NSString *tapText = [NSString string];
        if (tipType == MQTipTypeReply) {
            tapText = showBtn ? ([self.tipText containsString:@"留言"] ? @"留言" : @"You can give us a message") : @"";
        } else {
            if ([self.tipText containsString:@"转人工"]) {
                tapText = @"转人工";
            } else {
                tapText = [self.tipText containsString:@"轉人工"] ?  @"轉人工" : @"Tap here to redirect to an agent";
            }
        }
        NSRange replyTextRange = [self.tipText rangeOfString:tapText];
        self.tipExtraAttributesRanges = @[[NSValue valueWithRange:replyTextRange]];
        self.tipExtraAttributes = @[@{
                                        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:13],
                                        NSForegroundColorAttributeName : [MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor
                                        }];
    }
    return self;
}

- (MQTipsCellModel *)initWaitingInQueueTipCellModelWithCellWidth:(CGFloat)cellWidth withIntro:(NSString *)intro ticketIntro:(NSString *)ticketIntro position:(int)position tipType:(MQTipType)tipType showLeaveCommentBtn:(BOOL)showBtn {
    if (self = [super init]) {
        self.tipType = tipType;
        self.date = [NSDate date];
        NSString *waitNumberTitle = [MQBundleUtil localizedStringForKey:@"wating_in_queue_tip_number"];
        self.queueIntro = intro;
        self.queuePosition = position;
        self.queueTicketIntro = showBtn ? ticketIntro : @"";
        self.tipText =[NSString stringWithFormat:@"%@\n\n%@\n\n%d\n\n%@",intro,waitNumberTitle,position,self.queueTicketIntro];
        self.enableLinesDisplay = false;
        self.bottomBtnTitle = showBtn ? [MQBundleUtil localizedStringForKey:@"wating_in_queue_tip_leave_message"] : @"";
        
        //tip frame
        CGFloat tipsWidth = cellWidth - kMQMessageReplyTipsCellHorizontalSpacing * 2;
        CGFloat bottomBtnWidth = cellWidth - kMQMessageTipsBottomBtnHorizontalSpacing * 2;
        CGFloat tipsHeight = [MQStringSizeUtil getHeightForText:self.tipText withFont:[UIFont systemFontOfSize:kMQMessageTipsFontSize] andWidth:tipsWidth];
        tipsHeight += kMQMessageTipsBottomBtnHeight;
        CGRect tipLabelFrame = CGRectMake(kMQMessageReplyTipsCellHorizontalSpacing, kMQMessageReplyTipsCellVerticalSpacing, tipsWidth, tipsHeight);
        self.tipLabelFrame = tipLabelFrame;
        
        self.bottomBtnFrame = CGRectMake(kMQMessageTipsBottomBtnHorizontalSpacing, CGRectGetMaxY(self.tipLabelFrame), bottomBtnWidth, kMQMessageTipsBottomBtnHeight);
        
        self.cellHeight = kMQMessageReplyTipsCellVerticalSpacing * 2 + tipsHeight + kMQMessageTipsBottomBtnHeight;
        
        //上线条的frame
        CGFloat lineWidth = cellWidth;
        self.topLineFrame = CGRectMake(cellWidth/2-lineWidth/2, kMQMessageTipsLabelLineVerticalMargin, lineWidth, kMQMessageTipsLineHeight);
        
        //下线条的frame
        self.bottomLineFrame = CGRectMake(self.topLineFrame.origin.x, self.cellHeight - kMQMessageTipsLabelLineVerticalMargin - kMQMessageTipsLineHeight, lineWidth, kMQMessageTipsLineHeight);
        
        //tip的文字额外属性
        NSRange waitNumberTitleRange = [self.tipText rangeOfString:waitNumberTitle];
        NSRange waitNunmerRange = NSMakeRange(waitNumberTitleRange.location + waitNumberTitleRange.length + 2, [NSString stringWithFormat:@"%d",position].length);
        self.tipExtraAttributesRanges = @[[NSValue valueWithRange:waitNumberTitleRange], [NSValue valueWithRange:waitNunmerRange]];
        self.tipExtraAttributes = @[@{
                                        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:15],
                                        NSForegroundColorAttributeName : UIColor.blackColor
                                    },
                                    @{
                                        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:20],
                                        NSForegroundColorAttributeName : [MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor
                                    }];
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

- (NSString *)getMessageConversionId {
    return @"";
}

- (void)updateQueueTipPosition:(int)position {
    if (self.tipType == MQTipTypeWaitingInQueue) {
        NSString *waitNumberTitle = [MQBundleUtil localizedStringForKey:@"wating_in_queue_tip_number"];
        self.tipText =[NSString stringWithFormat:@"%@\n\n%@\n\n%d\n\n%@",self.queueIntro,waitNumberTitle,position,self.queueTicketIntro];
        //tip的文字额外属性
        NSRange waitNumberTitleRange = [self.tipText rangeOfString:waitNumberTitle];
        NSRange waitNunmerRange = NSMakeRange(waitNumberTitleRange.location + waitNumberTitleRange.length + 2, [NSString stringWithFormat:@"%d",position].length);
        self.tipExtraAttributesRanges = @[[NSValue valueWithRange:waitNumberTitleRange], [NSValue valueWithRange:waitNunmerRange]];
        self.tipExtraAttributes = @[@{
                                        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:15],
                                        NSForegroundColorAttributeName : UIColor.blackColor
                                    },
                                    @{
                                        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:20],
                                        NSForegroundColorAttributeName : [MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor
                                    }];
    }
}

- (int)getCurrentQueuePosition {
    return self.queuePosition;
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
