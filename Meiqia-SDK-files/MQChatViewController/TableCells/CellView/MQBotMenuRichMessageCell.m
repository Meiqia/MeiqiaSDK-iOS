//
//  MQNewRichText1.m
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/12.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQBotMenuRichMessageCell.h"
#import "MQChatViewConfig.h"
#import "UIView+MQLayout.h"
#import "MQCellModelProtocol.h"
#import "MQImageUtil.h"
#import "MQBotMenuMessage.h"
#import "MQBotMenuRichCellModel.h"
#import "MQBundleUtil.h"

static CGFloat const kMQBotMenuReplyTipSize = 12.0; // 查看提醒的文字大小

static CGFloat const kMQBotMenuTextSize = 15.0;// 答案列表文字

static CGFloat const kMQBotMenuVerticalSpacingInMenus = 12.0;


@interface MQBotMenuRichMessageCell()
{
    NSMutableArray *menuButtons;
}

@property (nonatomic, strong) MQBotMenuRichCellModel *viewModel;
@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) MQEmbededWebView *contentWebView;
@property (nonatomic, strong) UIView *itemsView;
@property (nonatomic, strong) UILabel *replyTipLabel;

@end

@implementation MQBotMenuRichMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.bubbleImageView];
        [self.bubbleImageView addSubview:self.contentWebView];
        [self.bubbleImageView addSubview:self.itemsView];
        [self.bubbleImageView addSubview:self.replyTipLabel];
        
        [self layoutUI];
        [self updateUI:0];
    }
    return self;
}

- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if ([model isKindOfClass:[MQBotMenuRichCellModel class]]) {
        MQBotMenuRichCellModel * tempModel = model;
        self.viewModel = model;
        
        __weak typeof(self) wself = self;
        __weak typeof(tempModel) weakTempModel = tempModel;
        [tempModel setCellHeight:^CGFloat{
            __strong typeof (wself) sself = wself;
            if (weakTempModel.cachedWetViewHeight) {
                return tempModel.cachedWetViewHeight + kMQCellAvatarToVerticalEdgeSpacing + kMQCellAvatarToVerticalEdgeSpacing + 120;
            }
            return sself.viewHeight;
        }];
        
        [self.viewModel setAvatarLoaded:^(UIImage *avatar) {
            __strong typeof (wself) sself = wself;
            sself.avatarImageView.image = avatar;
        }];
        
        [self.contentWebView loadHTML:self.viewModel.content WithCompletion:^(CGFloat height) {
            __strong typeof (wself) sself = wself;
            if (tempModel.cachedWetViewHeight != height) {
                [sself updateUI:height];
                tempModel.cachedWetViewHeight = height;
                [sself.chatCellDelegate reloadCellAsContentUpdated:sself messageId:[tempModel getCellMessageId]];
            }
        }];
        
        [self.contentWebView setTappedLink:^(NSURL *url) {
            if ([url.absoluteString rangeOfString:@"://"].location == NSNotFound) {
                if ([url.absoluteString rangeOfString:@"tel:"].location != NSNotFound) {
                    // 和后台预定的是 tel:182xxxxxxxxx
                    NSString *path = [url.absoluteString stringByReplacingOccurrencesOfString:@"tel:" withString:@"tel://"];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@", url.absoluteString]]];
                }
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        
        if (self.viewModel.cachedWetViewHeight > 0) {
            [self updateUI:tempModel.cachedWetViewHeight];
        }
        
        
        NSArray *menuTitles = tempModel.message.menu;
        NSInteger menuNum = [menuTitles count];
        for (UIButton *btn in menuButtons) {
            [btn removeFromSuperview];
        }
        menuButtons = [NSMutableArray new];
        CGFloat menuOrigin = kMQCellBubbleToTextVerticalSpacing;
        CGFloat maxLabelWidth = 280;
        
        for (NSInteger i = 0; i < menuNum; i++) {
            UIButton *menuButton = [UIButton new];
            [menuButton setTitle:[menuTitles objectAtIndex:i] forState:UIControlStateNormal];
            [menuButton setFrame:CGRectMake(kMQCellBubbleToTextHorizontalLargerSpacing, menuOrigin, maxLabelWidth - 2*kMQCellBubbleToTextHorizontalLargerSpacing, 16)];
            menuOrigin += 16 + kMQBotMenuVerticalSpacingInMenus;
            [menuButton setTitleColor:[MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor forState:UIControlStateNormal];
            menuButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [menuButton addTarget:self action:@selector(tapMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
            menuButton.titleLabel.textAlignment = NSTextAlignmentLeft;
            menuButton.titleLabel.numberOfLines = 0;
            menuButton.titleLabel.font = [UIFont systemFontOfSize:kMQBotMenuTextSize];
            [menuButtons addObject:menuButton];
            [_itemsView addSubview:menuButton];
        }
        self.bubbleImageView.backgroundColor = UIColor.yellowColor;
        self.itemsView.frame = CGRectMake(0, 200, self.contentWebView.viewWidth, 120);
        self.bubbleImageView.frame = CGRectMake(0, 0, maxLabelWidth, 340);

        //    _contentWebView.frame = CGRectMake(0, kMQCellBubbleToTextVerticalSpacing, maxLabelWidth, 0);
        //    _itemsView.frame = CGRectMake(0, _contentWebView.viewBottomEdge, maxLabelWidth, menuOrigin);
        //
        
        if (menuNum > 0) {
            self.replyTipLabel.hidden = false;
        }
    
        [tempModel bind];
    }
    
}

- (void)layoutUI {
    [self.avatarImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing)];
    [self.bubbleImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.avatarImageView.viewRightEdge + kMQCellAvatarToBubbleSpacing, self.avatarImageView.viewY)];
    self.bubbleImageView.viewWidth = self.contentView.viewWidth - kMQCellBubbleMaxWidthToEdgeSpacing - self.avatarImageView.viewRightEdge;
    
    self.contentWebView.viewWidth = self.bubbleImageView.viewWidth - 8;
    self.contentWebView.viewX = 8;
    
}

- (void)updateUI:(CGFloat)webContentHeight {
    CGFloat bubbleHeight = MAX(self.avatarImageView.viewHeight, webContentHeight);
    
    self.contentWebView.viewHeight = bubbleHeight;
    //    self.itemsView.viewHeight =
    self.itemsView.viewY = self.contentWebView.viewBottomEdge;
    //    self.bubbleImageView.viewHeight = self.itemsView.viewBottomEdge;
    self.contentView.viewHeight = self.bubbleImageView.viewBottomEdge + kMQCellAvatarToVerticalEdgeSpacing;
    self.viewHeight = self.contentView.viewHeight;
}

#pragma lazy

- (MQEmbededWebView *)contentWebView {
    if (!_contentWebView) {
        _contentWebView = [MQEmbededWebView new];
        _contentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _contentWebView;
}

- (UIImageView *)bubbleImageView {
    if (!_bubbleImageView) {
        _bubbleImageView = [UIImageView new];
        _bubbleImageView.userInteractionEnabled = true;
        UIImage *bubbleImage = [MQChatViewConfig sharedConfig].incomingBubbleImage;
        if ([MQChatViewConfig sharedConfig].incomingBubbleColor) {
            bubbleImage = [MQImageUtil convertImageColorWithImage:bubbleImage toColor:[MQChatViewConfig sharedConfig].incomingBubbleColor];
        }
        bubbleImage = [bubbleImage resizableImageWithCapInsets:[MQChatViewConfig sharedConfig].bubbleImageStretchInsets];
        _bubbleImageView.image = bubbleImage;
        _bubbleImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _bubbleImageView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.viewSize = CGSizeMake(kMQCellAvatarDiameter, kMQCellAvatarDiameter);
        _avatarImageView.image = [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage;
        if ([MQChatViewConfig sharedConfig].enableRoundAvatar) {
            _avatarImageView.layer.masksToBounds = YES;
            _avatarImageView.layer.cornerRadius = _avatarImageView.viewSize.width/2;
        }
    }
    return _avatarImageView;
}

- (UILabel *)replyTipLabel{
    if (!_replyTipLabel) {
        _replyTipLabel = [UILabel new];
        _replyTipLabel.textColor = [UIColor colorWithWhite:.6 alpha:1];
        _replyTipLabel.text = [MQBundleUtil localizedStringForKey:@"bot_menu_tip_text"];
        _replyTipLabel.textAlignment = NSTextAlignmentLeft;
        _replyTipLabel.font = [UIFont systemFontOfSize:kMQBotMenuReplyTipSize];
        _replyTipLabel.hidden = false;
    }
    return _replyTipLabel;
}

@end
