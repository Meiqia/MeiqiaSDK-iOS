//
//  MQPageScrollItemView.m
//  123
//
//  Created by shunxingzhang on 2022/12/27.
//  Copyright © 2022 shunxingzhang. All rights reserved.
//

#import "MQPageScrollItemView.h"

@interface MQPageScrollItemView()

@property (nonatomic, strong) NSArray *contentList;

@property (nonatomic, strong) NSMutableArray *contentViewArr;

@property (nonatomic, assign) int pageMaxSize;

@end

@implementation MQPageScrollItemView

- (instancetype)initPagescrollWithFrame:(CGRect)frame itemViewTitles:(NSArray *)contents pageMaxSize:(int)size {
    if (self = [super initWithFrame:frame]) {
        self.pageMaxSize = size;
        self.currentPageIndex = 0;
        self.totalPage = (contents.count % size  == 0) ? ((int)contents.count / size) : ((int)contents.count / size) + 1;
        self.contentList = [[NSArray alloc] initWithArray:contents];
        [self setupSubViews];
    }
    return self;
}

#pragma mark - Public Method

- (void)updateViewFrameWith:(CGFloat)maxWidth {
    self.bounds = CGRectMake(0, 0, maxWidth, self.pageMaxSize * (kMQPageItemYMargin + kMQPageItemContentHeight));
    __block CGFloat itemY = 0;
    [self.contentViewArr enumerateObjectsUsingBlock:^(UIButton *  _Nonnull btn, NSUInteger idx, BOOL * _Nonnull stop) {
        itemY += kMQPageItemYMargin;
        btn.frame = CGRectMake(kMQPageItemLeftAndRightMargin, itemY, maxWidth - 2 * kMQPageItemLeftAndRightMargin, kMQPageItemContentHeight);
    }];
}

- (void)toNextPage {
    if (self.currentPageIndex + 1 == self.totalPage) {
        return;
    }
    
    NSUInteger totalCount = self.contentList.count;
    int nextPage = self.currentPageIndex + 1;
    __weak typeof(self) weakSelf = self;
    [self.contentViewArr enumerateObjectsUsingBlock:^(UIButton *  _Nonnull btn, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(self) strongSelf = weakSelf;
        NSUInteger currentIndex = nextPage * strongSelf.pageMaxSize + idx;
        if (totalCount > currentIndex) {
            [btn setTitle:self.contentList[currentIndex] forState:UIControlStateNormal];
            btn.hidden = NO;
        } else {
            btn.hidden = YES;
        }
    }];
    self.currentPageIndex = nextPage;
}

- (void)toLastPage {
    if (self.currentPageIndex < 1) {
        return;
    }
    
    int lastPage = self.currentPageIndex - 1;
    __weak typeof(self) weakSelf = self;
    [self.contentViewArr enumerateObjectsUsingBlock:^(UIButton *  _Nonnull btn, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(self) strongSelf = weakSelf;
        NSUInteger currentIndex = lastPage * strongSelf.pageMaxSize + idx;
        [btn setTitle:self.contentList[currentIndex] forState:UIControlStateNormal];
        btn.hidden = NO;
    }];
    self.currentPageIndex = lastPage;
}

#pragma mark - itemButtonTapOnClick
- (void)itemButtonOnClick:(UIButton *)button {
    NSString *content = button.titleLabel.text;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedItemContent:)]) {
        [self.delegate selectedItemContent:content];
    }
}

#pragma mark - Private Method
- (void)setupSubViews {
    [self setupItems];
}

- (void)setupItems {
    
    __weak typeof(self) weakSelf = self;
    __block CGFloat itemY = 0;
    [self.contentList enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        itemY += kMQPageItemYMargin;
        btn.frame = CGRectMake(kMQPageItemLeftAndRightMargin, itemY, weakSelf.bounds.size.width - 2 * kMQPageItemLeftAndRightMargin, kMQPageItemContentHeight);
        itemY += kMQPageItemContentHeight;
        [weakSelf setupButton:btn title:obj idx:idx];
        if (idx == self.pageMaxSize - 1) {
            *stop = YES;
        }
    }];
}

- (void)setupButton:(UIButton *)itemButton title:(NSString *)title idx:(NSInteger)idx {
    [itemButton setTitleColor:[UIColor colorWithRed:24.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [itemButton setTitleColor:[UIColor colorWithRed:24.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:0.5] forState:UIControlStateHighlighted];
    [itemButton setTitle:title forState:UIControlStateNormal];
    itemButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    itemButton.tag = 1000 + idx;
    itemButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    itemButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    itemButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [itemButton addTarget:self action:@selector(itemButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:itemButton];
    [self.contentViewArr addObject:itemButton];
}

#pragma mark - Lazy Method

- (NSMutableArray *)contentViewArr {
    if (!_contentViewArr) {
        _contentViewArr = [NSMutableArray array];
    }
    return _contentViewArr;
}

@end
