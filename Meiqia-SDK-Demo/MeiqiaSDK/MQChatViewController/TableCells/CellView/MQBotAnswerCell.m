//
//  MQBotAnswerCell.m
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 16/4/27.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQBotAnswerCell.h"
#import "MQChatViewConfig.h"
#import "MQChatFileUtil.h"
#import "MQBundleUtil.h"
#import "MEIQIA_TTTAttributedLabel.h"
#import "MQStringSizeUtil.h"
#import "MQChatViewStyle.h"
#import "MQBotAnswerCellModel.h"

static const NSInteger kMQTextCellSelectedUrlActionSheetTag = 2000;
static const NSInteger kMQTextCellSelectedNumberActionSheetTag = 2001;
static const NSInteger kMQTextCellSelectedEmailActionSheetTag = 2002;
static const CGFloat   kMQBotAnswerEvaluateTextSize = 16.0;

@interface MQBotAnswerCell() <MEIQIA_TTTAttributedLabelDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@end

@implementation MQBotAnswerCell  {
    UIImageView *avatarImageView;
    TTTAttributedLabel *textLabel;
    UIImageView *bubbleImageView;
    UIActivityIndicatorView *sendingIndicator;
    UIImageView *failureImageView;
    UIView *evaluateUpperLine;
    UIView *evaluateMiddleLine;
    UIButton *positiveBtn;
    UIButton *negativeBtn;
    UIButton *evaluateDoneBtn;
    UIButton *replyBtn;
    NSString *messageId;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        messageId = @"";
        //初始化头像
        avatarImageView = [[UIImageView alloc] init];
        avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:avatarImageView];
        //初始化气泡
        bubbleImageView = [[UIImageView alloc] init];
        bubbleImageView.userInteractionEnabled = true;
        UILongPressGestureRecognizer *longPressBubbleGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBubbleView:)];
        [bubbleImageView addGestureRecognizer:longPressBubbleGesture];
        [self.contentView addSubview:bubbleImageView];
        //初始化文字
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
            textLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
            textLabel.delegate = self;
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
            textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
#pragma clang diagnostic pop
        }
        textLabel.numberOfLines = 0;
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.userInteractionEnabled = true;
        textLabel.backgroundColor = [UIColor clearColor];
        [bubbleImageView addSubview:textLabel];
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
        
        //初始化评价
        UIColor *botBtnColor = [MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor;
        
        evaluateUpperLine = [[UIView alloc] init];
        evaluateUpperLine.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        [bubbleImageView addSubview:evaluateUpperLine];
        
        evaluateMiddleLine = [[UIView alloc] init];
        evaluateMiddleLine.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        [bubbleImageView addSubview:evaluateMiddleLine];

        positiveBtn = [UIButton new];
        positiveBtn.backgroundColor = [UIColor clearColor];
        [positiveBtn setTitle:@"解决" forState:UIControlStateNormal];
        positiveBtn.titleLabel.font = [UIFont systemFontOfSize:kMQBotAnswerEvaluateTextSize];
        [positiveBtn setTitleColor:botBtnColor forState:UIControlStateNormal];
        [positiveBtn addTarget:self action:@selector(didTapPositive:) forControlEvents:UIControlEventTouchUpInside];
        [bubbleImageView addSubview:positiveBtn];

        negativeBtn = [UIButton new];
        negativeBtn.backgroundColor = [UIColor clearColor];
        [negativeBtn setTitle:@"未解决" forState:UIControlStateNormal];
        negativeBtn.titleLabel.font = [UIFont systemFontOfSize:kMQBotAnswerEvaluateTextSize];
        [negativeBtn setTitleColor:botBtnColor forState:UIControlStateNormal];
        [negativeBtn addTarget:self action:@selector(didTapNegative:) forControlEvents:UIControlEventTouchUpInside];
        [bubbleImageView addSubview:negativeBtn];

        evaluateDoneBtn = [UIButton new];
        evaluateDoneBtn.backgroundColor = [UIColor clearColor];
        [evaluateDoneBtn setTitle:@"已反馈" forState:UIControlStateNormal];
        evaluateDoneBtn.titleLabel.font = [UIFont systemFontOfSize:kMQBotAnswerEvaluateTextSize];
        [evaluateDoneBtn setTitleColor:[UIColor colorWithWhite:.6 alpha:1] forState:UIControlStateNormal];
        [bubbleImageView addSubview:evaluateDoneBtn];
        
        replyBtn = [UIButton new];
        replyBtn.backgroundColor = [UIColor clearColor];
        [replyBtn setTitle:@"留言" forState:UIControlStateNormal];
        replyBtn.titleLabel.font = [UIFont systemFontOfSize:kMQBotAnswerEvaluateTextSize];
        [replyBtn setTitleColor:botBtnColor forState:UIControlStateNormal];
        [replyBtn addTarget:self action:@selector(didTapReply:) forControlEvents:UIControlEventTouchUpInside];
        [bubbleImageView addSubview:replyBtn];
    }
    return self;
}

