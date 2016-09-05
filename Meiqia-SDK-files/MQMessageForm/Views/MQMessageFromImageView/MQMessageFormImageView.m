//
//  MQMessageFormImageView.m
//  MeiQiaSDK
//
//  Created by bingoogolapple on 16/5/4.
//  Copyright © 2016年 MeiQia Inc. All rights reserved.
//

#import "MQMessageFormImageView.h"
#import "MQAssetUtil.h"
#import "MQBundleUtil.h"
#import "MQMessageFormConfig.h"
#import "MQImageViewerViewController.h"
#import "MQMessageFormImageCell.h"

static CGFloat const kMQMessageFormImageViewSpacing   = 16.0;
static CGFloat const kMQMessageFormImageViewMaxPictureItemLength = 116;
static CGFloat const kMQMessageFormImageViewMaxItemCount = 3;
static CGFloat const kMQMessageFormImageViewItemSpacing = 7;
static CGFloat const kMQMessageFormImageViewHeaderHeight = 20;

static NSString * const kMQMessageFormImageViewCellID = @"MQMessageFormImageCell";
static NSString * const kMQMessageFormImageViewCellHeaderID = @"MQMessageFormImageCellHeader";

@interface MQMessageFormImageView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MQMessageFormImageCellDelegate>

@end

@implementation MQMessageFormImageView {
    NSMutableArray *images;
}

- (instancetype)initWithScreenWidth:(CGFloat)screenWidth {
    CGFloat pictureItemLength = [MQMessageFormImageView calculatePictureItemLengthWithScreenWidth:screenWidth];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(pictureItemLength, pictureItemLength);
    layout.minimumLineSpacing = kMQMessageFormImageViewItemSpacing;
    layout.minimumInteritemSpacing = kMQMessageFormImageViewItemSpacing;
    
    CGFloat width = pictureItemLength * kMQMessageFormImageViewMaxItemCount + kMQMessageFormImageViewItemSpacing * (kMQMessageFormImageViewMaxItemCount - 1);
    self = [super initWithFrame:CGRectMake(kMQMessageFormImageViewSpacing, kMQMessageFormImageViewSpacing, width, pictureItemLength + kMQMessageFormImageViewHeaderHeight) collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[MQMessageFormImageCell class] forCellWithReuseIdentifier:kMQMessageFormImageViewCellID];
        [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMQMessageFormImageViewCellHeaderID];

        images = [NSMutableArray new];
        [images addObject:[MQMessageFormConfig sharedConfig].messageFormViewStyle.addImage ?: [UIImage imageNamed:[MQAssetUtil resourceWithName:@"MQMessageFormAddIcon"]]];
    }
    return self;
}

+ (CGFloat)calculatePictureItemLengthWithScreenWidth:(CGFloat)screenWidth {
    CGFloat pictureItemLength = (screenWidth - 2 * kMQMessageFormImageViewSpacing - kMQMessageFormImageViewItemSpacing * (kMQMessageFormImageViewMaxItemCount - 1)) / kMQMessageFormImageViewMaxItemCount;
    pictureItemLength = pictureItemLength > kMQMessageFormImageViewMaxPictureItemLength ? kMQMessageFormImageViewMaxPictureItemLength : pictureItemLength;
    return pictureItemLength;
}

#pragma UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MQMessageFormImageCell *cell = (MQMessageFormImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kMQMessageFormImageViewCellID forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    cell.pictureIv.image = [images objectAtIndex:indexPath.row];
    if (indexPath.row == images.count - 1 && [images lastObject] == [MQMessageFormConfig sharedConfig].messageFormViewStyle.addImage) {
        cell.deleteIv.hidden = YES;
    } else {
        cell.deleteIv.hidden = NO;
    }
    // 图片数达到上限后，隐藏「添加」图片
    if (images.count == kMQMessageFormImageViewMaxItemCount + 1 && indexPath.row == images.count - 1) {
        cell.hidden = YES;
    } else {
        cell.hidden = NO;
    }
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, kMQMessageFormImageViewHeaderHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMQMessageFormImageViewCellHeaderID forIndexPath:indexPath];
    UILabel *addPictureLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    addPictureLabel.text = [MQBundleUtil localizedStringForKey:@"add_picture"];
    addPictureLabel.textColor = [MQMessageFormConfig sharedConfig].messageFormViewStyle.addPictureTextColor;
    addPictureLabel.font = [UIFont systemFontOfSize:14.0];
    [headerView addSubview:addPictureLabel];
    return headerView;
}

