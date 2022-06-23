//
//  MQNotificationView.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/6/15.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import "MQNotificationView.h"
#import "MQAssetUtil.h"
#import "MQServiceToViewInterface.h"
#ifndef INCLUDE_MEIQIA_SDK
#import "UIImageView+WebCache.h"
#endif

static CGFloat const kMQNotificationViewContentPadding = 10.0;
static CGFloat const kMQNotificationViewContentSpace = 5.0;
static CGFloat const kMQNotificationViewAvatarH = 20.0;
static CGFloat const kMQNotificationViewNameW = 200.0;

@interface MQNotificationView()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation MQNotificationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 5.0;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
        self.layer.shadowPath = path.CGPath;
        self.layer.shadowOpacity = 1.0;
        [self configSubview];
    }
    return self;
}


- (void)configSubview {
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.contentLabel];
}

-(void)configViewWithSenderName:(NSString *)name senderAvatarUrl:(NSString *)avatar sendContent:(NSString *)content {
    self.nameLabel.text = name;
    self.contentLabel.text = content;
    self.avatarImageView.image = [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage;
    
    //这里使用美洽接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_MEIQIA_SDK
    __weak typeof(self) weakSelf = self;
    [MQServiceToViewInterface downloadMediaWithUrlString:avatar progress:^(float progress) {
    } completion:^(NSData *mediaData, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (mediaData && !error) {
            UIImage *image = [UIImage imageWithData:mediaData];
            strongSelf.avatarImageView.image = image;
        }
    }];
#else
    //非美洽SDK用户，使用了SDWebImage来做图片缓存
    __weak typeof(self) weakSelf = self;
    [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.imagePath] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (image) {
            strongSelf.avatarImageView.image = image;
        }
    }];
#endif
}


- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kMQNotificationViewContentPadding, kMQNotificationViewContentPadding, kMQNotificationViewAvatarH, kMQNotificationViewAvatarH)];
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.cornerRadius = kMQNotificationViewAvatarH/2;
        _avatarImageView.image = [MQAssetUtil imageFromBundleWithName:@"MQIcon"];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + kMQNotificationViewContentSpace, CGRectGetMinY(self.avatarImageView.frame), kMQNotificationViewNameW, CGRectGetHeight(self.avatarImageView.frame))];
        _nameLabel.textColor = [UIColor colorWithRed:111/255.0 green:117/255.0 blue:146/255.0 alpha:1.0];
        _nameLabel.font = [UIFont systemFontOfSize:12.0];
        _nameLabel.text = @"客服名称";
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMQNotificationViewContentPadding, CGRectGetMaxY(self.nameLabel.frame) + kMQNotificationViewContentSpace, CGRectGetWidth(self.frame) - 2 * kMQNotificationViewContentPadding, kMQNotificationViewHeight - CGRectGetMaxY(self.nameLabel.frame) - kMQNotificationViewContentSpace - kMQNotificationViewContentPadding)];
        _contentLabel.font = [UIFont systemFontOfSize:14.0];
        _contentLabel.numberOfLines = 2;
        _contentLabel.text = @"发送内容";
    }
    return _contentLabel;
}

@end
