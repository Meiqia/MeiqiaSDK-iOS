//
//  MQPageScrollMenuView.m
//  123
//
//  Created by shunxingzhang on 2022/12/26.
//  Copyright © 2022 shunxingzhang. All rights reserved.
//

#import "MQPageScrollMenuView.h"

static CGFloat const kMQPageScrollBottomLineHeight = 1.0;
static CGFloat const kMQPageScrollItemLeftAndRightMargin = 0.0;
static CGFloat const kMQPageScrollItemMargin = 15.0;

@interface MQPageScrollMenuView()

@property (nonatomic, strong) NSMutableArray *titleArr;
/// items
@property (nonatomic, strong) NSMutableArray<UIButton *> *itemsArrayM;
/// item宽度
@property (nonatomic, strong) NSMutableArray *itemsWidthArraM;
/// 上次index
@property (nonatomic, assign) NSInteger lastIndex;
/// 当前index
@property (nonatomic, assign) NSInteger currentIndex;

/// 蒙层
@property (nonatomic, strong) UIView *converView;
/// ScrollView
@property (nonatomic, strong) UIScrollView *scrollView;
/// 底部线条
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, assign) BOOL isScrolling;

@end

@implementation MQPageScrollMenuView

- (instancetype)initPagescrollMenuViewWithFrame:(CGRect)frame
                                     titles:(NSArray *)titles
                               currentIndex:(NSInteger)currentIndex {
    
    if (self = [super init]) {
        self.frame = frame;
        self.titleArr = [[NSMutableArray alloc] initWithArray:titles];
        self.currentIndex = currentIndex;
        [self setupSubViews];
    }
    return self;
}

