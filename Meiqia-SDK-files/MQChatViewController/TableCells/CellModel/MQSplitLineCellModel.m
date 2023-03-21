//
//  MQSplitLineCellModel.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/20.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQSplitLineCellModel.h"
#import "MQSplitLineCell.h"

static CGFloat const kMQSplitLineCellSpacing = 20.0;
static CGFloat const kMQSplitLineCellHeight = 40.0;
static CGFloat const kMQSplitLineCellLableHeight = 20.0;
static CGFloat const kMQSplitLineCellLableWidth = 150.0;
@interface MQSplitLineCellModel()

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;
@property (nonatomic, readwrite, assign) CGRect labelFrame;
@property (nonatomic, readwrite, assign) CGRect leftLineFrame;
@property (nonatomic, readwrite, assign) CGRect rightLineFrame;
@property (nonatomic, readwrite, copy) NSDate *currentDate;

@end

@implementation MQSplitLineCellModel

- (MQSplitLineCellModel *)initCellModelWithCellWidth:(CGFloat)cellWidth withConversionDate:(NSDate *)date {
    if (self = [super init]) {
        self.cellWidth = cellWidth;
        self.currentDate = date;
        self.labelFrame = CGRectMake(cellWidth/2.0 - kMQSplitLineCellLableWidth/2.0, (kMQSplitLineCellHeight - kMQSplitLineCellLableHeight)/2.0 - 3, kMQSplitLineCellLableWidth, kMQSplitLineCellLableHeight);
        self.leftLineFrame = CGRectMake(kMQSplitLineCellSpacing, kMQSplitLineCellHeight/2.0, CGRectGetMinX(self.labelFrame) - kMQSplitLineCellSpacing, 0.5);
        self.rightLineFrame = CGRectMake(CGRectGetMaxX(self.labelFrame), CGRectGetMinY(self.leftLineFrame), cellWidth - kMQSplitLineCellSpacing - CGRectGetMaxX(self.labelFrame), 0.5);
    }
    return self;
}


#pragma MQCellModelProtocol
- (NSDate *)getCellDate {
    return self.currentDate;
}

- (CGFloat)getCellHeight {
    return kMQSplitLineCellHeight;
}

- (NSString *)getCellMessageId {
    return @"";
}

- (NSString *)getMessageConversionId {
    return @"";
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MQSplitLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];;
}

- (BOOL)isServiceRelatedCell {
    return false;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    
    self.labelFrame = CGRectMake(cellWidth/2.0 - kMQSplitLineCellLableWidth/2.0, (kMQSplitLineCellHeight - kMQSplitLineCellLableHeight)/2.0, kMQSplitLineCellLableWidth, kMQSplitLineCellLableHeight);
    self.leftLineFrame = CGRectMake(kMQSplitLineCellSpacing, kMQSplitLineCellHeight/2.0, CGRectGetMinX(self.labelFrame) - kMQSplitLineCellSpacing, 1);
    self.rightLineFrame = CGRectMake(CGRectGetMaxX(self.labelFrame), CGRectGetMinY(self.leftLineFrame), cellWidth - kMQSplitLineCellSpacing - CGRectGetMaxX(self.labelFrame), 1);
}

@end
