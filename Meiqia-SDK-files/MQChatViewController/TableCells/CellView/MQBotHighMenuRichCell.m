//
//  MQBotHighMenuRichCell.m
//  MQEcoboostSDK-test
//
//  Created by Cassie on 2023/9/11.
//  Copyright © 2023 MeiQia Inc. All rights reserved.
//

#import "MQBotHighMenuRichCell.h"
#import "MQPageView.h"
#import "MQBotHighMenuRichCellModel.h"
#import "MQChatViewConfig.h"
#import <UIKit/UIKit.h>
#import "MQEmbededWebView.h"
#import "MQBundleUtil.h"
#import "UIView+MQLayout.h"

static const NSInteger kMQBotMenuCellSelectedUrlActionSheetTag = 2000;
static const NSInteger kMQBotMenuCellSelectedNumberActionSheetTag = 2001;
static const NSInteger kMQBotMenuCellSelectedEmailActionSheetTag = 2002;

@interface MQBotHighMenuRichCell ()<UIActionSheetDelegate>

@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UILabel *menuTitleLabel;

@property (nonatomic, strong) MQEmbededWebView *contentWebView;

@property (nonatomic, strong) UIView *menuBackView;

@property (nonatomic, strong) MQPageView *pageView;

@end

@implementation MQBotHighMenuRichCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化头像
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.avatarImageView];
        //初始化气泡
        self.bubbleImageView = [[UIImageView alloc] init];
        self.bubbleImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.bubbleImageView];
        
        [self.bubbleImageView addSubview:self.contentWebView];
        
        self.menuBackView = [[UIView alloc] init];
        self.menuBackView.backgroundColor = [UIColor whiteColor];
        self.menuBackView.clipsToBounds = YES;
        self.menuBackView.layer.cornerRadius = 8.0;
        self.menuBackView.layer.borderWidth = 1.0;
        self.menuBackView.layer.borderColor = [UIColor colorWithRed:244/255 green:242/255 blue:241/255 alpha:0.2].CGColor;
        [self.contentView addSubview:self.menuBackView];
        
        self.menuTitleLabel = [[UILabel alloc] init];
        self.menuTitleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        self.menuTitleLabel.textColor = [UIColor colorWithRed:29.0/255.0 green:39.0/255.0 blue:84.0/255.0 alpha:1.0];
        [self.menuBackView addSubview:self.menuTitleLabel];
    }
    return self;
}

#pragma MQChatCellProtocol
- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if (![model isKindOfClass:[MQBotHighMenuRichCellModel class]]) {
        NSAssert(NO, @"传给 MQBotHighMenuRichCell 的 Model 类型不正确");
        return ;
    }    
    MQBotHighMenuRichCellModel *cellModel = (MQBotHighMenuRichCellModel *)model;

    //刷新头像
    if (cellModel.avatarImage) {
        self.avatarImageView.image = cellModel.avatarImage;
    }
    self.avatarImageView.frame = cellModel.avatarFrame;
    if ([MQChatViewConfig sharedConfig].enableRoundAvatar) {
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.cornerRadius = cellModel.avatarFrame.size.width/2;
    }

    //刷新气泡
    self.bubbleImageView.image = cellModel.bubbleImage;
    self.bubbleImageView.frame = cellModel.bubbleImageFrame;
    
    self.menuTitleLabel.frame = cellModel.menuTipLabelFrame;
    self.menuTitleLabel.text = cellModel.menuTipText;
    
    self.menuBackView.frame = cellModel.menuBackFrame;
    
    [self.contentWebView loadHTML:cellModel.richText WithCompletion:^(CGFloat height) {
    }];
    self.contentWebView.frame = cellModel.textLabelFrame;
    
    [self.contentWebView setTappedLink:^(NSURL *url) {
        if ([url.absoluteString rangeOfString:@"://"].location == NSNotFound) {
            if ([url.absoluteString rangeOfString:@"tel:"].location != NSNotFound) {
                NSString *path = [url.absoluteString stringByReplacingOccurrencesOfString:@"tel:" withString:@"tel://"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@", url.absoluteString]]];
            }
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    
    if (!self.pageView) {
        [self.menuBackView addSubview:cellModel.pageView];
    }
//    if (self.pageView != cellModel.pageView) {
        for (UIView *tempView in self.menuBackView.subviews) {
            if (tempView != self.menuTitleLabel) {
                [tempView removeFromSuperview];
            }
        }
        [self.menuBackView addSubview:cellModel.pageView];
//    }
    
//    self.pageView = cellModel.pageView;
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
}

- (MQEmbededWebView *)contentWebView {
    if (!_contentWebView) {
        _contentWebView = [MQEmbededWebView new];
        _contentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _contentWebView;
}

@end
