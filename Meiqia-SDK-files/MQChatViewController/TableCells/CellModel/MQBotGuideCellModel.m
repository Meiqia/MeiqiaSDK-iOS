//
//  MQBotGuideCellModel.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/1/12.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import "MQBotGuideCellModel.h"
#import "MQBotGuideCell.h"
#import "UIColor+MQHex.h"

@interface MQBotGuideCellModel ()

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief 标签的tagList
 */
@property (nonatomic, readwrite, strong) MQTagListView *cacheTagListView;

/**
 * @brief 标签的数据源
 */
@property (nonatomic, readwrite, strong) NSArray *cacheTags;

/**
 * cell中消息的会话id
 */
@property (nonatomic, strong) NSString *conversionId;

/**
 *  消息的时间
 */
@property (nonatomic, copy) NSDate *date;

/**
 *  cell中消息的id
 */
@property (nonatomic, strong) NSString *messageId;

@end

@implementation MQBotGuideCellModel

-(MQBotGuideCellModel *)initCellModelWithMessage:(MQBotGuideMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegate {
    if (self = [super init]) {
        self.messageId = message.messageId;
        self.conversionId = message.conversionId;
        self.date = message.date;
        self.cellWidth = cellWidth;
        CGFloat maxWidth = cellWidth - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarDiameter - kMQCellAvatarToBubbleSpacing - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing - kMQCellBubbleMaxWidthToEdgeSpacing;
        self.cacheTagListView = [[MQTagListView alloc] initWithTitleArray:[NSArray arrayWithArray:message.guideContents] andMaxWidth:maxWidth tagBackgroundColor:[UIColor mq_colorWithHexWithLong:0x3E8BFF] tagTitleColor:[UIColor whiteColor] tagFontSize:15 needBorder:NO];
        self.cacheTags = [NSArray arrayWithArray:message.guideContents];
        [self configCellWidth:cellWidth];
    }
    return self;
}

#pragma mark private

-(void)configCellWidth:(CGFloat)cellWidth {
    //最大宽度
    CGFloat maxWidth = cellWidth - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarDiameter - kMQCellAvatarToBubbleSpacing - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing - kMQCellBubbleMaxWidthToEdgeSpacing;
    
    if (self.cacheTagListView) {
        [self.cacheTagListView updateLayoutWithMaxWidth:maxWidth];
        self.cacheTagListView.frame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing + kMQCellAvatarDiameter + kMQCellAvatarToBubbleSpacing, 0, self.cacheTagListView.bounds.size.width, self.cacheTagListView.bounds.size.height);
    }
    
    //计算cell的高度
    self.cellHeight = self.cacheTagListView != nil ? self.cacheTagListView.frame.size.height + kMQCellBubbleToIndicatorSpacing : 0;
}

#pragma mark MQCellModelProtocol

- (NSDate *)getCellDate { 
    return self.date;
}

- (CGFloat)getCellHeight { 
    return self.cellHeight > 0 ? self.cellHeight : 0;
}

- (NSString *)getCellMessageId { 
    return self.messageId;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MQBotGuideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSString *)getMessageConversionId { 
    return self.conversionId;
}

- (BOOL)isServiceRelatedCell { 
    return false;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth { 
    self.cellWidth = cellWidth;
    [self configCellWidth:cellWidth];
}

@end
