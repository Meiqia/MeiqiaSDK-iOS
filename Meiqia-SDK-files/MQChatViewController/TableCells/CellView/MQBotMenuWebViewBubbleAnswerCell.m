//
//  MQBotMenuWebViewBubbleAnswerCell.m
//  Meiqia-SDK-Demo
//
//  Created by xulianpeng on 2017/9/26.
//  Copyright © 2017年 Meiqia. All rights reserved.
//

#import "MQBotMenuWebViewBubbleAnswerCell.h"
#import "MQBotMenuWebViewBubbleAnswerCellModel.h"
#import "UIView+MQLayout.h"
#import "MQChatViewConfig.h"
#import "MQImageUtil.h"
#import "MQEmbededWebView.h"
#import "MQStringSizeUtil.h"
#import "MQToolUtil.h"
#import "MQBundleUtil.h"
#import "MQAssetUtil.h"


#define FONT_SIZE_MENU_TITLE 16
#define FONT_SIZE_MENU 14


#define FONT_SIZE_EVALUATE_BUTTON 16
#define SPACE_INTERNAL_VERTICAL 10

#define BUTTON_HEIGHT 32
#define BUTTON_WIDTH 76

static CGFloat const kMQButtonToBubbleVerticalEdgeSpacing = 5.0;
static CGFloat const kMQMenuItemYMargin = 12.0;
static CGFloat const kMQMenuItemContentHeight = 15.0;

@interface MQBotMenuWebViewBubbleAnswerCell()

@property (nonatomic, strong) MQBotMenuWebViewBubbleAnswerCellModel *viewModel;
@property (nonatomic, strong) UIImageView *itemsView;
@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) MQEmbededWebView *contentWebView;

//xlp 新添加的
@property (nonatomic, strong) UILabel *menuTitleLabel; //相关问题

@property (nonatomic, strong) UIButton *solvedButton;
@property (nonatomic, strong) UIButton *unsolvedButton;

@property (nonatomic, strong) UIView *menuView;

@property (nonatomic, assign) BOOL manuallySetToEvaluated;

@end

@implementation MQBotMenuWebViewBubbleAnswerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.itemsView];
        
        [self.itemsView addSubview:self.contentWebView];
        [self.menuView addSubview:self.menuTitleLabel];
        [self.contentView addSubview:self.menuView];
        
        [self layoutUI];
        [self updateUI:0];
    }
    return self;
}

- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if ([model isKindOfClass:[MQBotMenuWebViewBubbleAnswerCellModel class]]) {
        self.viewModel = model;
        MQBotMenuWebViewBubbleAnswerCellModel * tempModel = model;

        __weak typeof(self) wself = self;
    
        [tempModel setCellHeight:^CGFloat{
            __strong typeof (wself) sself = wself;
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
    
    //布局关联视图
    [self layoutMenuView];
    self.contentView.viewHeight = self.menuView.viewBottomEdge + kMQCellAvatarToVerticalEdgeSpacing;
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

- (void)layoutMenuView{
    
    self.menuTitleLabel.text = self.viewModel.menuTitle;
    self.menuTitleLabel.viewWidth = self.contentView.viewWidth - 2 * kMQCellBubbleToTextHorizontalSmallerSpacing - 2 * kMQCellAvatarToHorizontalEdgeSpacing;
    [self.menuTitleLabel sizeToFit];
    [self.menuTitleLabel align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kMQCellBubbleToTextHorizontalSmallerSpacing, kMQCellBubbleToTextVerticalSpacing)];
    CGFloat menuViewHeight = self.viewModel.menus.count * (kMQMenuItemYMargin + kMQMenuItemContentHeight) + self.menuTitleLabel.viewBottomEdge + kMQCellBubbleToTextVerticalSpacing;
    CGFloat menuViewWidth = self.contentView.viewWidth - 2 * kMQCellAvatarToHorizontalEdgeSpacing;
    CGFloat menuViewOriginY = (!self.viewModel.needShowFeedback ? self.itemsView.viewBottomEdge : self.solvedButton.viewBottomEdge) + SPACE_INTERNAL_VERTICAL;
    self.menuView.frame = CGRectMake(kMQCellAvatarToHorizontalEdgeSpacing, menuViewOriginY, menuViewWidth, menuViewHeight);
    [self configMenusView:self.viewModel.menus];
}

- (void)configMenusView:(NSArray *)menus {
    NSInteger index = 0;
    for (UIView *tempView in self.menuView.subviews) {
        if (tempView == self.menuTitleLabel) {
            continue;
        }
        if (index >= menus.count) {
            tempView.hidden = YES;
        } else {
            UIButton *btn = (UIButton * )tempView;
            btn.hidden = NO;
            [btn setTitle:menus[index] forState:UIControlStateNormal];
        }
        index += 1;
    }
    
    if (index < menus.count) {
        
        for (int i = (int)index; i < menus.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat btnOriginY = self.menuTitleLabel.viewBottomEdge + (i + 1) * kMQMenuItemYMargin + i * kMQMenuItemContentHeight;
            btn.frame = CGRectMake(kMQCellBubbleToTextHorizontalSmallerSpacing, btnOriginY, self.menuView.viewWidth - 2 * kMQCellBubbleToTextHorizontalSmallerSpacing, kMQMenuItemContentHeight);
            btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [btn setTitle:menus[i] forState:UIControlStateNormal];
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MENU]];
            [btn addTarget:self action:@selector(menuTapped:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:[UIColor colorWithRed:24.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:24.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:0.5] forState:UIControlStateHighlighted];
            [self.menuView addSubview:btn];
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

- (void)menuTapped:(UIButton *)menu {
    NSString *didTapMenuText = menu.titleLabel.text;
    
    if ([self.chatCellDelegate respondsToSelector:@selector(didTapMenuWithText:)]) {
        [self.chatCellDelegate didTapMenuWithText:didTapMenuText];
    }
}

#pragma - lazy

- (MQEmbededWebView *)contentWebView {
    if (!_contentWebView) {
        _contentWebView = [MQEmbededWebView new];
        _contentWebView.frame = CGRectMake(8, 0, self.itemsView.frame.size.width-8, self.itemsView.frame.size.height/2);
    }
    return _contentWebView;
}

- (UIImageView *)itemsView {
    if (!_itemsView) {
        _itemsView = [UIImageView new];
        NSInteger itemsViewX = kMQCellAvatarToVerticalEdgeSpacing+kMQCellAvatarDiameter+kMQCellAvatarToBubbleSpacing;
        _itemsView.frame = CGRectMake(itemsViewX,kMQCellAvatarToHorizontalEdgeSpacing,MQToolUtil.kMQScreenWidth - itemsViewX - kMQCellBubbleMaxWidthToEdgeSpacing , 200);
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
        _avatarImageView.frame = CGRectMake(kMQCellAvatarToVerticalEdgeSpacing, kMQCellAvatarToHorizontalEdgeSpacing, kMQCellAvatarDiameter, kMQCellAvatarDiameter);
        _avatarImageView.image = [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage;
        if ([MQChatViewConfig sharedConfig].enableRoundAvatar) {
            _avatarImageView.layer.masksToBounds = YES;
            _avatarImageView.layer.cornerRadius = _avatarImageView.viewSize.width/2;
        }
    }
    return _avatarImageView;
}

- (UILabel *)menuTitleLabel {
    if (!_menuTitleLabel) {
        _menuTitleLabel = [UILabel new];
        _menuTitleLabel.numberOfLines = 0;
        _menuTitleLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE_MENU_TITLE];
        _menuTitleLabel.textColor = [UIColor colorWithRed:29/255 green:39/255 blue:84/255 alpha:1.0];
    }
    return _menuTitleLabel;
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

-(UIView *)menuView {
    if (!_menuView) {
        _menuView = [[UIView alloc] init];
        _menuView = [[UIView alloc] init];
        _menuView.backgroundColor = [UIColor whiteColor];
        _menuView.clipsToBounds = YES;
        _menuView.layer.cornerRadius = 8.0;
        _menuView.layer.borderWidth = 1.0;
        _menuView.layer.borderColor = [UIColor colorWithRed:244/255 green:242/255 blue:241/255 alpha:0.2].CGColor;
    }
    return _menuView;
}


@end
