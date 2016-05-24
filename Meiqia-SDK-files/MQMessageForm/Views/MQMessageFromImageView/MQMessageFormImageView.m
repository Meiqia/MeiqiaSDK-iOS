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

static CGFloat const kMQMessageFormSpacing   = 16.0;
static CGFloat const kMQMessageFormMaxPictureItemLength = 116;
static CGFloat const kMQMessageFormMaxDeleteItemLength = 24;

@implementation MQMessageFormImageView {
    UILabel *addPictureLabel;
    
    UIView *pictureOneItem;
    UIImageView *pictureOneIv;
    UIImageView *deleteOneIv;
    
    UIView *pictureTwoItem;
    UIImageView *pictureTwoIv;
    UIImageView *deleteTwoIv;
    
    UIView *pictureThreeItem;
    UIImageView *pictureThreeIv;
    UIImageView *deleteThreeIv;
    
    CGFloat pictureItemLength;
    CGFloat pictureLength;
    
    NSMutableArray *images;
    UIImage *deleteIconImage;
    UIImage *addIconImage;
}

- (instancetype)initWithScreenWidth:(CGFloat)screenWidth {
    self = [super init];
    if (self) {
        images = [NSMutableArray arrayWithCapacity:3];
        deleteIconImage = [MQMessageFormConfig sharedConfig].messageFormViewStyle.deleteImage;
        addIconImage = [MQMessageFormConfig sharedConfig].messageFormViewStyle.addImage;
        
        [self calculatePictureAndPictureItemLengthWithScreenWidth:screenWidth];
        
        [self initAddPictureLabel];
        [self initPictureOneItem];
        [self initPictureTwoItem];
        [self initPictureThreeItem];
        
        [self handlePictureCount];
    }
    return self;
}

/**
 *  根据屏幕宽度计算图片宽度和图片条目宽度
 *
 *  @param screenWidth 屏幕宽度
 */
- (void)calculatePictureAndPictureItemLengthWithScreenWidth:(CGFloat)screenWidth {
    pictureItemLength = (screenWidth - 4 * kMQMessageFormSpacing) / 3;
    pictureItemLength = pictureItemLength > kMQMessageFormMaxPictureItemLength ? kMQMessageFormMaxPictureItemLength : pictureItemLength;
    pictureLength = pictureItemLength - kMQMessageFormMaxDeleteItemLength / 2;
}

- (void)initAddPictureLabel {
    addPictureLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMQMessageFormSpacing, 0, 0, 0)];
    addPictureLabel.text = [MQBundleUtil localizedStringForKey:@"add_picture"];
    addPictureLabel.textColor = [MQMessageFormConfig sharedConfig].messageFormViewStyle.addPictureTextColor;
    addPictureLabel.font = [UIFont systemFontOfSize:14.0];
    [addPictureLabel sizeToFit];
    [self addSubview:addPictureLabel];
}

- (void)initPictureOneItem {
    pictureOneItem = [[UIView alloc] init];
    pictureOneIv = [[UIImageView alloc] init];
    deleteOneIv = [[UIImageView alloc] init];
    
    [self initItem:pictureOneItem pictureIv:pictureOneIv deleteIv:deleteOneIv index:0];
    [self refreshFrameWithItem:pictureOneItem pictureIv:pictureOneIv deleteIv:deleteOneIv preItem:nil];
    [self addSubview:pictureOneItem];
}

- (void)initPictureTwoItem {
    pictureTwoItem = [[UIView alloc] init];
    pictureTwoIv = [[UIImageView alloc] init];
    deleteTwoIv = [[UIImageView alloc] init];
    
    [self initItem:pictureTwoItem pictureIv:pictureTwoIv deleteIv:deleteTwoIv index:1];
    [self refreshFrameWithItem:pictureTwoItem pictureIv:pictureTwoIv deleteIv:deleteTwoIv preItem:pictureOneItem];
    [self addSubview:pictureTwoItem];
}

- (void)initPictureThreeItem {
    pictureThreeItem = [[UIView alloc] init];
    pictureThreeIv = [[UIImageView alloc] init];
    deleteThreeIv = [[UIImageView alloc] init];
    
    [self initItem:pictureThreeItem pictureIv:pictureThreeIv deleteIv:deleteThreeIv index:2];
    [self refreshFrameWithItem:pictureThreeItem pictureIv:pictureThreeIv deleteIv:deleteThreeIv preItem:pictureTwoItem];
    [self addSubview:pictureThreeItem];
}

- (void)initItem:(UIView *)item pictureIv:(UIImageView *)pictureIv deleteIv:(UIImageView *)deleteIv index:(NSInteger)index {
    pictureIv.contentMode = UIViewContentModeScaleAspectFill;
    pictureIv.clipsToBounds = YES;
    pictureIv.userInteractionEnabled = YES;
    pictureIv.tag = index;
    [pictureIv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPicture:)]];
    
    deleteIv.image = deleteIconImage;
    deleteIv.userInteractionEnabled = YES;
    deleteIv.tag = index;
    [deleteIv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDeleteIcon:)]];
    
    [item addSubview:pictureIv];
    [item addSubview:deleteIv];
}

