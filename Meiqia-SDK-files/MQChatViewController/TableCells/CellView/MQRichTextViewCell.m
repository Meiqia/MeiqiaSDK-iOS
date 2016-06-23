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
CGFloat internalImageWidth = 80;

@interface MQRichTextViewCell()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *itemsView;

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
    
    [self.viewModel setCellHeight:^CGFloat{
        if ([UIDevice currentDevice].systemVersion.intValue >= 7) {
            return UITableViewAutomaticDimension;
        } else {
            return internalImageWidth + kMQCellAvatarToVerticalEdgeSpacing * 2;
        }
    }];
    
    [self.viewModel load];
}

- (void)setupUI {
    [self.contentView addSubview:self.itemsView];
    self.iconImageView = [[UIImageView alloc] initWithImage:[MQChatViewConfig sharedConfig].incomingDefaultAvatarImage];
    [self.itemsView addSubview:self.iconImageView];
    [self.itemsView addSubview:self.contentLabel];
}

- (void)prepareForReuse {
    self.iconImageView.image = [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage;
}

- (void)makeConstraints {
    
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.itemsView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *d = @{@"icon":self.iconImageView, @"label":self.contentLabel};
    NSDictionary *m = @{@"av":@(kMQCellAvatarToVerticalEdgeSpacing), @"bv":@(kMQCellBubbleToTextVerticalSpacing), @"al":@(kMQCellAvatarToBubbleSpacing), @"br":@(kMQCellBubbleMaxWidthToEdgeSpacing), @"ad":@(kMQCellAvatarDiameter), @"id":@(internalImageWidth), @"is":@(internalSpace), @"iis":@(internalImageToTextSpace), @"bts":@(kMQCellBubbleToTextHorizontalLargerSpacing), @"btvs":@(kMQCellBubbleToTextVerticalSpacing)};
    
    [self.itemsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[icon(id)]-is-[label]-bts-|" options:0 metrics:m views:d]];
    [self.itemsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[icon(id)]-0-|" options:0 metrics:m views:d]];
    [self.itemsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[label]-|" options:0 metrics:m views:d]];
    
    d = @{@"items":self.itemsView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-av-[items]-br-|" options:0 metrics:m views:d]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-av-[items]-av-|" options:0 metrics:m views:d]];
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
        _contentLabel.textColor = [MQChatViewConfig sharedConfig].incomingMsgTextColor;
        _contentLabel.font = [UIFont systemFontOfSize:15];

    }
    return _contentLabel;
}

- (UIView *)itemsView {
    if (!_itemsView) {
        _itemsView = [UIView new];
        _itemsView.backgroundColor = [MQChatViewConfig sharedConfig].incomingBubbleColor;
        _itemsView.layer.cornerRadius = 4;
        _itemsView.layer.masksToBounds = YES;
    }
    return _itemsView;
}

@end
