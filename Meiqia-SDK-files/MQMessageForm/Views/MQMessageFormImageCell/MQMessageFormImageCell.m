//
//  MQMessageFormImageCell.m
//  Meiqia-SDK-Demo
//
//  Created by bingoogol on 16/5/24.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQMessageFormImageCell.h"
#import "MQMessageFormConfig.h"

static CGFloat const kMQMessageFormImageCellDeleteIvLength = 32;

@implementation MQMessageFormImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _pictureIv = [[UIImageView alloc] init];
        _pictureIv.contentMode = UIViewContentModeScaleAspectFill;
        _pictureIv.clipsToBounds = YES;
        _pictureIv.userInteractionEnabled = YES;
        [_pictureIv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPictureIv)]];
        _deleteIv = [[UIImageView alloc] init];
        _deleteIv.contentMode = UIViewContentModeScaleAspectFill;
        _deleteIv.clipsToBounds = YES;
        _deleteIv.userInteractionEnabled = YES;
        _deleteIv.image = [MQMessageFormConfig sharedConfig].messageFormViewStyle.deleteImage;
        [_deleteIv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDeleteIv)]];
        
        [self refreshFrame];
        [self.contentView addSubview:_pictureIv];
        [self.contentView addSubview:_deleteIv];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self refreshFrame];
}

- (void)refreshFrame {
    _deleteIv.frame = CGRectMake(self.frame.size.width - kMQMessageFormImageCellDeleteIvLength, 0, kMQMessageFormImageCellDeleteIvLength, kMQMessageFormImageCellDeleteIvLength);
    CGFloat pictureIvLength = self.frame.size.width - kMQMessageFormImageCellDeleteIvLength / 2;
    _pictureIv.frame = CGRectMake(0, kMQMessageFormImageCellDeleteIvLength / 2, pictureIvLength, pictureIvLength);
}

- (void)tapPictureIv {
    [self.delegate tapPictureIv:self.indexPath.row];
}

- (void)tapDeleteIv {
    [self.delegate tapDeleteIv:self.indexPath.row];
}

@end
