//
//  MQTextMessageCell.m
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import "MQTextMessageCell.h"
#import "MQWindowUtil.h"
#import "MQChatFileUtil.h"
#import "MQChatViewConfig.h"
#import "MQBundleUtil.h"
#import "MQTextCellModel.h"
#import "MQTTTAttributedLabel.h"
#import "MQTagListView.h"

static const NSInteger kMQTextCellSelectedUrlActionSheetTag = 2000;
static const NSInteger kMQTextCellSelectedNumberActionSheetTag = 2001;
static const NSInteger kMQTextCellSelectedEmailActionSheetTag = 2002;
static const NSString *kMQTextCellsensitiveWords = @"！消息包含不规范用语";

@interface MQTextMessageCell() <MQTTTAttributedLabelDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@end

@implementation MQTextMessageCell  {
    UIImageView *avatarImageView;
    MQTTTAttributedLabel *textLabel;
    UILabel *sensitiveTextLabel;
    UIImageView *bubbleImageView;
    UIActivityIndicatorView *sendingIndicator;
    UIImageView *failureImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
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
            textLabel = [[MQTTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
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
        sensitiveTextLabel = [[UILabel alloc] init];
        sensitiveTextLabel.text = [NSString stringWithFormat:@"%@",kMQTextCellsensitiveWords];
        sensitiveTextLabel.textColor = [UIColor grayColor];
        sensitiveTextLabel.font = [UIFont systemFontOfSize:14];
        [sensitiveTextLabel setHidden:YES];
        [self.contentView addSubview:sensitiveTextLabel];
    }
    return self;
}

#pragma MQChatCellProtocol
- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if (![model isKindOfClass:[MQTextCellModel class]]) {
        NSAssert(NO, @"传给MQTextMessageCell的Model类型不正确");
        return ;
    }
    MQTextCellModel *cellModel = (MQTextCellModel *)model;
    
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
    if ([textLabel isKindOfClass:[MQTTTAttributedLabel class]]) {
        textLabel.text = cellModel.cellText;
    } else {
        textLabel.attributedText = cellModel.cellText;
    }
    //获取文字中的可选中的元素
    if (cellModel.emailNumberRangeDic.count > 0) {
        for (NSString *key in cellModel.emailNumberRangeDic.allKeys) {
            NSRange range = [cellModel.emailNumberRangeDic[key] rangeValue];
            // 验证范围是否有效
            NSString *labelText = textLabel.text;
            if (range.location != NSNotFound && labelText && 
                range.location + range.length <= labelText.length) {
                [textLabel addLinkToTransitInformation:@{@"email" : key} withRange:range];
            }
        }
    }
    if (cellModel.numberRangeDic.count > 0) {
        for (NSString *key in cellModel.numberRangeDic.allKeys) {
            NSRange range = [cellModel.numberRangeDic[key] rangeValue];
            // 验证范围是否有效
            NSString *labelText = textLabel.text;
            if (range.location != NSNotFound && labelText && 
                range.location + range.length <= labelText.length) {
                [textLabel addLinkToPhoneNumber:key withRange:range];
            }
        }
    }
    if (cellModel.linkNumberRangeDic.count > 0) {
        for (NSString *key in cellModel.linkNumberRangeDic.allKeys) {
            NSRange range = [cellModel.linkNumberRangeDic[key] rangeValue];
            // 验证范围是否有效
            NSString *labelText = textLabel.text;
            if (range.location != NSNotFound && labelText && 
                range.location + range.length <= labelText.length) {
                [textLabel addLinkToURL:[NSURL URLWithString:key] withRange:range];
            }
        }
    }
    
    //刷新出错图片
    failureImageView.hidden = true;
    if (cellModel.sendStatus == MQChatMessageSendStatusFailure) {
        failureImageView.hidden = false;
        failureImageView.frame = cellModel.sendFailureFrame;
    }
    
    [sensitiveTextLabel setHidden:!cellModel.isSensitive];
    sensitiveTextLabel.frame = cellModel.sensitiveLableFrame;
    
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
            MQMessageBottomTagModel * model = cacheTags[index];
            switch (model.tagType) {
                case MQMessageBottomTagTypeCopy:
                    [[UIPasteboard generalPasteboard] setString:model.value];
                    if (strongSelf.chatCellDelegate) {
                        if ([strongSelf.chatCellDelegate respondsToSelector:@selector(showToastViewInCell:toastText:)]) {
                            [strongSelf.chatCellDelegate showToastViewInCell:strongSelf toastText:[MQBundleUtil localizedStringForKey:@"save_text_success"]];
                        }
                    }
                    break;
                case MQMessageBottomTagTypeCall:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", model.value]] options:@{} completionHandler:nil];
                    break;
                case MQMessageBottomTagTypeLink:
                    if ([model.value rangeOfString:@"://"].location == NSNotFound) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", model.value]] options:@{} completionHandler:nil];
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.value] options:@{} completionHandler:nil];
                    }
                    break;
                default:
                    break;
            }
        };
    }
}