- (void)beginScrollContent {
    self.isScrolling = YES;
    UIButton *currentButton = self.itemsArrayM[self.currentIndex];
    [currentButton setTitleColor:[UIColor colorWithRed:24.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    currentButton.selected = NO;
}

- (void)endScrollContentIndex:(NSInteger)index {
    self.isScrolling = NO;
    self.currentIndex= index;
    [self.itemsArrayM enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        [button setTitleColor:[UIColor colorWithRed:111.0/255.0 green:117.0/255.0 blue:146.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }];
    [self adjustItemAnimate:YES];;
}

- (void)updateScrollContentIndex:(NSInteger)index indexPercent:(float)percent {
    if (percent == 0 || !_isScrolling) {
        return;
    }
    if (index > self.currentIndex) {
        self.currentIndex = index;
    } else if (index + 1 < self.currentIndex) {
        self.currentIndex = index + 1;
    }
    
    if (index == self.currentIndex && index + 1 < self.titleArr.count) {
        [self updateScrollOffsetWithIndex:index willIndex:index + 1 indexPercent:percent];
    } else if (index < self.currentIndex && index > -1) {
        [self updateScrollOffsetWithIndex:self.currentIndex willIndex:index indexPercent: 1 - percent];
    }
    
}

- (void)updateScrollOffsetWithIndex:(NSInteger)index willIndex:(NSInteger)willIndex indexPercent:(float)percent {
    UIButton *willButton = self.itemsArrayM[willIndex];
    UIButton *currentButton = self.itemsArrayM[index];
    [willButton setTitleColor:[self getToSelectedButtonRGBWithProgress:percent] forState:UIControlStateNormal];
    [currentButton setTitleColor:[self getToNormalButtonRGBWithProgress:percent] forState:UIControlStateNormal];
    
    if (willIndex > index) {
        self.bottomLine.frame = CGRectMake(CGRectGetMinX(currentButton.frame) + CGRectGetWidth(currentButton.frame) * percent, CGRectGetMaxY(currentButton.frame), CGRectGetWidth(currentButton.frame) * (1 - percent) + CGRectGetWidth(willButton.frame) * percent,kMQPageScrollBottomLineHeight);
        [self adjustItemPositionWithCurrentIndex:willIndex];
    } else {
        self.bottomLine.frame = CGRectMake(CGRectGetMaxX(willButton.frame) - CGRectGetWidth(willButton.frame) * percent, CGRectGetMaxY(currentButton.frame), CGRectGetWidth(currentButton.frame) * (1 - percent) + CGRectGetWidth(willButton.frame) * percent,kMQPageScrollBottomLineHeight);
        [self adjustItemPositionWithCurrentIndex:willIndex];
    }
    
}

#pragma mark - itemButtonTapOnClick
- (void)itemButtonOnClick:(UIButton *)button {
    self.currentIndex= button.tag;
    [self adjustItemWithAnimated:YES];
    if (self.delegate &&[self.delegate respondsToSelector:@selector(selectedMenuIndex:)]) {
        [self.delegate selectedMenuIndex:self.currentIndex];
    }
}
//
//- (void)reloadView {
//    for (UIView *view in self.subviews) {
//        [view removeFromSuperview];
//    }
//
//    for (UIView *view in self.scrollView.subviews) {
//        [view removeFromSuperview];
//    }
//
//    [self.itemsArrayM removeAllObjects];
//    [self.itemsWidthArraM removeAllObjects];
//    [self setupSubViews];
//}

#pragma mark - Private Method
- (void)setupSubViews {
    [self setupItems];
    [self setupOtherViews];
}

- (void)setupItems {
    [self.titleArr enumerateObjectsUsingBlock:^(id  _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setupButton:itemButton title:title idx:idx];
    }];
}

- (void)setupButton:(UIButton *)itemButton title:(NSString *)title idx:(NSInteger)idx {
    itemButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [itemButton setTitleColor:[UIColor colorWithRed:111.0/255.0 green:117.0/255.0 blue:146.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [itemButton setTitleColor:[UIColor colorWithRed:24.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateSelected];
    [itemButton setTitle:title forState:UIControlStateNormal];
    itemButton.tag = idx;
    [itemButton addTarget:self action:@selector(itemButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [itemButton sizeToFit];
    [self.itemsWidthArraM addObject:@(itemButton.bounds.size.width)];
    [self.itemsArrayM addObject:itemButton];
    [self.scrollView addSubview:itemButton];
}

- (UIColor *)getToNormalButtonRGBWithProgress:(CGFloat)progress {
    CGFloat r = 24 + (111.0 - 24.0) * progress;
    CGFloat g = 128.0 - (128.0 - 117.0) * progress;
    CGFloat b = 255.0 - (255.0 - 146.0) * progress;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

- (UIColor *)getToSelectedButtonRGBWithProgress:(CGFloat)progress {
    CGFloat r = 111.0 - (111.0 - 24.0) * progress;
    CGFloat g = 117.0 + (128.0 - 117.0) * progress;
    CGFloat b = 146.0 + (255.0 - 146.0) * progress;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

- (void)setupOtherViews {
    self.scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.self.bounds.size.height);
    [self addSubview:self.scrollView];
    
    /// item
    __block CGFloat itemX = 0;
    __block CGFloat itemY = 0;
    __block CGFloat itemH = self.bounds.size.height - kMQPageScrollBottomLineHeight;
    
    [self.itemsArrayM enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            itemX += kMQPageScrollItemLeftAndRightMargin;
        }else{
            itemX += kMQPageScrollItemMargin + [self.itemsWidthArraM[idx - 1] floatValue];
        }
        button.frame = CGRectMake(itemX, itemY, [self.itemsWidthArraM[idx] floatValue], itemH);
    }];
    
    CGFloat scrollSizeWidth = kMQPageScrollItemLeftAndRightMargin + CGRectGetMaxX([[self.itemsArrayM lastObject] frame]);
    self.scrollView.contentSize = CGSizeMake(scrollSizeWidth, self.scrollView.bounds.size.height);
    
    self.bottomLine.frame = CGRectMake(kMQPageScrollItemLeftAndRightMargin, CGRectGetMaxY(self.scrollView.frame) - kMQPageScrollBottomLineHeight, [self.itemsWidthArraM.firstObject floatValue], kMQPageScrollBottomLineHeight);
    [self.scrollView insertSubview:self.bottomLine atIndex:0];
    
    [self setDefaultTheme];
    [self selectedItemIndex:self.currentIndex animated:NO];
}

- (void)setDefaultTheme {
    UIButton *currentButton = self.itemsArrayM[self.currentIndex];
    currentButton.selected = YES;
    self.lastIndex = self.currentIndex;
}

- (void)adjustItemAnimate:(BOOL)animated {
    UIButton *lastButton = self.itemsArrayM[self.lastIndex];
    UIButton *currentButton = self.itemsArrayM[self.currentIndex];
    [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
        /// 颜色
        lastButton.selected = NO;
        currentButton.selected  = YES;
        self.bottomLine.frame = CGRectMake(CGRectGetMinX(currentButton.frame), CGRectGetMaxY(currentButton.frame), CGRectGetWidth(currentButton.frame), kMQPageScrollBottomLineHeight);
        self.lastIndex = self.currentIndex;
    } completion:^(BOOL finished) {
        [self adjustItemPositionWithCurrentIndex:self.currentIndex];
    }];
}

- (void)selectedItemIndex:(NSInteger)index
                 animated:(BOOL)animated {
    self.currentIndex = index;
    [self adjustItemAnimate:animated];
}

- (void)adjustItemWithAnimated:(BOOL)animated {
    if (self.lastIndex == self.currentIndex) return;
    [self adjustItemAnimate:animated];
}

- (void)adjustItemPositionWithCurrentIndex:(NSInteger)index {
    UIButton *button = self.itemsArrayM[index];
    CGFloat offSex = button.center.x - self.scrollView.bounds.size.width * 0.5;
    
    offSex = offSex > 0 ? offSex : 0;
    
    CGFloat maxOffSetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    
    maxOffSetX = maxOffSetX > 0 ? maxOffSetX : 0;
    
    offSex = offSex > maxOffSetX ? maxOffSetX : offSex;
    
    [self.scrollView setContentOffset:CGPointMake(offSex, 0) animated:YES];
}

#pragma mark - Lazy Method

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor colorWithRed:24.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0];
    }
    return _bottomLine;
}

- (NSMutableArray *)itemsWidthArraM {
    if (!_itemsWidthArraM) {
        _itemsWidthArraM = [NSMutableArray array];
    }
    return _itemsWidthArraM;
}

- (NSMutableArray *)itemsArrayM {
    if (!_itemsArrayM) {
        _itemsArrayM = [NSMutableArray array];
    }
    return _itemsArrayM;
}

@end
