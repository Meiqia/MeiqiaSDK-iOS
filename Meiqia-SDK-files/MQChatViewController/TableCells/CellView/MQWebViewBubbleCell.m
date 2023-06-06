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
#import "MQTextMessage.h"

@interface MQWebViewBubbleCell()

@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@end

@implementation MQWebViewBubbleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化头像
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.avatarImageView];
        //初始化气泡
        self.bubbleImageView = [[UIImageView alloc] init];
        self.bubbleImageView.userInteractionEnabled = true;
        [self.contentView addSubview:self.bubbleImageView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    for (UIView *tempView in self.contentView.subviews) {
        if ([tempView isKindOfClass:[MQTagListView class]]) {
            [tempView removeFromSuperview];
        }
    }
    [self.bubbleImageView.subviews.firstObject removeFromSuperview];
}

- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    if (![model isKindOfClass:[MQWebViewBubbleCellModel class]]) {
        NSAssert(NO, @"传给MQWebViewBubbleCell的Model类型不正确");
        return ;
    }
    MQWebViewBubbleCellModel * cellModel = model;
    
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
    self.bubbleImageView.frame = cellModel.bubbleFrame;
    
    CGFloat tagViewHeight = 0;
    
    [self.bubbleImageView addSubview:cellModel.contentWebView];
    cellModel.contentWebView.scrollView.zoomScale = 1.0;
    cellModel.contentWebView.scrollView.contentSize = CGSizeMake(0, 0);
    
    [cellModel.contentWebView setTappedLink:^(NSURL *url) {
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
    
    if (cellModel.cacheTagListView) {
        tagViewHeight = cellModel.cacheTagListView.viewHeight + kMQCellBubbleToIndicatorSpacing;
        cellModel.cacheTagListView.frame = CGRectMake(CGRectGetMinX(self.bubbleImageView.frame), CGRectGetMaxY(self.bubbleImageView.frame) + kMQCellBubbleToIndicatorSpacing, cellModel.cacheTagListView.bounds.size.width, cellModel.cacheTagListView.bounds.size.height);
        [self.contentView addSubview:cellModel.cacheTagListView];
        
        NSArray *cacheTags = [[NSArray alloc] initWithArray:cellModel.cacheTags];
        __weak typeof(self) weakSelf = self;
        __weak typeof(cellModel) weakTempModel = cellModel;

        cellModel.cacheTagListView.mqTagListSelectedIndex = ^(NSInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
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
            
            if ([strongSelf.chatCellDelegate respondsToSelector:@selector(collectionOperationIndex:messageId:)]) {
                [strongSelf.chatCellDelegate collectionOperationIndex:(int)index messageId:[weakTempModel getCellMessageId]];
            }
            
        };
    }
    
}

@end