- (void)refreshFrameWithItem:(UIView *)item pictureIv:(UIImageView *)pictureIv deleteIv:(UIImageView *)deleteIv preItem:(UIView *)preItem{
    CGFloat addPictureLabelMaxY = CGRectGetMaxY(addPictureLabel.frame);
    CGFloat itemX = preItem == nil ? kMQMessageFormSpacing : CGRectGetMaxX(preItem.frame) + kMQMessageFormSpacing - kMQMessageFormMaxDeleteItemLength / 2;
    item.frame = CGRectMake(itemX, addPictureLabelMaxY, pictureItemLength, pictureItemLength);
    pictureIv.frame = CGRectMake(0, kMQMessageFormMaxDeleteItemLength / 2, pictureLength, pictureLength);
    deleteIv.frame = CGRectMake(pictureItemLength - kMQMessageFormMaxDeleteItemLength, 0, kMQMessageFormMaxDeleteItemLength, kMQMessageFormMaxDeleteItemLength);
}

- (void)tapDeleteIcon:(UITapGestureRecognizer *)sender {
    UIImageView *deleteIconIv = (UIImageView *)sender.view;
    [images removeObjectAtIndex:deleteIconIv.tag];
    [self handlePictureCount];
}

- (void)tapPicture:(UITapGestureRecognizer *)sender {
    UIImageView *pictureIv = (UIImageView *)sender.view;
    if (images.count < (pictureIv.tag + 1)) {
        [self showChoosePictureActionSheet];
    } else {
        [self showImageViewerWithIndex:pictureIv.tag];
    }
}

- (void)showImageViewerWithIndex:(NSUInteger)index {
    MQImageViewerViewController *viewerVC = [MQImageViewerViewController new];
    viewerVC.images = images;
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
    if (images.count > 0) {
        [fromRectArray addObject:[NSValue valueWithCGRect:[pictureOneIv.superview convertRect:pictureOneIv.frame toView:[UIApplication sharedApplication].keyWindow]]];
    }
    if (images.count > 1) {
        [fromRectArray addObject:[NSValue valueWithCGRect:[pictureTwoIv.superview convertRect:pictureTwoIv.frame toView:[UIApplication sharedApplication].keyWindow]]];
    }
    if (images.count > 2) {
        [fromRectArray addObject:[NSValue valueWithCGRect:[pictureThreeIv.superview convertRect:pictureThreeIv.frame toView:[UIApplication sharedApplication].keyWindow]]];
    }
    return fromRectArray;
}

- (void)handlePictureCount {
    if (images.count == 0) {
        [self changeToZeroPicture];
    } else if (images.count == 1) {
        [self changeToOnePicture];
    } else if (images.count == 2) {
        [self changeToTwoPicture];
    } else if (images.count == 3) {
        [self changeToThreePicture];
    }
}

- (void)changeToZeroPicture {
    pictureTwoItem.hidden = YES;
    pictureThreeItem.hidden = YES;
    
    deleteOneIv.hidden = YES;
    deleteTwoIv.hidden = YES;
    deleteThreeIv.hidden = YES;
    
    pictureOneIv.image = addIconImage;
}

- (void)changeToOnePicture {
    pictureTwoItem.hidden = NO;
    pictureThreeItem.hidden = YES;
    
    deleteOneIv.hidden = NO;
    deleteTwoIv.hidden = YES;
    deleteThreeIv.hidden = YES;
    
    pictureOneIv.image = [images objectAtIndex:0];
    pictureTwoIv.image = addIconImage;
}

- (void)changeToTwoPicture {
    pictureTwoItem.hidden = NO;
    pictureThreeItem.hidden = NO;
    
    deleteOneIv.hidden = NO;
    deleteTwoIv.hidden = NO;
    deleteThreeIv.hidden = YES;
    
    pictureOneIv.image = [images objectAtIndex:0];
    pictureTwoIv.image = [images objectAtIndex:1];
    pictureThreeIv.image = addIconImage;
}

- (void)changeToThreePicture {
    pictureTwoItem.hidden = NO;
    pictureThreeItem.hidden = NO;
    
    deleteOneIv.hidden = NO;
    deleteTwoIv.hidden = NO;
    deleteThreeIv.hidden = NO;
    
    pictureOneIv.image = [images objectAtIndex:0];
    pictureTwoIv.image = [images objectAtIndex:1];
    pictureThreeIv.image = [images objectAtIndex:2];
}

- (void)refreshFrameWithScreenWidth:(CGFloat)screenWidth andY:(CGFloat)y {
    [self calculatePictureAndPictureItemLengthWithScreenWidth:screenWidth];
    
    [addPictureLabel sizeToFit];
    
    [self refreshFrameWithItem:pictureOneItem pictureIv:pictureOneIv deleteIv:deleteOneIv preItem:nil];
    [self refreshFrameWithItem:pictureTwoItem pictureIv:pictureTwoIv deleteIv:deleteTwoIv preItem:pictureOneItem];
    [self refreshFrameWithItem:pictureThreeItem pictureIv:pictureThreeIv deleteIv:deleteThreeIv preItem:pictureTwoItem];
    
    self.frame = CGRectMake(0, y + kMQMessageFormSpacing, screenWidth, CGRectGetMaxY(pictureOneItem.frame) + kMQMessageFormSpacing);
}

- (void)addImage:(UIImage *)image {
    [images addObject:image];
    [self handlePictureCount];
}

- (NSArray *)getImages {
    return images;
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
            if ([self.delegate respondsToSelector:@selector(choosePictureWithSourceType:)]) {
                [self.delegate choosePictureWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
            break;
        }
        case 1: {
            if ([self.delegate respondsToSelector:@selector(choosePictureWithSourceType:)]) {
                [self.delegate choosePictureWithSourceType:(NSInteger*)UIImagePickerControllerSourceTypeCamera];
            }
            break;
        }
    }
    actionSheet = nil;
}

@end
