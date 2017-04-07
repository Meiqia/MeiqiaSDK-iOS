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


#define TAG_MENUS 10
#define TAG_EVALUATE 11
#define HEIHGT_VIEW_EVALUATE 40
#define FONT_SIZE_CONTENT 16
#define FONT_SIZE_MENU_TITLE 13
#define FONT_SIZE_MENU 15
#define FONT_SIZE_MENU_FOOTNOTE 12
#define FONT_SIZE_EVALUATE_BUTTON 14
#define SPACE_INTERNAL_VERTICAL 15

@interface MQBotWebViewBubbleAnswerCell()

@property (nonatomic, strong) UIImageView *itemsView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) MQEmbededWebView *contentWebView;
@property (nonatomic, strong) MQBotWebViewBubbleAnswerCellModel *viewModel;
@property (nonatomic, strong) UIView *evaluateView;
@property (nonatomic, strong) UIView *evaluatedView;
@property (nonatomic, assign) BOOL manuallySetToEvaluated;

@end

@implementation MQBotWebViewBubbleAnswerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.avatarImageView];
        [self addSubview:self.itemsView];
        [self.itemsView addSubview:self.contentWebView];
        [self layoutUI];
        [self updateUI:0];
    }
    return self;
}

- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    self.manuallySetToEvaluated = NO;
    self.viewModel = model;
    
    __weak typeof(self) wself = self;
    
    [self.viewModel setCellHeight:^CGFloat{
        __strong typeof (wself) sself = wself;
        if (sself.viewModel.cachedWebViewHeight > 0) {
            return sself.viewModel.cachedWebViewHeight + kMQCellAvatarToVerticalEdgeSpacing + kMQCellAvatarToVerticalEdgeSpacing + HEIHGT_VIEW_EVALUATE + SPACE_INTERNAL_VERTICAL;
        }
        return sself.viewHeight;
    }];
    
    [self.viewModel setAvatarLoaded:^(UIImage *avatar) {
       __strong typeof (wself) sself = wself;
        sself.avatarImageView.image = avatar;
    }];
    
    [self.contentWebView loadHTML:self.viewModel.content WithCompletion:^(CGFloat height) {
        __strong typeof (wself) sself = wself;
        if (height != self.viewModel.cachedWebViewHeight) {
            [sself.viewModel setCachedWebViewHeight:height];
            [sself updateUI:height];
            [sself.chatCellDelegate reloadCellAsContentUpdated:sself];
        }
    }];
    
    [self.contentWebView setTappedLink:^(NSURL *url) {
        [[UIApplication sharedApplication] openURL:url];
    }];
    
    if (self.viewModel.cachedWebViewHeight > 0) {
        [self updateUI:self.viewModel.cachedWebViewHeight];
    }
    
    [self.viewModel bind];
}

- (void)layoutUI {
    
    [self.avatarImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarToHorizontalEdgeSpacing)];
    [self.itemsView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.avatarImageView.viewRightEdge + kMQCellAvatarToBubbleSpacing, self.avatarImageView.viewY)];
    self.itemsView.viewWidth = self.contentView.viewWidth - kMQCellBubbleMaxWidthToEdgeSpacing - self.avatarImageView.viewRightEdge;
    
    self.contentWebView.viewWidth = self.itemsView.viewWidth - 8;
    self.contentWebView.viewX = 8;
}

- (void)updateUI:(CGFloat)webContentHeight {
    
    self.contentWebView.viewHeight = webContentHeight;
    //recreate evaluate view
    UIView *evaluateView = [self evaluateRelatedView];
    [[self.itemsView viewWithTag:evaluateView.tag] removeFromSuperview];
    [self.itemsView addSubview:evaluateView];
    [evaluateView align:(ViewAlignmentTopLeft) relativeToPoint:CGPointMake(8, self.contentWebView.viewBottomEdge + SPACE_INTERNAL_VERTICAL)];
    
    CGFloat bubbleHeight = MAX(self.avatarImageView.viewHeight, evaluateView.viewBottomEdge);
    self.itemsView.viewHeight = bubbleHeight;
    self.contentView.viewHeight = self.itemsView.viewBottomEdge + kMQCellAvatarToVerticalEdgeSpacing;
    self.viewHeight = self.contentView.viewHeight;
}

#pragma mark - actions

- (void)didTapPositive {
    
    [self updateEvaluateViewAnimatedComplete:^{
        if ([self.chatCellDelegate respondsToSelector:@selector(evaluateBotAnswer:messageId:)]) {
            [self.chatCellDelegate evaluateBotAnswer:true messageId:self.viewModel.messageId];
        }
    }];
}