#pragma MQChatCellProtocol
- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if (![model isKindOfClass:[MQBotAnswerCellModel class]]) {
        NSAssert(NO, @"传给 MQBotAnswerCellModel.h 的Model类型不正确");
        return ;
    }
    MQBotAnswerCellModel *cellModel = (MQBotAnswerCellModel *)model;
    
    messageId = cellModel.messageId;
    //刷新头像
    if (cellModel.avatarImage) {
        avatarImageView.image = cellModel.avatarImage;
    }
    avatarImageView.frame = cellModel.avatarFrame;
    if ([MQChatViewConfig sharedConfig].enableRoundAvatar) {
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.layer.cornerRadius = cellModel.avatarFrame.size.width/2;
    }
    
    //刷新气泡
    bubbleImageView.image = cellModel.bubbleImage;
    bubbleImageView.frame = cellModel.bubbleImageFrame;
    
    //刷新indicator
    sendingIndicator.hidden = true;
    [sendingIndicator stopAnimating];
    if (cellModel.sendStatus == MQChatMessageSendStatusSending && cellModel.cellFromType == MQChatCellOutgoing) {
        sendingIndicator.hidden = false;
        sendingIndicator.frame = cellModel.sendingIndicatorFrame;
        [sendingIndicator startAnimating];
    }
    
    //刷新聊天文字
    textLabel.frame = cellModel.textLabelFrame;
    if ([textLabel isKindOfClass:[TTTAttributedLabel class]]) {
        textLabel.text = cellModel.cellText;
    } else {
        textLabel.attributedText = cellModel.cellText;
    }
    //判断文字是否居中显示
    CGFloat messageTextWidth = [MQStringSizeUtil getWidthForAttributedText:cellModel.cellText textHeight:cellModel.textLabelFrame.size.height];
    if (cellModel.textLabelFrame.size.width > messageTextWidth && ![cellModel.normalSubTypes containsObject:cellModel.messageSubType]) {
        textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    //获取文字中的可选中的元素
    if (cellModel.numberRangeDic.count > 0) {
        NSString *longestKey = @"";
        for (NSString *key in cellModel.numberRangeDic.allKeys) {
            //找到最长的key
            if (key.length > longestKey.length) {
                longestKey = key;
            }
        }
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
            [textLabel addLinkToPhoneNumber:longestKey withRange:[cellModel.numberRangeDic[longestKey] rangeValue]];
        }
    }
    if (cellModel.linkNumberRangeDic.count > 0) {
        NSString *longestKey = @"";
        for (NSString *key in cellModel.linkNumberRangeDic.allKeys) {
            //找到最长的key
            if (key.length > longestKey.length) {
                longestKey = key;
            }
        }
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
            [textLabel addLinkToURL:[NSURL URLWithString:longestKey] withRange:[cellModel.linkNumberRangeDic[longestKey] rangeValue]];
        }
    }
    if (cellModel.emailNumberRangeDic.count > 0) {
        NSString *longestKey = @"";
        for (NSString *key in cellModel.emailNumberRangeDic.allKeys) {
            //找到最长的key
            if (key.length > longestKey.length) {
                longestKey = key;
            }
        }
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
            [textLabel addLinkToTransitInformation:@{@"email" : longestKey} withRange:[cellModel.emailNumberRangeDic[longestKey] rangeValue]];
        }
    }
    
    //刷新出错图片
    failureImageView.hidden = true;
    if (cellModel.sendStatus == MQChatMessageSendStatusFailure) {
        failureImageView.hidden = false;
        failureImageView.frame = cellModel.sendFailureFrame;
    }
    
    //评价
    evaluateUpperLine.frame = cellModel.evaluateUpperLineFrame;
    
    if ([cellModel.messageSubType isEqualToString:@"evaluate"]) {
        // 渲染评价样式
        replyBtn.hidden = true;
        evaluateMiddleLine.frame = cellModel.evaluateMiddleLineFrame;
        positiveBtn.frame = cellModel.positiveBtnFrame;
        negativeBtn.frame = cellModel.negativeBtnFrame;
        evaluateDoneBtn.frame = cellModel.evaluateDoneBtnFrame;
        positiveBtn.hidden = false;
        negativeBtn.hidden = false;
        evaluateMiddleLine.hidden = false;
        evaluateDoneBtn.hidden = true;
        positiveBtn.alpha = 1.0;
        negativeBtn.alpha = 1.0;
        evaluateMiddleLine.alpha = 1.0;
        evaluateDoneBtn.alpha = 0.0;
        if (cellModel.isEvaluated) {
            positiveBtn.hidden = true;
            negativeBtn.hidden = true;
            evaluateDoneBtn.hidden = false;
            evaluateDoneBtn.alpha = 1.0;
            evaluateMiddleLine.hidden = true;
        }
    } else if ([cellModel.messageSubType isEqualToString:@"reply"]) {
        // 渲染留言样式
        evaluateMiddleLine.hidden = true;
        positiveBtn.hidden = true;
        negativeBtn.hidden = true;
        evaluateDoneBtn.hidden = true;
        replyBtn.frame = cellModel.replyBtnFrame;
        replyBtn.hidden = false;
    } else if ([cellModel.normalSubTypes containsObject:cellModel.messageSubType]) {
        evaluateUpperLine.hidden = true;
        evaluateMiddleLine.hidden = true;
        positiveBtn.hidden = true;
        negativeBtn.hidden = true;
        evaluateDoneBtn.hidden = true;
        replyBtn.hidden = true;
    }
}

