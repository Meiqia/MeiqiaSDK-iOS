//
//  MQBotMenuCell.m
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 16/4/27.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQBotMenuCell.h"
#import "MQWindowUtil.h"
#import "MQChatFileUtil.h"
#import "MQChatViewConfig.h"
#import "MQBundleUtil.h"
#import "MQBotMenuCellModel.h"
#import "MQTTTAttributedLabel.h"
#import "MQBundleUtil.h"

static const NSInteger kMQBotMenuCellSelectedUrlActionSheetTag = 2000;
static const NSInteger kMQBotMenuCellSelectedNumberActionSheetTag = 2001;
static const NSInteger kMQBotMenuCellSelectedEmailActionSheetTag = 2002;

@interface MQBotMenuCell() <MQTTTAttributedLabelDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@end

@implementation MQBotMenuCell  {
    UIImageView *avatarImageView;
    MQTTTAttributedLabel *textLabel;
    UIImageView *bubbleImageView;
    UIActivityIndicatorView *sendingIndicator;
    UIImageView *failureImageView;
    NSMutableArray *menuButtons;
    UILabel *replyTipLabel;
    UILabel *menuTipLabel;
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
//        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
//            textLabel = [[MQTTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
//            textLabel.delegate = self;
//        } else {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
//            textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
//#pragma clang diagnostic pop
//        }
        
        textLabel = [[MQTTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];

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
        // 初始化 reply tip label
        menuTipLabel = [UILabel new];
        menuTipLabel.textColor = [UIColor blackColor];
        menuTipLabel.text = [MQBundleUtil localizedStringForKey:@"bot_menu_problem_tip_text"];
        menuTipLabel.textAlignment = NSTextAlignmentLeft;
        menuTipLabel.font = [UIFont systemFontOfSize:kMQBotMenuTipSize];
        menuTipLabel.hidden = false;
        [bubbleImageView addSubview:menuTipLabel];
        // 初始化 menu button 数组
        menuButtons = [NSMutableArray new];
        // 初始化 reply tip label
        replyTipLabel = [UILabel new];
        replyTipLabel.textColor = [UIColor colorWithWhite:.6 alpha:1];
        replyTipLabel.text = [MQBundleUtil localizedStringForKey:@"bot_menu_tip_text"];
        replyTipLabel.numberOfLines = 0;
        replyTipLabel.textAlignment = NSTextAlignmentLeft;
        replyTipLabel.font = [UIFont systemFontOfSize:kMQBotMenuReplyTipSize];
        replyTipLabel.hidden = false;
        [bubbleImageView addSubview:replyTipLabel];
    }
    return self;
}

#pragma MQChatCellProtocol
- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if (![model isKindOfClass:[MQBotMenuCellModel class]]) {
        NSAssert(NO, @"传给 MQBotMenuCellModel 的 Model 类型不正确");
        return ;
    }
    MQBotMenuCellModel *cellModel = (MQBotMenuCellModel *)model;
    
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
    
//    //获取文字中的可选中的元素
//    if (cellModel.numberRangeDic.count > 0) {
//        NSString *longestKey = @"";
//        for (NSString *key in cellModel.numberRangeDic.allKeys) {
//            //找到最长的key
//            if (key.length > longestKey.length) {
//                longestKey = key;
//            }
//        }
//        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
//            [textLabel addLinkToPhoneNumber:longestKey withRange:[cellModel.numberRangeDic[longestKey] rangeValue]];
//        }
//    }
//    if (cellModel.linkNumberRangeDic.count > 0) {
//        NSString *longestKey = @"";
//        for (NSString *key in cellModel.linkNumberRangeDic.allKeys) {
//            //找到最长的key
//            if (key.length > longestKey.length) {
//                longestKey = key;
//            }
//        }
//        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
//            [textLabel addLinkToURL:[NSURL URLWithString:longestKey] withRange:[cellModel.linkNumberRangeDic[longestKey] rangeValue]];
//        }
//    }
//    if (cellModel.emailNumberRangeDic.count > 0) {
//        NSString *longestKey = @"";
//        for (NSString *key in cellModel.emailNumberRangeDic.allKeys) {
//            //找到最长的key
//            if (key.length > longestKey.length) {
//                longestKey = key;
//            }
//        }
//        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
//            [textLabel addLinkToTransitInformation:@{@"email" : longestKey} withRange:[cellModel.emailNumberRangeDic[longestKey] rangeValue]];
//        }
//    }
    
    //刷新出错图片
    failureImageView.hidden = true;
    if (cellModel.sendStatus == MQChatMessageSendStatusFailure) {
        failureImageView.hidden = false;
        failureImageView.frame = cellModel.sendFailureFrame;
    }
    
    // 重置 menu buttons
    NSInteger menuNum = [cellModel.menuTitles count];
    for (UIButton *btn in menuButtons) {
        [btn removeFromSuperview];
    }
    menuButtons = [NSMutableArray new];
    for (NSInteger i = 0; i < menuNum; i++) {
        UIButton *menuButton = [UIButton new];
        menuButton.frame = [[cellModel.menuFrames objectAtIndex:i] CGRectValue];
        [menuButton setTitle:[cellModel.menuTitles objectAtIndex:i] forState:UIControlStateNormal];
        [menuButton setTitleColor:[MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor forState:UIControlStateNormal];
        menuButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [menuButton addTarget:self action:@selector(tapMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
        menuButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        menuButton.titleLabel.numberOfLines = 0;
        menuButton.titleLabel.font = [UIFont systemFontOfSize:kMQBotMenuTextSize];
        [menuButtons addObject:menuButton];
        [bubbleImageView addSubview:menuButton];
    }
    
    // 刷新 reply tip label 和「常见问题」tip label
    if (menuNum > 0 && cellModel.needTip) {
        replyTipLabel.hidden = false;
        replyTipLabel.frame = cellModel.replyTipLabelFrame;
        menuTipLabel.hidden = false;
        menuTipLabel.frame = cellModel.menuTipLabelFrame;
    } else {
        replyTipLabel.hidden = true;
        replyTipLabel.frame = CGRectZero;
        menuTipLabel.hidden = true;
        menuTipLabel.frame = CGRectZero;
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
        case kMQBotMenuCellSelectedNumberActionSheetTag: {
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
        case kMQBotMenuCellSelectedUrlActionSheetTag: {
            switch (buttonIndex) {
                case 0: {
                    if ([actionSheet.title rangeOfString:@"://"].location == NSNotFound) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", actionSheet.title]]];
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title] options:@{} completionHandler:nil];
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
        case kMQBotMenuCellSelectedEmailActionSheetTag: {
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

#pragma 点击 menu 事件
- (void)tapMenuBtn:(UIButton *)menuBtn{
    NSString *didTapMenuText = menuBtn.titleLabel.text;
    if ([self.chatCellDelegate respondsToSelector:@selector(didTapMenuWithText:)]) {
        [self.chatCellDelegate didTapMenuWithText:didTapMenuText];
    }
}



@end
