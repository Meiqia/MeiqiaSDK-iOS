//
//  MQBotMenuAnswerCell.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/24.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQBotMenuAnswerCell.h"
#import "MQChatViewConfig.h"
#import "MQImageUtil.h"
#import "UIView+MQLayout.h"
#import "UIImage+MQGenerate.h"
#import "MQStringSizeUtil.h"
#import "MQBotMenuAnswerCellModel.h"

#define TAG_MENUS 10
#define TAG_EVALUATE 11
#define HEIHGT_VIEW_EVALUATE 40
#define FONT_SIZE_CONTENT 16
#define FONT_SIZE_MENU_TITLE 13
#define FONT_SIZE_MENU 15
#define FONT_SIZE_MENU_FOOTNOTE 12
#define FONT_SIZE_EVALUATE_BUTTON 14
#define SPACE_INTERNAL_VERTICAL 15

@interface MQBotMenuAnswerCell()

@property (nonatomic, strong) MQBotMenuAnswerCellModel *cellModel;
@property (nonatomic, strong) UIImageView *itemsView;
@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *menuTitleLabel;
@property (nonatomic, strong) UILabel *menuFootnoteLabel;

@property (nonatomic, strong) UIView *evaluateView;
@property (nonatomic, strong) UIView *evaluatedView;

@property (nonatomic, assign) CGFloat currentCellWidth;
@property (nonatomic, assign) CGFloat currentContentWidth;


@property (nonatomic, assign) BOOL manuallySetToEvaluated;

@end

@implementation MQBotMenuAnswerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.itemsView];
        
        [self.itemsView addSubview:self.contentLabel];
        [self.itemsView addSubview:self.menuTitleLabel];
        [self.itemsView addSubview:self.menuFootnoteLabel];
    }
    return self;
}

- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    self.manuallySetToEvaluated = NO;
    self.cellModel = model;
    
    [self updateUI];
    
    __weak typeof(self) wself = self;
    self.cellModel.provoideCellHeight = ^{
        __strong typeof (wself) sself = wself;
        return sself.contentView.viewHeight;
    };
    
    if (self.cellModel.avatarImage) {
        self.avatarImageView.image = self.cellModel.avatarImage;
    } else {
        [self.cellModel setAvatarLoaded:^(UIImage *avatar) {
            __strong typeof (wself) sself = wself;
            if (avatar) {
                sself.avatarImageView.image = avatar;
            }
        }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateUI];
}

- (void)updateUI {
    //layout fix components
    [self.avatarImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarToHorizontalEdgeSpacing)];
    [self.itemsView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.avatarImageView.viewRightEdge + kMQCellAvatarToBubbleSpacing, self.avatarImageView.viewY)];
    
    self.itemsView.viewWidth = self.contentView.viewWidth - kMQCellBubbleMaxWidthToEdgeSpacing - self.avatarImageView.viewRightEdge;
    self.currentCellWidth = self.contentView.viewWidth;
    self.currentContentWidth = self.itemsView.viewWidth - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarToHorizontalEdgeSpacing;
    
    self.contentLabel.text = self.cellModel.content;
    self.contentLabel.viewWidth = self.currentContentWidth;
    [self.contentLabel sizeToFit];
    [self.contentLabel align:(ViewAlignmentTopLeft) relativeToPoint:CGPointMake(kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarToHorizontalEdgeSpacing)];
    
    self.menuTitleLabel.text = self.cellModel.menuTitle;
    self.menuTitleLabel.viewWidth = self.currentContentWidth;
    [self.menuTitleLabel sizeToFit];
    [self.menuTitleLabel align:(ViewAlignmentTopLeft) relativeToPoint:CGPointMake(self.contentLabel.leftBottomCorner.x, self.contentLabel.leftBottomCorner.y + SPACE_INTERNAL_VERTICAL)];
    
    //recreate menus view
    UIView *menusView = [self menusView:self.cellModel.menus];
    [[self.itemsView viewWithTag:menusView.tag] removeFromSuperview];
    [self.itemsView addSubview:menusView];
    [menusView align:(ViewAlignmentTopLeft) relativeToPoint:CGPointMake(self.menuTitleLabel.leftBottomCorner.x, self.menuTitleLabel.leftBottomCorner.y + SPACE_INTERNAL_VERTICAL)];
    
    self.menuFootnoteLabel.text = self.cellModel.menuFootnote;
    self.menuFootnoteLabel.viewWidth = self.currentContentWidth;
    [self.menuFootnoteLabel sizeToFit];
    [self.menuFootnoteLabel align:(ViewAlignmentTopLeft) relativeToPoint:menusView.leftBottomCorner];
    
    //recreate evaluate view
    UIView *evaluateView = [self evaluateRelatedView];
    [[self.itemsView viewWithTag:evaluateView.tag] removeFromSuperview];
    [self.itemsView addSubview:evaluateView];
    [evaluateView align:(ViewAlignmentTopLeft) relativeToPoint:CGPointMake(8, self.menuFootnoteLabel.leftBottomCorner.y + SPACE_INTERNAL_VERTICAL)];
    
    self.itemsView.viewHeight = evaluateView.viewBottomEdge;
    self.contentView.viewHeight = self.itemsView.viewBottomEdge;
    self.viewHeight = self.contentView.viewHeight;
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

