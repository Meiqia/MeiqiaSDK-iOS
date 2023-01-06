//
//  MQBotWebViewBubbleAnswerCell.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQBotWebViewBubbleAnswerCell.h"
#import "MQBotWebViewBubbleAnswerCellModel.h"
#import "UIView+MQLayout.h"
#import "MQChatViewConfig.h"
#import "MQImageUtil.h"
#import "MQBundleUtil.h"
#import "MQAssetUtil.h"

#define FONT_SIZE_EVALUATE_BUTTON 16
#define SPACE_INTERNAL_VERTICAL 10

#define BUTTON_HEIGHT 32
#define BUTTON_WIDTH 76

static CGFloat const kMQButtonToBubbleVerticalEdgeSpacing = 5.0;

@interface MQBotWebViewBubbleAnswerCell()

@property (nonatomic, strong) UIImageView *itemsView; //底部气泡
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) MQEmbededWebView *contentWebView;
@property (nonatomic, strong) UIButton *solvedButton;
@property (nonatomic, strong) UIButton *unsolvedButton;
@property (nonatomic, strong) MQBotWebViewBubbleAnswerCellModel *viewModel;

@end

@implementation MQBotWebViewBubbleAnswerCell

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
    if ([model isKindOfClass:[MQBotWebViewBubbleAnswerCellModel class]]) {
        MQBotWebViewBubbleAnswerCellModel * tempModel = model;
        self.viewModel = model;
        
        __weak typeof(self) wself = self;
        __weak typeof(tempModel) weakTempModel = tempModel;
        [tempModel setCellHeight:^CGFloat{
            __strong typeof (wself) sself = wself;
            if (weakTempModel.cachedWebViewHeight > 0) {
                return weakTempModel.cachedWebViewHeight + 2 * kMQCellAvatarToVerticalEdgeSpacing  + (sself.viewModel.needShowFeedback ? SPACE_INTERNAL_VERTICAL + BUTTON_HEIGHT : 0);
            }
            return sself.viewHeight;
        }];
        
        [tempModel setAvatarLoaded:^(UIImage *avatar) {
           __strong typeof (wself) sself = wself;
            sself.avatarImageView.image = avatar;
        }];
        
        [self.contentWebView loadHTML:tempModel.content WithCompletion:^(CGFloat height) {
            __strong typeof (wself) sself = wself;
            if (height != tempModel.cachedWebViewHeight) {
                [tempModel setCachedWebViewHeight:height];
                [sself updateUI:height];
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
        
        if (tempModel.cachedWebViewHeight > 0) {
            [self updateUI:tempModel.cachedWebViewHeight];
        }
        
        [tempModel bind];
        
        if (tempModel.needShowFeedback) {
            self.solvedButton.enabled = !tempModel.isEvaluated;
            self.unsolvedButton.enabled = !tempModel.isEvaluated;
            self.solvedButton.hidden = tempModel.isEvaluated ? !tempModel.solved : NO;
            self.unsolvedButton.hidden = tempModel.isEvaluated ? tempModel.solved : NO;
            [self updateUnsolvedButtonLayout:tempModel.isEvaluated andSolved:tempModel.solved];
        }
        
    }
}

- (void)layoutUI {
    
    [self.avatarImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarToHorizontalEdgeSpacing)];
    [self.itemsView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.avatarImageView.viewRightEdge + kMQCellAvatarToBubbleSpacing, self.avatarImageView.viewY)];
    self.itemsView.viewWidth = self.contentView.viewWidth - kMQCellBubbleMaxWidthToEdgeSpacing - self.avatarImageView.viewRightEdge;
    self.contentWebView.viewWidth = self.itemsView.viewWidth - 2 * kMQCellBubbleToTextHorizontalSmallerSpacing;
    self.contentWebView.viewX = kMQCellBubbleToTextHorizontalSmallerSpacing;
}

- (void)updateUI:(CGFloat)webContentHeight {
    
    self.contentWebView.viewHeight = webContentHeight;
    CGFloat viewBottomEdge = self.contentWebView.viewBottomEdge;
    CGFloat bubbleHeight = MAX(self.avatarImageView.viewHeight, viewBottomEdge);
    self.itemsView.viewHeight = bubbleHeight;
    
    if (self.viewModel.needShowFeedback) {
        //recreate evaluate view
        if (![self.contentView.subviews containsObject:self.solvedButton]) {
            [self.contentView addSubview:self.solvedButton];
            [self.contentView addSubview:self.unsolvedButton];
        }
        [self.solvedButton align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.itemsView.viewX + kMQButtonToBubbleVerticalEdgeSpacing, self.itemsView.viewBottomEdge + SPACE_INTERNAL_VERTICAL)];
        [self.unsolvedButton align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.solvedButton.viewRightEdge + 8, self.solvedButton.viewY)];
    } else {
        [self.solvedButton removeFromSuperview];
        [self.unsolvedButton removeFromSuperview];
    }
    self.contentView.viewHeight = (!self.viewModel.needShowFeedback ? self.itemsView.viewBottomEdge : self.solvedButton.viewBottomEdge) + kMQCellAvatarToVerticalEdgeSpacing;
    self.viewHeight = self.contentView.viewHeight;
}