#pragma MQMessageFormImageCellDelegate
- (void)tapDeleteIv:(NSUInteger)index {
    // 若少于上限，则显示「添加」图片
    if ([images lastObject] != [MQMessageFormConfig sharedConfig].messageFormViewStyle.addImage) {
        [images removeObjectAtIndex:index];
        [images addObject:[MQMessageFormConfig sharedConfig].messageFormViewStyle.addImage];
        [self reloadData];
    } else {
        [images removeObjectAtIndex:index];
        [self performBatchUpdates:^{
            [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        } completion:^(BOOL finished) {
            [self reloadData];
        }];
    }
}

- (void)tapPictureIv:(NSUInteger)index {
    if (index == images.count - 1) {
        [self showChoosePictureActionSheet];
    } else {
        [self showImageViewerWithIndex:index];
    }
}

- (void)showImageViewerWithIndex:(NSUInteger)index {
    MQImageViewerViewController *viewerVC = [MQImageViewerViewController new];
    viewerVC.images = [images subarrayWithRange:NSMakeRange(0, images.count - 1)];
    viewerVC.currentIndex = index;
    viewerVC.shouldHideSaveBtn = YES;
    
    __weak MQImageViewerViewController *wViewerVC = viewerVC;
    [viewerVC setSelection:^(NSUInteger index) {
        __strong MQImageViewerViewController *sViewerVC = wViewerVC;
        [sViewerVC dismiss];
    }];
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [viewerVC showOn:[UIApplication sharedApplication].keyWindow.rootViewController fromRectArray:[self getFromRectArray]];
}

- (NSArray *)getFromRectArray {
    NSMutableArray *fromRectArray = [NSMutableArray new];
    for (int i = 0; i < images.count - 1; i++) {
        MQMessageFormImageCell *cell = (MQMessageFormImageCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [fromRectArray addObject:[NSValue valueWithCGRect:[cell.pictureIv.superview convertRect:cell.pictureIv.frame toView:[UIApplication sharedApplication].keyWindow]]];
    }
    return fromRectArray;
}


- (void)refreshFrameWithScreenWidth:(CGFloat)screenWidth andY:(CGFloat)y {
    CGFloat pictureItemLength = [MQMessageFormImageView calculatePictureItemLengthWithScreenWidth:screenWidth];
    CGFloat width = pictureItemLength * kMQMessageFormImageViewMaxItemCount + kMQMessageFormImageViewItemSpacing * (kMQMessageFormImageViewMaxItemCount - 1);
    self.frame = CGRectMake(kMQMessageFormImageViewSpacing, y + kMQMessageFormImageViewSpacing, width, pictureItemLength + kMQMessageFormImageViewHeaderHeight);
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.itemSize = CGSizeMake(pictureItemLength, pictureItemLength);
}

- (void)addImage:(UIImage *)image {
    // 达到上限时，清楚「添加」图片
    if (images.count == kMQMessageFormImageViewMaxItemCount) {
        [images replaceObjectAtIndex:kMQMessageFormImageViewMaxItemCount - 1 withObject:image];
    } else {
        [images insertObject:image atIndex:images.count - 1];
    }
    [self reloadData];
}

- (NSArray *)getImages {
    // 如果最后一张图片是「加号图片」，则返回「加号图片」以外的图片数组
    if ([images lastObject] == [MQMessageFormConfig sharedConfig].messageFormViewStyle.addImage) {
        return [images subarrayWithRange:NSMakeRange(0, images.count - 1)];
    } else {
        return images;
    }
}

- (void)showChoosePictureActionSheet {
    // 先关闭键盘，否则会被键盘遮住
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:[MQBundleUtil localizedStringForKey:@"cancel"] destructiveButtonTitle:nil otherButtonTitles:[MQBundleUtil localizedStringForKey:@"select_gallery"], [MQBundleUtil localizedStringForKey:@"select_camera"], nil];
    [sheet showInView:self.superview];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            if ([self.choosePictureDelegate respondsToSelector:@selector(choosePictureWithSourceType:)]) {
                [self.choosePictureDelegate choosePictureWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
            break;
        }
        case 1: {
            if ([self.choosePictureDelegate respondsToSelector:@selector(choosePictureWithSourceType:)]) {
                [self.choosePictureDelegate choosePictureWithSourceType:(NSInteger*)UIImagePickerControllerSourceTypeCamera];
            }
            break;
        }
    }
    actionSheet = nil;
}

@end