#pragma MQTTTAttributedLabelDelegate 点击事件
- (void)attributedLabel:(MQTTTAttributedLabel *)label
didLongPressLinkWithPhoneNumber:(NSString *)phoneNumber
                atPoint:(CGPoint)point {
    [self showMenueController];
}

- (void)attributedLabel:(MQTTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    NSString *messageContent = [textLabel.text copy];
    __weak typeof(self) weakSelf = self;
    [MQWindowUtil presentActionSheetWithTitle:phoneNumber actionTitles:@[[NSString stringWithFormat:@"%@%@", [MQBundleUtil localizedStringForKey:@"make_call_to"], phoneNumber], [NSString stringWithFormat:@"%@%@", [MQBundleUtil localizedStringForKey:@"send_message_to"], phoneNumber], [MQBundleUtil localizedStringForKey:@"save_text"]] cancelTitle:[MQBundleUtil localizedStringForKey:@"alert_view_cancel"] sourceView:label handler:^(NSInteger index) {
        if (index == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]] options:@{} completionHandler:nil];
        } else if (index == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", phoneNumber]] options:@{} completionHandler:nil];
        } else if (index == 2) {
            [UIPasteboard generalPasteboard].string = phoneNumber;
        }
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if ([strongSelf.chatCellDelegate respondsToSelector:@selector(didSelectMessageInCell:messageContent:selectedContent:)]) {
            [strongSelf.chatCellDelegate didSelectMessageInCell:strongSelf messageContent:messageContent selectedContent:phoneNumber];
        }
    }];
}

- (void)attributedLabel:(MQTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSString *urlString = url.absoluteString;
    NSString *messageContent = [textLabel.text copy];
    __weak typeof(self) weakSelf = self;
    [MQWindowUtil presentActionSheetWithTitle:urlString actionTitles:@[[MQBundleUtil localizedStringForKey:@"open_url_by_safari"], [MQBundleUtil localizedStringForKey:@"save_text"]] cancelTitle:[MQBundleUtil localizedStringForKey:@"alert_view_cancel"] sourceView:label handler:^(NSInteger index) {
        if (index == 0) {
            NSString *openString = [urlString rangeOfString:@"://"].location == NSNotFound ? [NSString stringWithFormat:@"http://%@", urlString] : urlString;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openString] options:@{} completionHandler:nil];
        } else if (index == 1) {
            [UIPasteboard generalPasteboard].string = urlString;
        }
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if ([strongSelf.chatCellDelegate respondsToSelector:@selector(didSelectMessageInCell:messageContent:selectedContent:)]) {
            [strongSelf.chatCellDelegate didSelectMessageInCell:strongSelf messageContent:messageContent selectedContent:urlString];
        }
    }];
}

- (void)attributedLabel:(MQTTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    if (!components[@"email"]) {
        return ;
    }
    NSString *email = components[@"email"];
    NSString *messageContent = [textLabel.text copy];
    __weak typeof(self) weakSelf = self;
    [MQWindowUtil presentActionSheetWithTitle:email actionTitles:@[[MQBundleUtil localizedStringForKey:@"make_email_to"], [MQBundleUtil localizedStringForKey:@"save_text"]] cancelTitle:[MQBundleUtil localizedStringForKey:@"alert_view_cancel"] sourceView:label handler:^(NSInteger index) {
        if (index == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", email]] options:@{} completionHandler:nil];
        } else if (index == 1) {
            [UIPasteboard generalPasteboard].string = email;
        }
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if ([strongSelf.chatCellDelegate respondsToSelector:@selector(didSelectMessageInCell:messageContent:selectedContent:)]) {
            [strongSelf.chatCellDelegate didSelectMessageInCell:strongSelf messageContent:messageContent selectedContent:email];
        }
    }];
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
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", actionSheet.title]] options:@{} completionHandler:nil];
                    break;
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", actionSheet.title]] options:@{} completionHandler:nil];
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
                    NSURL *url;
                    if ([actionSheet.title rangeOfString:@"://"].location == NSNotFound) {
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", actionSheet.title]];
                    } else {
                        url = [NSURL URLWithString:actionSheet.title];
                    }
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
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
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", actionSheet.title]] options:@{} completionHandler:nil];
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

#pragma 点击发送失败消息 重新发送事件
- (void)tapFailImage:(id)sender {
    NSString *text = [textLabel.text copy];
    if (text.length == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [MQWindowUtil presentAlertWithTitle:@"重新发送吗？" message:nil cancelTitle:@"取消" confirmTitle:@"确定" sourceView:self handler:^(BOOL confirmed) {
        if (confirmed) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf.chatCellDelegate resendMessageInCell:strongSelf resendData:@{@"text" : text}];
        }
    }];
}

#pragma UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.chatCellDelegate resendMessageInCell:self resendData:@{@"text" : textLabel.text}];
    }
}

@end