#pragma TTTAttributedLabelDelegate 点击事件
- (void)attributedLabel:(TTTAttributedLabel *)label
didLongPressLinkWithPhoneNumber:(NSString *)phoneNumber
                atPoint:(CGPoint)point {
    [self showMenueController];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:phoneNumber delegate:self cancelButtonTitle:[MQBundleUtil localizedStringForKey:@"alert_view_cancel"] destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"%@%@", [MQBundleUtil localizedStringForKey:@"make_call_to"], phoneNumber], [NSString stringWithFormat:@"%@%@", [MQBundleUtil localizedStringForKey:@"send_message_to"], phoneNumber], [MQBundleUtil localizedStringForKey:@"save_text"], nil];
    sheet.tag = kMQTextCellSelectedNumberActionSheetTag;
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:[MQBundleUtil localizedStringForKey:@"alert_view_cancel"] destructiveButtonTitle:nil otherButtonTitles:[MQBundleUtil localizedStringForKey:@"open_url_by_safari"], [MQBundleUtil localizedStringForKey:@"save_text"], nil];
    sheet.tag = kMQTextCellSelectedUrlActionSheetTag;
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    if (!components[@"email"]) {
        return ;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:components[@"email"] delegate:self cancelButtonTitle:[MQBundleUtil localizedStringForKey:@"alert_view_cancel"] destructiveButtonTitle:nil otherButtonTitles:[MQBundleUtil localizedStringForKey:@"make_email_to"], [MQBundleUtil localizedStringForKey:@"save_text"], nil];
    sheet.tag = kMQTextCellSelectedEmailActionSheetTag;
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MQChatViewKeyboardResignFirstResponderNotification object:nil];
    switch (actionSheet.tag) {
        case kMQTextCellSelectedNumberActionSheetTag: {
            switch (buttonIndex) {
                case 0:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", actionSheet.title]]];
                    break;
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", actionSheet.title]]];
                    break;
                case 2:
                    [UIPasteboard generalPasteboard].string = actionSheet.title;
                    break;
                default:
                    break;
            }
            break;
        }
        case kMQTextCellSelectedUrlActionSheetTag: {
            switch (buttonIndex) {
                case 0: {
                    if ([actionSheet.title rangeOfString:@"://"].location == NSNotFound) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", actionSheet.title]]];
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
                    }
                    break;
                }
                case 1:
                    [UIPasteboard generalPasteboard].string = actionSheet.title;
                    break;
                default:
                    break;
            }
            break;
        }
        case kMQTextCellSelectedEmailActionSheetTag: {
            switch (buttonIndex) {
                case 0: {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", actionSheet.title]]];
                    break;
                }
                case 1:
                    [UIPasteboard generalPasteboard].string = actionSheet.title;
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    //通知界面点击了消息
    if (self.chatCellDelegate) {
        if ([self.chatCellDelegate respondsToSelector:@selector(didSelectMessageInCell:messageContent:selectedContent:)]) {
            [self.chatCellDelegate didSelectMessageInCell:self messageContent:self.textLabel.text selectedContent:actionSheet.title];
        }
    }
}

#pragma 长按事件
- (void)longPressBubbleView:(id)sender {
    if (((UILongPressGestureRecognizer*)sender).state == UIGestureRecognizerStateBegan) {
        [self showMenueController];
    }
}

- (void)showMenueController {
    [self showMenuControllerInView:self targetRect:bubbleImageView.frame menuItemsName:@{@"textCopy" : textLabel.text}];
    
}

#pragma 点击发送失败消息，重新发送事件
- (void)tapFailImage:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"重新发送吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.chatCellDelegate resendMessageInCell:self resendData:@{@"text" : textLabel.text}];
    }
}

