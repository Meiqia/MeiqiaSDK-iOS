//
//  MQTipsCell.m
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import "MQTipsCell.h"
#import "MQTipsCellModel.h"
#import "MQBundleUtil.h"

@implementation MQTipsCell {
    UILabel *tipsLabel;
    UIButton *bottomBtn;
    CALayer *topLineLayer;
    CALayer *bottomLineLayer;
    UITapGestureRecognizer *tapReconizer;
    MQTipType tipType;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化提示label
        tipsLabel = [[UILabel alloc] init];
        tipsLabel.textColor = [UIColor grayColor];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.font = [UIFont systemFontOfSize:kMQMessageTipsFontSize];
        tipsLabel.backgroundColor = [UIColor clearColor];
        tipsLabel.numberOfLines = 0;
        [self.contentView addSubview:tipsLabel];
        bottomBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        bottomBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [bottomBtn setBackgroundColor:[UIColor colorWithRed:62/255.0 green:139/255.0 blue:255/255.0 alpha:1.0]];
        bottomBtn.layer.masksToBounds = YES;
        bottomBtn.layer.cornerRadius = 5.0;
        bottomBtn.hidden = YES;
        bottomBtn.enabled = NO;
        [self.contentView addSubview:bottomBtn];
        //画上下两条线
        topLineLayer = [self gradientLine];
        [self.contentView.layer addSublayer:topLineLayer];
        bottomLineLayer = [self gradientLine];
        [self.contentView.layer addSublayer:bottomLineLayer];
    }
    return self;
}

#pragma MQChatCellProtocol
- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if (![model isKindOfClass:[MQTipsCellModel class]]) {
        NSAssert(NO, @"传给MQTipsCell的Model类型不正确");
        return ;
    }
    
    MQTipsCellModel *cellModel = (MQTipsCellModel *)model;
    
    tipType = cellModel.tipType;
    
    //刷新时间label
    NSMutableAttributedString *tipsString = [[NSMutableAttributedString alloc] initWithString:cellModel.tipText];
    if (cellModel.tipExtraAttributesRanges.count > 0) {
        for (int i = 0; i < cellModel.tipExtraAttributesRanges.count; i++) {
            [tipsString addAttributes:cellModel.tipExtraAttributes[i] range:[cellModel.tipExtraAttributesRanges[i] rangeValue]];
        }
    }
    tipsLabel.attributedText = tipsString;
    tipsLabel.frame = cellModel.tipLabelFrame;
    
    if (cellModel.tipType == MQTipTypeWaitingInQueue && cellModel.bottomBtnTitle.length > 0) {
        bottomBtn.hidden = false;
        [bottomBtn setTitle:cellModel.bottomBtnTitle forState:UIControlStateNormal];
        bottomBtn.frame = cellModel.bottomBtnFrame;
    } else {
        bottomBtn.hidden = true;
        bottomBtn.frame = CGRectZero;
    }
    
    
    //刷新上下两条线
    if (cellModel.enableLinesDisplay) {
        [self.contentView.layer addSublayer:topLineLayer];
        [self.contentView.layer addSublayer:bottomLineLayer];
    } else {
        [topLineLayer removeFromSuperlayer];
        [bottomLineLayer removeFromSuperlayer];
    }
    topLineLayer.frame = cellModel.topLineFrame;
    bottomLineLayer.frame = cellModel.bottomLineFrame;
    
    // 判断是否该 tip 是提示留言的 tip，若是提示留言 tip，则增加点击事件
    if (!tapReconizer) {
        tapReconizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTipCell:)];
        self.contentView.userInteractionEnabled = true;
        [self.contentView addGestureRecognizer:tapReconizer];
    }
}

- (CAGradientLayer*)gradientLine {
    CAGradientLayer* line = [CAGradientLayer layer];
    line.backgroundColor = [UIColor clearColor].CGColor;
    line.startPoint = CGPointMake(0.1, 0.5);
    line.endPoint = CGPointMake(0.9, 0.5);
    line.colors = @[(id)[UIColor clearColor].CGColor,
                    (id)[UIColor lightGrayColor].CGColor,
                    (id)[UIColor lightGrayColor].CGColor,
                    (id)[UIColor clearColor].CGColor];
    return line;
}

- (void)tapTipCell:(id)sender {
    if ([tipsLabel.text isEqualToString:[NSString stringWithFormat:@"%@%@",[MQBundleUtil localizedStringForKey:@"reply_tip_text"], [MQBundleUtil localizedStringForKey:@"reply_tip_leave"]]]) {
        if ([self.chatCellDelegate respondsToSelector:@selector(didTapReplyBtn)]) {
            [self.chatCellDelegate didTapReplyBtn];
        }
    }
    NSArray *botRedirectArray = @[[MQBundleUtil localizedStringForKey:@"bot_redirect_tip_text"], [MQBundleUtil localizedStringForKey:@"bot_manual_redirect_tip_text"]];
    if ([botRedirectArray containsObject:tipsLabel.text]) {
        if ([self.chatCellDelegate respondsToSelector:@selector(didTapBotRedirectBtn)]) {
            [self.chatCellDelegate didTapBotRedirectBtn];
        }
    }
    if (tipType == MQTipTypeWaitingInQueue) {
        if ([self.chatCellDelegate respondsToSelector:@selector(didTapReplyBtn)]) {
            [self.chatCellDelegate didTapReplyBtn];
        }
    }
}



@end
