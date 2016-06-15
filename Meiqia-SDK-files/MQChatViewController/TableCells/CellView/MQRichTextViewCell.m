//
//  MQRichTextViewCell.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQRichTextViewCell.h"
#import "UIView+MQLayout.h"
#import "MQChatViewConfig.h"
#import "MQImageUtil.h"
#import "MQCellModelProtocol.h"
#import "MQRichTextViewModel.h"
#import "MQWindowUtil.h"


CGFloat internalSpace = 10;
CGFloat internalImageToTextSpace = kMQCellBubbleToTextHorizontalLargerSpacing;
CGFloat internalImageWidth = 50;

@interface MQRichTextViewCell()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *itemsView;

@property (nonatomic, strong) MQRichTextViewModel *viewModel;

@end


@implementation MQRichTextViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        [self makeConstraints];
        [self setupAction];
    }
    return self;
}

- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    self.viewModel = model;
    [self bind:model];
}

- (void)bind:(MQRichTextViewModel *)viewModel {
    
    __weak typeof(self) wself = self;
    [self.viewModel setModelChanges:^(NSString *url, NSString *content, NSString *iconPath) {
        __strong typeof (wself) sself = wself;
        
        sself.contentLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - kMQCellAvatarToBubbleSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing - kMQCellBubbleMaxWidthToEdgeSpacing - kMQCellAvatarDiameter - kMQCellAvatarToHorizontalEdgeSpacing - internalSpace - internalImageToTextSpace - internalImageWidth;
        sself.contentLabel.text = content;
    }];
    
    [self.viewModel setIconLoaded:^(UIImage *iconImage) {
        __strong typeof (wself) sself = wself;
        if (iconImage) {
            sself.iconImageView.image = iconImage;
        }
    }];
    
    [self.viewModel setAvatarLoaded:^(UIImage *avatarImage) {
        __strong typeof (wself) sself = wself;
        sself.avatarImageView.image = avatarImage;
    }];
    
    [self.viewModel setCellHeight:^CGFloat{
        __strong typeof (wself)sself = wself;
        if ([UIDevice currentDevice].systemVersion.intValue < 7) {
            return UITableViewAutomaticDimension;
        } else {
            sself.contentLabel.viewWidth = sself.contentLabel.preferredMaxLayoutWidth;
            [sself.contentLabel sizeToFit];
            return self.contentLabel.viewHeight + kMQCellBubbleToTextVerticalSpacing * 2 + kMQCellAvatarToVerticalEdgeSpacing;
        }
    }];
    
    [self.viewModel load];
}

- (void)setupUI {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.itemsView];
    
    self.iconImageView = [[UIImageView alloc] init];
    [self.itemsView addSubview:self.iconImageView];
    
    [self.itemsView addSubview:self.contentLabel];
}

- (void)makeConstraints {
    
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.itemsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *d = @{@"icon":self.iconImageView, @"label":self.contentLabel};
    NSDictionary *m = @{@"av":@(kMQCellAvatarToVerticalEdgeSpacing), @"bv":@(kMQCellBubbleToTextVerticalSpacing), @"al":@(kMQCellAvatarToBubbleSpacing), @"br":@(kMQCellBubbleMaxWidthToEdgeSpacing), @"ad":@(kMQCellAvatarDiameter), @"id":@(internalImageWidth), @"is":@(internalSpace), @"iis":@(internalImageToTextSpace), @"bts":@(kMQCellBubbleToTextHorizontalLargerSpacing), @"btvs":@(kMQCellBubbleToTextVerticalSpacing)};
    
    [self.itemsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-iis-[icon(id)]-is-[label]-bts-|" options:0 metrics:m views:d]];
    [self.itemsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-btvs-[icon(id)]" options:0 metrics:m views:d]];
    [self.itemsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-btvs-[label]-btvs-|" options:0 metrics:m views:d]];
    
    d = @{@"avatar":self.avatarImageView, @"items":self.itemsView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-al-[avatar(ad)]-is-[items]-br-|" options:0 metrics:m views:d]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-av-[avatar(ad)]" options:0 metrics:m views:d]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-av-[items]|" options:0 metrics:m views:d]];
}

- (void)setupAction {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openURL)];
    [self.itemsView addGestureRecognizer:tap];
}

- (void)openURL {
    [self.viewModel openFrom:[MQWindowUtil topController]];
}

#pragma mark -

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textAlignment = NSTextAlignmentNatural;

    }
    return _contentLabel;
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