#pragma mark - dynamic views

- (UIView *)menusView:(NSArray *)menus {
    UIView *container = [UIView new];
    container.tag = TAG_MENUS;
    container.viewWidth = self.currentContentWidth;
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    CGFloat topOffset = 0;
    for (NSString *menuTitle in menus) {
        UIButton *menu = [UIButton buttonWithType:(UIButtonTypeCustom)];
        menu.viewWidth = container.viewWidth;
        menu.titleLabel.numberOfLines = 0;
        menu.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        menu.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [menu setTitle:menuTitle forState:(UIControlStateNormal)];
        [menu setContentHorizontalAlignment:(UIControlContentHorizontalAlignmentLeft)];
        [menu.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MENU]];
        [menu addTarget:self action:@selector(menuTapped:) forControlEvents:(UIControlEventTouchUpInside)];
        [menu setTitleColor:[MQChatViewConfig sharedConfig].chatViewStyle.btnTextColor forState:(UIControlStateNormal)];
        [menu align:(ViewAlignmentTopLeft) relativeToPoint:CGPointMake(0, topOffset)];
        [container addSubview:menu];
        menu.viewHeight = [MQStringSizeUtil getHeightForText:menuTitle withFont:[UIFont systemFontOfSize:FONT_SIZE_MENU] andWidth:container.viewWidth];
        
        topOffset += menu.viewHeight + SPACE_INTERNAL_VERTICAL;
        
    }
    
    container.viewHeight = topOffset;
    return container;
}

- (UIView *)evaluateRelatedView {
    UIView *view;
    if (self.cellModel.isEvaluated || self.manuallySetToEvaluated) {
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

#pragma mark - actions

- (void)menuTapped:(UIButton *)menu {
    NSString *didTapMenuText = menu.titleLabel.text;
    
    if ([self.chatCellDelegate respondsToSelector:@selector(didTapMenuWithText:)]) {
        [self.chatCellDelegate didTapMenuWithText:didTapMenuText];
    }
}

- (void)didTapPositive {
    
    [self updateEvaluateViewAnimatedComplete:^{
        if ([self.chatCellDelegate respondsToSelector:@selector(evaluateBotAnswer:messageId:)]) {
            [self.chatCellDelegate evaluateBotAnswer:true messageId:self.cellModel.messageId];
        }
    }];
}

- (void)didTapNegative {
    [self updateEvaluateViewAnimatedComplete:^{
        if ([self.chatCellDelegate respondsToSelector:@selector(evaluateBotAnswer:messageId:)]) {
            [self.chatCellDelegate evaluateBotAnswer:false messageId:self.cellModel.messageId];
        }
    }];
}

#pragma mark - lazy load

- (UIView *)evaluateView {
//    if (!_evaluateView) {
        _evaluateView = [UIView new];
        _evaluateView.viewWidth = self.itemsView.viewWidth - 8;
        _evaluateView.viewHeight = HEIHGT_VIEW_EVALUATE;
        _evaluateView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
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

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont systemFontOfSize:FONT_SIZE_CONTENT];
        _contentLabel.textColor = [MQChatViewConfig sharedConfig].incomingMsgTextColor;
    }
    return _contentLabel;
}

- (UILabel *)menuTitleLabel {
    if (!_menuTitleLabel) {
        _menuTitleLabel = [UILabel new];
        _menuTitleLabel.numberOfLines = 0;
        _menuTitleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_MENU_TITLE];
        _menuTitleLabel.textColor = [UIColor grayColor];
    }
    return _menuTitleLabel;
}

- (UILabel *)menuFootnoteLabel {
    if (!_menuFootnoteLabel) {
        _menuFootnoteLabel = [UILabel new];
        _menuFootnoteLabel.numberOfLines = 0;
        _menuFootnoteLabel.font = [UIFont systemFontOfSize:FONT_SIZE_MENU_FOOTNOTE];
        _menuFootnoteLabel.textColor = [UIColor grayColor];
    }
    return _menuFootnoteLabel;
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