- (void)didTapNegative {
    [self updateEvaluateViewAnimatedComplete:^{
        if ([self.chatCellDelegate respondsToSelector:@selector(evaluateBotAnswer:messageId:)]) {
            [self.chatCellDelegate evaluateBotAnswer:false messageId:self.viewModel.messageId];
        }
    }];
}

- (void)updateEvaluateViewAnimatedComplete:(void(^)(void))action {
    self.manuallySetToEvaluated = YES;
    
    UIView *oldView = [self.itemsView viewWithTag:TAG_EVALUATE];
    
    UIView *newView = [self evaluateRelatedView];
    newView.alpha = 0.0;
    newView.frame = oldView.frame;
    [self.itemsView addSubview:newView];
    
    [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            oldView.alpha = 0.0;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            newView.alpha = 1.0;
        }];
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
        if (action) {
            action();
        }
    }];
}

- (UIView *)evaluateRelatedView {
    UIView *view;
    if (self.viewModel.isEvaluated || self.manuallySetToEvaluated) {
        if (self.evaluateView.superview) {
            [self.evaluateView removeFromSuperview];
        }
        view = self.evaluatedView;
    } else {
        if (self.evaluatedView.superview) {
            [self.evaluatedView removeFromSuperview];
        }
        view = self.evaluateView;
    }
    
    view.tag = TAG_EVALUATE;
    return view;
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

- (UIView *)evaluateView {
    //    if (!_evaluateView) {
    _evaluateView = [UIView new];
    _evaluateView.viewWidth = self.itemsView.viewWidth - 8;
    _evaluateView.viewHeight = HEIHGT_VIEW_EVALUATE;
    _evaluateView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth;
    
    UIView *lineH = [UIView new];
    lineH.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    lineH.viewHeight = 0.5;
    lineH.viewWidth = _evaluateView.viewWidth;
    lineH.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIButton *usefulButton = [UIButton new];
    usefulButton.viewWidth = _evaluateView.viewWidth / 2 - 0.5;
    usefulButton.viewHeight = _evaluateView.viewHeight - 0.5;
    usefulButton.viewY = 0.5;
    [usefulButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_EVALUATE_BUTTON]];
    usefulButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    [usefulButton setTitle:@"已解决" forState:(UIControlStateNormal)];
    [usefulButton setTitleColor:[MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor forState:(UIControlStateNormal)];
    [usefulButton addTarget:self action:@selector(didTapPositive) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIView *lineV = [UIView new];
    lineV.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    lineV.viewHeight = HEIHGT_VIEW_EVALUATE;
    lineV.viewWidth = 0.5;
    [lineV align:(ViewAlignmentTopLeft) relativeToPoint:usefulButton.rightTopCorner];
    lineV.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    UIButton *uselessButton = [UIButton new];
    [uselessButton setTitleColor:[MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor forState:(UIControlStateNormal)];
    [uselessButton setTitle:@"未解决" forState:(UIControlStateNormal)];
    [uselessButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_EVALUATE_BUTTON]];
    [uselessButton addTarget:self action:@selector(didTapNegative) forControlEvents:(UIControlEventTouchUpInside)];
    uselessButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    uselessButton.viewWidth = _evaluateView.viewWidth / 2;
    uselessButton.viewHeight = _evaluateView.viewHeight - 0.5;
    uselessButton.viewY = 0.5;
    [uselessButton align:(ViewAlignmentTopLeft) relativeToPoint:CGPointMake(usefulButton.viewRightEdge + 0.5, usefulButton.viewY)];
    
    [_evaluateView addSubview:lineH];
    [_evaluateView addSubview:lineV];
    [_evaluateView addSubview:usefulButton];
    [_evaluateView addSubview:uselessButton];
    //    }
    return _evaluateView;
}

- (UIView *)evaluatedView {
    //    if (!_evaluatedView) {
    _evaluatedView = [UIView new];
    _evaluatedView.viewWidth = self.itemsView.viewWidth - 8;
    _evaluatedView.viewHeight = HEIHGT_VIEW_EVALUATE;
    _evaluatedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIView *lineH = [UIView new];
    lineH.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    lineH.viewHeight = 0.5;
    lineH.viewWidth = _evaluatedView.viewWidth;
    lineH.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_evaluatedView addSubview:lineH];
    
    UIButton *button = [UIButton new];
    button.viewWidth = _evaluatedView.viewWidth;
    button.viewHeight = _evaluatedView.viewHeight - 0.5;
    button.viewY = 0.5;
    [button setTitleColor:[UIColor lightGrayColor] forState:(UIControlStateNormal)];
    [button.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_EVALUATE_BUTTON]];
    [button setTitle:@"已提交" forState:(UIControlStateNormal)];
    [button setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
    [_evaluatedView addSubview:button];
    //    }
    return _evaluatedView;
}
@end
