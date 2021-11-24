//
//  MQWebViewBubbleCell.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQWebViewBubbleCell.h"
#import "MQChatViewConfig.h"
#import "UIView+MQLayout.h"
#import "MQCellModelProtocol.h"
#import "MQImageUtil.h"
#import "MQWebViewBubbleCellModel.h"
#import "MQTagListView.h"
#import "MQBundleUtil.h"

@interface MQWebViewBubbleCell()

@property (nonatomic, strong) UIImageView *itemsView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) MQEmbededWebView *contentWebView;
@property (nonatomic, strong) MQWebViewBubbleCellModel *webViewCellModel;
@end

@implementation MQWebViewBubbleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.itemsView];
        [self.itemsView addSubview:self.contentWebView];
        [self layoutUI];
        [self updateUI:0];
    }
    return self;
}

- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if ([model isKindOfClass:[MQWebViewBubbleCellModel class]]) {
        MQWebViewBubbleCellModel * tempModel = model;
        self.webViewCellModel = tempModel;
        __weak typeof(self) wself = self;
        
        __weak typeof(tempModel) weakTempModel = tempModel;
        [tempModel setCellHeight:^CGFloat{
            __strong typeof (wself) sself = wself;
            if (weakTempModel.cachedWetViewHeight) {
                CGFloat tagViewHeight = 0;
                if (self.webViewCellModel.cacheTagListView) {
                    tagViewHeight = self.webViewCellModel.cacheTagListView.viewHeight + kMQCellBubbleToIndicatorSpacing;
                }
                return weakTempModel.cachedWetViewHeight + kMQCellAvatarToVerticalEdgeSpacing + kMQCellAvatarToVerticalEdgeSpacing + tagViewHeight;
            }
            return sself.viewHeight;
        }];
        
        [tempModel setAvatarLoaded:^(UIImage *avatar) {
            __strong typeof (wself) sself = wself;
            sself.avatarImageView.image = avatar;
        }];
        
        [self.contentWebView loadHTML:tempModel.content WithCompletion:^(CGFloat height) {
            __strong typeof (wself) sself = wself;
            if (tempModel.cachedWetViewHeight != height) {
                [sself updateUI:height];
                tempModel.cachedWetViewHeight = height;
                [sself.chatCellDelegate reloadCellAsContentUpdated:sself messageId:[tempModel getCellMessageId]];
            }
        }];
        
        [self.contentWebView setTappedLink:^(NSURL *url) {
            if ([url.absoluteString rangeOfString:@"://"].location == NSNotFound) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@", url.absoluteString]]];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        
        if (tempModel.cachedWetViewHeight > 0) {
            [self updateUI:tempModel.cachedWetViewHeight];
        }
        
        [tempModel bind];
    }
}

- (void)layoutUI {
    [self.avatarImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarToVerticalEdgeSpacing)];
    [self.itemsView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.avatarImageView.viewRightEdge + kMQCellAvatarToBubbleSpacing, self.avatarImageView.viewY)];
    self.itemsView.viewWidth = self.contentView.viewWidth - kMQCellBubbleMaxWidthToEdgeSpacing - self.avatarImageView.viewRightEdge;
    
    self.contentWebView.viewWidth = self.itemsView.viewWidth - 8;
    self.contentWebView.viewX = 8;
}

- (void)updateUI:(CGFloat)webContentHeight {
    CGFloat bubbleHeight = MAX(self.avatarImageView.viewHeight, webContentHeight);
    
    self.contentWebView.viewHeight = webContentHeight;
    self.itemsView.viewHeight = bubbleHeight;
    CGFloat tagViewHeight = 0;
    
    for (UIView *tempView in self.contentView.subviews) {
        if ([tempView isKindOfClass:[MQTagListView class]]) {
            [tempView removeFromSuperview];
        }
    }
    if (self.webViewCellModel.cacheTagListView) {
        tagViewHeight = self.webViewCellModel.cacheTagListView.viewHeight + kMQCellBubbleToIndicatorSpacing;
        self.webViewCellModel.cacheTagListView.frame = CGRectMake(CGRectGetMinX(self.itemsView.frame), CGRectGetMaxY(self.itemsView.frame) + kMQCellBubbleToIndicatorSpacing, self.webViewCellModel.cacheTagListView.bounds.size.width, self.webViewCellModel.cacheTagListView.bounds.size.height);
        [self.contentView addSubview:self.webViewCellModel.cacheTagListView];
        
        NSArray *cacheTags = [[NSArray alloc] initWithArray:self.webViewCellModel.cacheTags];
        __weak __typeof(self) weakSelf = self;
        self.webViewCellModel.cacheTagListView.mqTagListSelectedIndex = ^(NSInteger index) {
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
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", model.value]]];
                    break;
                case MQMessageBottomTagTypeLink:
                    if ([model.value rangeOfString:@"://"].location == NSNotFound) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", model.value]]];
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.value]];
                    }
                    break;
                default:
                    break;
            }
        };
    }
    self.contentView.viewHeight = self.itemsView.viewBottomEdge + kMQCellAvatarToVerticalEdgeSpacing + tagViewHeight;
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

- (UIImageView *)itemsView {
    if (!_itemsView) {
        _itemsView = [UIImageView new];
        _itemsView.userInteractionEnabled = true;
        UIImage *bubbleImage = [MQChatViewConfig sharedConfig].incomingBubbleImage;
        if ([MQChatViewConfig sharedConfig].incomingBubbleColor) {
            bubbleImage = [MQImageUtil convertImageColorWithImage:bubbleImage toColor:[MQChatViewConfig sharedConfig].incomingBubbleColor];
        }
        bubbleImage = [bubbleImage resizableImageWithCapInsets:[MQChatViewConfig sharedConfig].bubbleImageStretchInsets];
        _itemsView.image = bubbleImage;
        _itemsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _itemsView;
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

@end
