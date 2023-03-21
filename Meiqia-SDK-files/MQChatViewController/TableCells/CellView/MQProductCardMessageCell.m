//
//  MQProductCardMessageCell.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2021/9/2.
//  Copyright © 2021 2020 MeiQia. All rights reserved.
//

#import "MQProductCardMessageCell.h"
#import "MQProductCardCellModel.h"
#import "MQChatViewConfig.h"
#import "MQImageUtil.h"
#import "MQBundleUtil.h"

@implementation MQProductCardMessageCell
{
    UIImageView *avatarImageView;
    UIView *bubbleView;
    UIImageView *bubbleContentImageView;
    UILabel *titleLabel;
    UILabel *descLable;
    UILabel *saleCountLable;
    UILabel *linkLable;
    UIActivityIndicatorView *sendingIndicator;
    UIImageView *failureImageView;
    MQProductCardCellModel *cellModel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化头像
        avatarImageView = [[UIImageView alloc] init];
        avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:avatarImageView];
        //初始化气泡
        bubbleView = [[UIView alloc] init];
        bubbleView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:247/255.0 alpha:1];
        bubbleView.layer.masksToBounds = true;
        bubbleView.layer.cornerRadius = 6.0;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleTapped)];
        [bubbleView addGestureRecognizer:tapGesture];
        
        [self.contentView addSubview:bubbleView];
        
        //初始化contentImageView
        bubbleContentImageView = [[UIImageView alloc] init];
        [bubbleView addSubview:bubbleContentImageView];
        //初始化title
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:16.0];
        titleLabel.textColor = [UIColor colorWithRed:4/255.0 green:15/255.0 blue:66/255.0 alpha:1];
        [bubbleView addSubview:titleLabel];
        //初始化description
        descLable = [[UILabel alloc] init];
        descLable.font = [UIFont systemFontOfSize:13.0];
        descLable.textColor = [UIColor colorWithRed:111/255.0 green:117/255.0 blue:146/255.0 alpha:1];
        descLable.numberOfLines = 2;
        [bubbleView addSubview:descLable];
        //初始化salecount
        saleCountLable = [[UILabel alloc] init];
        saleCountLable.font = [UIFont systemFontOfSize:13.0];
        saleCountLable.textColor = [UIColor colorWithRed:111/255.0 green:117/255.0 blue:146/255.0 alpha:1];
        [bubbleView addSubview:saleCountLable];
        //初始化link
        linkLable = [[UILabel alloc] init];
        linkLable.font = [UIFont systemFontOfSize:13.0];
        linkLable.textColor = [UIColor colorWithRed:24/255.0 green:128/255.0 blue:155/255.0 alpha:1];
        linkLable.textAlignment = NSTextAlignmentRight;
        linkLable.text = [MQBundleUtil localizedStringForKey:@"product_message_check_details"];
        [bubbleView addSubview:linkLable];
        
        //初始化indicator
        sendingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        sendingIndicator.hidden = YES;
        [self.contentView addSubview:sendingIndicator];
        //初始化出错image
        failureImageView = [[UIImageView alloc] initWithImage:[MQChatViewConfig sharedConfig].messageSendFailureImage];
        UITapGestureRecognizer *tapFailureImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFailImage:)];
        failureImageView.userInteractionEnabled = true;
        [failureImageView addGestureRecognizer:tapFailureImageGesture];
        [self.contentView addSubview:failureImageView];
    }
    return self;
}

#pragma MQChatCellProtocol
- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if (![model isKindOfClass:[MQProductCardCellModel class]]) {
        NSAssert(NO, @"传给MQProductCardCellModel的Model类型不正确");
        return ;
    }
    cellModel = (MQProductCardCellModel *)model;

    //刷新头像
    if (cellModel.avatarImage) {
        avatarImageView.image = cellModel.avatarImage;
    }
    avatarImageView.frame = cellModel.avatarFrame;
    if ([MQChatViewConfig sharedConfig].enableRoundAvatar) {
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.layer.cornerRadius = cellModel.avatarFrame.size.width / 2;
    }
    
    //刷新气泡
    bubbleView.frame = cellModel.bubbleFrame;
    bubbleContentImageView.frame = cellModel.contentImageViewFrame;
    
    //消息图片
    bubbleContentImageView.image = cellModel.image;
    titleLabel.text = cellModel.title;
    descLable.text = cellModel.desc;
    NSString *countStr = (cellModel.saleCount && cellModel.saleCount >= 0) ? [NSString stringWithFormat:@"%ld",cellModel.saleCount] : @"--";
    saleCountLable.text = [NSString stringWithFormat:@"%@: %@",[MQBundleUtil localizedStringForKey:@"product_message_sales"],countStr];
    
    titleLabel.frame = cellModel.titleFrame;
    descLable.frame = cellModel.descriptionFrame;
    saleCountLable.frame = cellModel.saleCountFrame;
    linkLable.frame = cellModel.linkFrame;
    
    sendingIndicator.hidden = true;
    [sendingIndicator stopAnimating];
    if (cellModel.sendStatus == MQChatMessageSendStatusSending && cellModel.cellFromType == MQChatCellOutgoing) {
        sendingIndicator.hidden = false;
        sendingIndicator.frame = cellModel.sendingIndicatorFrame;
        [sendingIndicator startAnimating];
    }
    
    failureImageView.hidden = true;
    if (cellModel.sendStatus == MQChatMessageSendStatusFailure) {
        failureImageView.hidden = false;
        failureImageView.frame = cellModel.sendFailureFrame;
    }
}

#pragma 单击气泡
- (void)bubbleTapped {
    
    if ([self.chatCellDelegate respondsToSelector:@selector(didTapProductCard:)]) {
        NSString *productUrl = [NSString stringWithFormat:@"%@",cellModel.productUrl];
        [self.chatCellDelegate didTapProductCard:productUrl];
    }
}

#pragma 点击发送失败消息 重新发送事件
- (void)tapFailImage:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[MQBundleUtil localizedStringForKey:@"retry_send_message"] message:nil delegate:self cancelButtonTitle:[MQBundleUtil localizedStringForKey:@"alert_view_cancel"] otherButtonTitles:[MQBundleUtil localizedStringForKey:@"alert_view_confirm"], nil];
    [alertView show];
}

#pragma UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        MQProductCardMessage *message = [[MQProductCardMessage alloc] initWithPictureUrl:cellModel.productPictureUrl title:cellModel.title description:cellModel.desc productUrl:cellModel.productUrl andSalesCount:cellModel.saleCount];
        [self.chatCellDelegate resendMessageInCell:self resendData:@{@"productCard" : message}];
    }
}

@end
