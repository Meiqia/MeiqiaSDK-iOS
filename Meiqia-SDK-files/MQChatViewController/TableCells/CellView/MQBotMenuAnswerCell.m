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
#import "MQBotMenuAnswerCellModel.h"

#define TAG_MENUS 10
#define TAG_EVALUATE 11

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
@property (nonatomic, assign) CGFloat currentBubbleWidth;

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

    self.cellModel = model;
    
    [self updateUI];
    
    __weak typeof(self) wself = self;
    self.cellModel.provoideCellHeight = ^{
        __strong typeof (wself) sself = wself;
        return sself.contentView.viewHeight;
    };
}

- (void)updateUI {
    //layout fix components
    [self.avatarImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarToHorizontalEdgeSpacing)];
    [self.itemsView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.avatarImageView.viewRightEdge + kMQCellAvatarToBubbleSpacing, self.avatarImageView.viewY)];
    
    self.itemsView.viewWidth = self.contentView.viewWidth - kMQCellBubbleMaxWidthToEdgeSpacing - self.avatarImageView.viewRightEdge;
    
    self.contentLabel.text = self.cellModel.content;
    self.contentLabel.viewWidth = self.itemsView.viewWidth;
    [self.contentLabel sizeToFit];
    [self.contentLabel align:(ViewAlignmentTopLeft) relativeToPoint:CGPointZero];
    
    self.menuTitleLabel.text = self.cellModel.menuTitle;
    self.menuTitleLabel.viewWidth = self.itemsView.viewWidth;
    [self.menuTitleLabel sizeToFit];
    [self.menuTitleLabel align:(ViewAlignmentTopLeft) relativeToPoint:self.contentLabel.leftBottomCorner];
    
    //recreate menus view
    UIView *menusView = [self menusView:self.cellModel.menus];
    [[self.itemsView viewWithTag:menusView.tag] removeFromSuperview];
    [self.itemsView addSubview:menusView];
    [menusView align:(ViewAlignmentTopLeft) relativeToPoint:self.menuTitleLabel.leftBottomCorner];
    
    self.menuFootnoteLabel.text = self.cellModel.menuFootnote;
    self.menuFootnoteLabel.viewWidth = self.itemsView.viewWidth;
    [self.menuFootnoteLabel sizeToFit];
    [self.menuFootnoteLabel align:(ViewAlignmentTopLeft) relativeToPoint:menusView.leftBottomCorner];
    
    //recreate evaluate view
    UIView *evaluateView = [self evaluateRelatedView];
    [[self.itemsView viewWithTag:evaluateView.tag] removeFromSuperview];
    [evaluateView align:(ViewAlignmentTopLeft) relativeToPoint:self.menuFootnoteLabel.leftBottomCorner];
    
    self.itemsView.viewHeight = evaluateView.viewBottomEdge;
    self.contentView.viewHeight = self.itemsView.viewBottomEdge;
}

- (UIView *)menusView:(NSArray *)menus {
    UIView *container = [UIView new];
    container.tag = TAG_MENUS;
    container.viewWidth = self.currentBubbleWidth;
    
    CGFloat topOffset = 0;
    for (NSString *menuTitle in menus) {
        UIButton *menu = [UIButton new];
        menu.viewWidth = container.viewWidth;
        [menu setTitle:menuTitle forState:(UIControlStateNormal)];
        [menu sizeToFit];
        [menu addTarget:self action:@selector(menuTapped:) forControlEvents:(UIControlEventTouchUpInside)];
        [container addSubview:menu];
        [menu align:(ViewAlignmentTopLeft) relativeToPoint:CGPointMake(0, topOffset)];
        
        topOffset += menu.viewHeight;
    }
    
    container.viewHeight = topOffset;
    return container;
}

- (UIView *)evaluateRelatedView {
    if (self.cellModel.isEvaluated) {
        if (self.evaluatedView.superview) {
            [self.evaluateView removeFromSuperview];
        }
        return self.evaluatedView;
    } else {
        if (self.evaluatedView.superview) {
            [self.evaluatedView removeFromSuperview];
        }
        return self.evaluateView;
    }
}

#pragma mark - actions

- (void)menuTapped:(UIButton *)menu {
    NSString *didTapMenuText = menu.titleLabel.text;
    if ([self.chatCellDelegate respondsToSelector:@selector(didTapMenuWithText:)]) {
        [self.chatCellDelegate didTapMenuWithText:didTapMenuText];
    }
}

- (void)didTapPositive {
    if ([self.chatCellDelegate respondsToSelector:@selector(evaluateBotAnswer:messageId:)]) {
        [self.chatCellDelegate evaluateBotAnswer:true messageId:self.cellModel.messageId];
    }
}

- (void)didTapNegative {
    if ([self.chatCellDelegate respondsToSelector:@selector(evaluateBotAnswer:messageId:)]) {
        [self.chatCellDelegate evaluateBotAnswer:false messageId:self.cellModel.messageId];
    }
}

#pragma mark - lazy load

- (UIView *)evaluateView {
    if (!_evaluateView) {
        _evaluateView = [UIView new];
        _evaluatedView.tag = TAG_EVALUATE;
    }
    return _evaluateView;
}

- (UIView *)evaluatedView {
    if (!_evaluatedView) {
        _evaluatedView = [UIView new];
        _evaluatedView.tag = TAG_EVALUATE;
    }
    return _evaluatedView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = [UIColor darkGrayColor];
    }
    return _contentLabel;
}

- (UILabel *)menuTitleLabel {
    if (!_menuTitleLabel) {
        _menuTitleLabel = [UILabel new];
        _menuTitleLabel.numberOfLines = 0;
        _menuTitleLabel.font = [UIFont systemFontOfSize:14];
        _menuTitleLabel.textColor = [UIColor grayColor];
    }
    return _menuTitleLabel;
}

- (UILabel *)menuFootnoteLabel {
    if (!_menuFootnoteLabel) {
        _menuFootnoteLabel = [UILabel new];
        _menuFootnoteLabel.numberOfLines = 0;
        _menuFootnoteLabel.font = [UIFont systemFontOfSize:14];
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
