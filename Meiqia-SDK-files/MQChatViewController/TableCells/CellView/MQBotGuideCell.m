//
//  MQBotGuideCell.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/1/12.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import "MQBotGuideCell.h"
#import "MQBotGuideCellModel.h"

@interface MQBotGuideCell()

@end

@implementation MQBotGuideCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

#pragma MQChatCellProtocol
- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if (![model isKindOfClass:[MQBotGuideCellModel class]]) {
        NSAssert(NO, @"传给MQBotGuideCell的Model类型不正确");
        return ;
    }
    MQBotGuideCellModel *cellModel = (MQBotGuideCellModel *)model;
    
    for (UIView *tempView in self.contentView.subviews) {
        if ([tempView isKindOfClass:[MQTagListView class]]) {
            [tempView removeFromSuperview];
        }
    }
    if (cellModel.cacheTagListView) {
        [self.contentView addSubview:cellModel.cacheTagListView];
        NSArray *cacheTags = [[NSArray alloc] initWithArray:cellModel.cacheTags];
        __weak __typeof(self) weakSelf = self;
        cellModel.cacheTagListView.mqTagListSelectedIndex = ^(NSInteger index) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            NSString *didTapText = cacheTags[index];
            if ([self.chatCellDelegate respondsToSelector:@selector(deleteCell:withTipMsg:enableLinesDisplay:)]) {
                [self.chatCellDelegate deleteCell:strongSelf withTipMsg:nil enableLinesDisplay:NO];
            }
            if ([self.chatCellDelegate respondsToSelector:@selector(didTapGuideWithText:)]) {
                [self.chatCellDelegate didTapGuideWithText:didTapText];
            }
        };
    }
}

@end
