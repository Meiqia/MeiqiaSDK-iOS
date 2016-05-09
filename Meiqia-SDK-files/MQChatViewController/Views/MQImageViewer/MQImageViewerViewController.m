//
//  MQImageViewerViewController.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/5/9.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQImageViewerViewController.h"
#import "MQServiceToViewInterface.h"

#define KCellReuseId @"cell"

@interface MQImageViewerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CGRect fromRect;

@end

@implementation MQImageViewerViewController

- (void)showOn:(UIViewController *)controller fromRect:(CGRect)rect {
    [[[[UIApplication sharedApplication]windows]objectAtIndex:0]addSubview:self.view];
    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
    
    self.fromRect = rect;
    
    self.view.frame = self.fromRect;
    
    [UIView animateWithDuration:0.35 delay:0.0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.view.frame = [UIScreen mainScreen].bounds;
    } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.35 delay:0.0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.view.frame = self.fromRect;
    } completion:^(BOOL complete){
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
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
            cell.imageView.image = [UIImage imageWithData:mediaData];
        }];
    } else {
        cell.imageView.image = self.images[indexPath.row];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark - lazy load

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        
        _collectionView = [[UICollectionView alloc]initWithFrame:screenRect collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MQImageCollectionCell class] forCellWithReuseIdentifier:KCellReuseId];
    }
    
    return _collectionView;
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