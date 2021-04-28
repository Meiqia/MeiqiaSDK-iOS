//
//  MQSplitLineCell.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/20.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQSplitLineCell.h"
#import <Foundation/Foundation.h>
#import "MQSplitLineCellModel.h"
#import "MQDateFormatterUtil.h"
#import "UIColor+MQHex.h"

@implementation MQSplitLineCell {
    UILabel *_lable;
    UIView *_leftLine;
    UIView *_rightLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *lable = [[UILabel alloc] init];
        lable.font = [UIFont boldSystemFontOfSize:14];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = [UIColor colorWithRed:242/255 green:242/255 blue:247/255 alpha:0.2];
        _lable = lable;
        [self.contentView addSubview:_lable];
        
        UIView *leftLine = [UIView new];
        leftLine.backgroundColor = [UIColor colorWithRed:242/255 green:242/255 blue:247/255 alpha:0.2];
        _leftLine = leftLine;
        [self.contentView addSubview:_leftLine];
        
        UIView *rightLine = [UIView new];
        rightLine.backgroundColor = [UIColor colorWithRed:242/255 green:242/255 blue:247/255 alpha:0.2];
        _rightLine = rightLine;
        [self.contentView addSubview:_rightLine];
        
    }
    return self;
}

#pragma MQChatCellProtocol
- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if (![model isKindOfClass:[MQSplitLineCellModel class]]) {
        NSAssert(NO, @"传给MQEventMessageCell的Model类型不正确");
        return ;
    }
    MQSplitLineCellModel *cellModel = (MQSplitLineCellModel *)model;
    _lable.frame = cellModel.labelFrame;
    _leftLine.frame = cellModel.leftLineFrame;
    _rightLine.frame = cellModel.rightLineFrame;
    _lable.text = [[MQDateFormatterUtil sharedFormatter] meiqiaSplitLineDateForDate:cellModel.getCellDate];
}

@end

