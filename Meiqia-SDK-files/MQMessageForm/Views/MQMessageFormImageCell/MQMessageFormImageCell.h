//
//  MQMessageFormImageCell.h
//  Meiqia-SDK-Demo
//
//  Created by bingoogol on 16/5/24.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MQMessageFormImageCellDelegate <NSObject>

- (void)tapDeleteIv:(NSUInteger)index;

- (void)tapPictureIv:(NSUInteger)index;

@end

@interface MQMessageFormImageCell : UICollectionViewCell

@property(nonatomic, weak) id<MQMessageFormImageCellDelegate> delegate;
@property(nonatomic, weak) NSIndexPath *indexPath;

@property (strong, nonatomic) UIImageView *pictureIv;
@property (strong, nonatomic) UIImageView *deleteIv;

@end