- (void)updateUnsolvedButtonLayout:(BOOL)isEvaluated andSolved:(BOOL)solved {
    if (!isEvaluated) {
        [self.unsolvedButton align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.solvedButton.viewRightEdge + 8, self.solvedButton.viewY)];
    } else {
        if (!solved) {
            [self.unsolvedButton align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.solvedButton.viewX, self.solvedButton.viewY)];
        }
    }
}

#pragma mark - actions

- (void)didTapPositive:(UIButton *)btn {
    
    BOOL solved = btn == self.solvedButton;
    self.solvedButton.enabled = NO;
    self.unsolvedButton.enabled = NO;
    self.solvedButton.hidden = !solved;
    self.unsolvedButton.hidden = solved;
    [self updateUnsolvedButtonLayout:YES andSolved:solved];
    if ([self.chatCellDelegate respondsToSelector:@selector(evaluateBotAnswer:messageId:)]) {
        [self.chatCellDelegate evaluateBotAnswer:solved messageId:self.viewModel.messageId];
    }
}


#pragma - lazy

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
        _avatarImageView.contentMode = UIViewContentModeScaleToFill;
        _avatarImageView.viewSize = CGSizeMake(kMQCellAvatarDiameter, kMQCellAvatarDiameter);
        _avatarImageView.image = [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage;
        if ([MQChatViewConfig sharedConfig].enableRoundAvatar) {
            _avatarImageView.layer.masksToBounds = YES;
            _avatarImageView.layer.cornerRadius = _avatarImageView.viewSize.width/2;
        }
    }
    return _avatarImageView;
}

- (UIButton *)solvedButton {
    if (!_solvedButton) {
        _solvedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _solvedButton.bounds = CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
        _solvedButton.clipsToBounds = YES;
        _solvedButton.layer.cornerRadius = 3.0;
        _solvedButton.layer.borderWidth = 1.0;
        _solvedButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 3);
        _solvedButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _solvedButton.layer.borderColor = [UIColor colorWithRed:244/255 green:242/255 blue:241/255 alpha:0.2].CGColor;
        [_solvedButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_EVALUATE_BUTTON]];
        [_solvedButton setTitle:[MQBundleUtil localizedStringForKey:@"mq_solved"] forState:UIControlStateNormal];
        [_solvedButton setTitleColor:[UIColor colorWithRed:29/255 green:39/255 blue:84/255 alpha:1.0] forState:UIControlStateNormal];
        [_solvedButton setTitleColor:[UIColor colorWithRed:29/255 green:39/255 blue:84/255 alpha:0.5] forState:UIControlStateHighlighted];
        [_solvedButton setImage:[MQAssetUtil imageFromBundleWithName:@"thumb-up-line"] forState:UIControlStateNormal];
        [_solvedButton setImage:[MQAssetUtil imageFromBundleWithName:@"thumb-up-fill"] forState:UIControlStateDisabled];
        [_solvedButton addTarget:self action:@selector(didTapPositive:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _solvedButton;
}

- (UIButton *)unsolvedButton {
    if (!_unsolvedButton) {
        _unsolvedButton= [UIButton buttonWithType:UIButtonTypeCustom];
        _unsolvedButton.bounds = CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
        _unsolvedButton.clipsToBounds = YES;
        _unsolvedButton.layer.cornerRadius = 3.0;
        _unsolvedButton.layer.borderWidth = 1.0;
        _unsolvedButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 3);
        _unsolvedButton.layer.borderColor = [UIColor colorWithRed:244/255 green:242/255 blue:241/255 alpha:0.2].CGColor;
        [_unsolvedButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_EVALUATE_BUTTON]];
        [_unsolvedButton setTitle:[MQBundleUtil localizedStringForKey:@"mq_unsolved"] forState:UIControlStateNormal];
        [_unsolvedButton setTitleColor:[UIColor colorWithRed:29/255 green:39/255 blue:84/255 alpha:1.0] forState:UIControlStateNormal];
        [_unsolvedButton setTitleColor:[UIColor colorWithRed:29/255 green:39/255 blue:84/255 alpha:0.5] forState:UIControlStateHighlighted];
        [_unsolvedButton setImage:[MQAssetUtil imageFromBundleWithName:@"thumb-down-line"] forState:UIControlStateNormal];
        [_unsolvedButton setImage:[MQAssetUtil imageFromBundleWithName:@"thumb-down-fill"] forState:UIControlStateDisabled];
        [_unsolvedButton addTarget:self action:@selector(didTapPositive:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _unsolvedButton;
}
@end
