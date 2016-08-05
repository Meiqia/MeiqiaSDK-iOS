//
//  MQImageViewerViewController.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/5/9.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQImageViewerViewController.h"
#import "MQServiceToViewInterface.h"
#import "MQBundleUtil.h"
#import "MQToast.h"
#import "MQImageUtil.h"

#define KCellReuseId @"cell"

@interface MQImageViewerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *fromRectArray;

@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, assign) CGRect centerScreenFrame;

@end

@implementation MQImageViewerViewController

- (void)showOn:(UIViewController *)controller fromRectArray:(NSArray *)rectArray {
    [controller.view addSubview:self.view];
    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.centerScreenFrame = (CGRect){CGPointMake(CGRectGetMidX(screenRect), CGRectGetMidY(screenRect)), CGSizeZero};
    
    self.fromRectArray = rectArray;
    
    if ((self.fromRectArray.count > 0 && self.fromRectArray.count == self.images.count) || (self.fromRectArray.count > 0 && self.fromRectArray.count == self.imagePaths.count)) {
        self.view.frame = [[self.fromRectArray objectAtIndex:self.currentIndex] CGRectValue];
    } else {
        // 从屏幕中间开始放大
        self.view.frame = self.centerScreenFrame;
    }
    self.view.alpha = 0.0;
    [UIView animateWithDuration:0.35 delay:0.0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.view.frame = [UIScreen mainScreen].bounds;
        self.view.alpha = 1.0;
    } completion:nil];
    
    // 选中当前要浏览图片的位置
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

- (void)dismiss {
    [UIView animateWithDuration:0.35 delay:0.0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        if ((self.fromRectArray.count > 0 && self.fromRectArray.count == self.images.count) || (self.fromRectArray.count > 0 && self.fromRectArray.count == self.imagePaths.count)) {
            self.view.frame = [[self.fromRectArray objectAtIndex:self.currentIndex] CGRectValue];
        } else {
            // 缩放到屏幕中间
            self.view.frame = self.centerScreenFrame;
        }
        self.view.alpha = 0.0;
    } completion:^(BOOL complete){
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)setImages:(NSArray *)images {
    NSMutableArray *tempImageArray = [NSMutableArray new];
    for (UIImage * image in images) {
        [tempImageArray addObject:[MQImageUtil resizeImageToMaxScreenSize:image]];
    }
    _images = tempImageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
    
    if (!self.shouldHideSaveBtn) {
        [self.view addSubview:self.saveButton];
        self.saveButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self leftButtonCornerConstrainsToView:self.saveButton onTo:self.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - collection view delegate and datasource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MQImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:KCellReuseId forIndexPath:indexPath];
    [self loadImageForIndexPath:indexPath forCell:cell];
    
    __weak typeof (self)wself = self;
    [cell setTapOnImage:^{
        __strong typeof (wself) sself = wself;
        if (sself.selection) {
            sself.selection(indexPath.row);
        }
    }];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count ?: self.imagePaths.count;
}

- (void)loadImageForIndexPath:(NSIndexPath *)indexPath forCell:(MQImageCollectionCell *)cell {
    NSString *imagePath = self.imagePaths[indexPath.row];
    if (self.images.count == 0) {
        [MQServiceToViewInterface downloadMediaWithUrlString:imagePath progress:nil completion:^(NSData *mediaData, NSError *error) {
            cell.imageView.image = [MQImageUtil resizeImageToMaxScreenSize:[UIImage imageWithData:mediaData]];
        }];
    } else {
        cell.imageView.image = self.images[indexPath.row];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger page = floor(scrollView.contentOffset.x + scrollView.bounds.size.width / 2) / scrollView.bounds.size.width;
    self.pageControl.currentPage = page;
    self.currentIndex = page;
}

#pragma mark - lazy load

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0.0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:screenRect collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[MQImageCollectionCell class] forCellWithReuseIdentifier:KCellReuseId];
    }
    
    return _collectionView;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton new];
        [_saveButton setTitle:[MQBundleUtil localizedStringForKey:@"save_photo"] forState:(UIControlStateNormal)];
        [_saveButton sizeToFit];
        _saveButton.layer.cornerRadius = 12;
        _saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _saveButton.layer.borderWidth = 1.0;
        _saveButton.layer.masksToBounds = YES;
        _saveButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_saveButton setContentEdgeInsets:UIEdgeInsetsMake(10, 20, 10, 20)];
        [_saveButton addTarget:self action:@selector(saveImage) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _saveButton;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [UIPageControl new];
        _pageControl.numberOfPages = self.images.count ?: self.imagePaths.count;
        _pageControl.currentPage = self.currentIndex;
        [self.view addSubview:_pageControl];
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self centerButtonCornerConstrainsToView:_pageControl onTo:self.view];
    }
    return _pageControl;
}

- (void)saveImage {
    NSUInteger index = self.pageControl.currentPage;
    UIImage *image = [(MQImageCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] imageView].image;
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *) error contextInfo:(void *)contextInfo {
    if (error) {
        [MQToast showToast:[MQBundleUtil localizedStringForKey:@"save_photo_error"] duration:0.25 window:self.view.window];
    } else {
        [MQToast showToast:[MQBundleUtil localizedStringForKey:@"save_photo_success"] duration:0.25 window:self.view.window];
    }
}

- (void)leftButtonCornerConstrainsToView:(UIView *)innderView onTo:(UIView *)outterView {
    NSArray *constrants = @[[NSLayoutConstraint constraintWithItem:innderView attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:outterView attribute:(NSLayoutAttributeLeft) multiplier:1.0 constant:20],
                            [NSLayoutConstraint constraintWithItem:innderView attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:outterView attribute:(NSLayoutAttributeBottom) multiplier:1.0 constant:-20]];
    
    [self.view addConstraints:constrants];
}

- (void)centerButtonCornerConstrainsToView:(UIView *)innderView onTo:(UIView *)outterView {
    NSArray *constrants = @[[NSLayoutConstraint constraintWithItem:innderView attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:outterView attribute:(NSLayoutAttributeCenterX) multiplier:1.0 constant:0],
                            [NSLayoutConstraint constraintWithItem:innderView attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:outterView attribute:(NSLayoutAttributeBottom) multiplier:1.0 constant:0]];
    
    [self.view addConstraints:constrants];
}

@end

#pragma mark - ***
#pragma mark - MQImageCollectionCell

@interface MQImageCollectionCell() <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation MQImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self layoutViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setupViews {
    self.scrollView = [UIScrollView new];
    self.scrollView.maximumZoomScale = 2;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.zoomScale = 1.0;
    self.scrollView.delegate = self;
    [self.contentView addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
    
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped)];
    [self.imageView addGestureRecognizer:tap];
}

- (void)tapped {
    if (self.tapOnImage) {
        self.tapOnImage();
    }
}

- (void)layoutViews {
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSameSizeConstrainsToView:self.scrollView onTo:self.contentView];
    [self addSameSizeConstrainsToView:self.imageView onTo:self.scrollView];
}

- (void)addSameSizeConstrainsToView:(UIView *)innerView onTo:(UIView *)outterView {
    
    NSArray *constrains = @[
                            [NSLayoutConstraint constraintWithItem:innerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:outterView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0],
                            [NSLayoutConstraint constraintWithItem:innerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:outterView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0],
                            [NSLayoutConstraint constraintWithItem:innerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:outterView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0],
                            [NSLayoutConstraint constraintWithItem:innerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:outterView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    [self addConstraints:constrains];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end