#pragma 点击「有用」按钮
- (void)didTapPositive:(id)sender{
    [self showEvaluateDoneBtnWithCompletion:^{
    }];
    if ([self.chatCellDelegate respondsToSelector:@selector(evaluateBotAnswer:messageId:)]) {
        [self.chatCellDelegate evaluateBotAnswer:true messageId:messageId];
    }
}

#pragma 点击「无用」按钮
- (void)didTapNegative:(id)sender{
    [self showEvaluateDoneBtnWithCompletion:^{
        if ([self.chatCellDelegate respondsToSelector:@selector(evaluateBotAnswer:messageId:)]) {
            [self.chatCellDelegate evaluateBotAnswer:false messageId:messageId];
        }
    }];
}

#pragma 点击「留言」按钮
- (void)didTapReply:(id)sender {
    if ([self.chatCellDelegate respondsToSelector:@selector(didTapReplyBtn)]) {
        [self.chatCellDelegate didTapReplyBtn];
    }
}

- (void)showEvaluateDoneBtnWithCompletion:(void(^)(void))completion {
    [UIView animateWithDuration:0.5 animations:^{
        positiveBtn.alpha = 0.0;
        negativeBtn.alpha = 0.0;
        evaluateDoneBtn.alpha = 1.0;
        evaluateMiddleLine.alpha = 0.0;
    } completion:^(BOOL finished) {
        positiveBtn.hidden = true;
        negativeBtn.hidden = true;
        evaluateMiddleLine.hidden = true;
        evaluateDoneBtn.hidden = false;
        completion();
    }];
}


@end
