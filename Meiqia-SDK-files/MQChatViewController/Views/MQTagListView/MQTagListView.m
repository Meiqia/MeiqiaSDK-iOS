//
//  MQTagListView.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2021/11/16.
//  Copyright © 2021 MeiQia Inc. All rights reserved.
//

#import "MQTagListView.h"

/**
 * tag标签的内边距top
 */
static CGFloat const kMQTagItemTopEdgeInsets = 4.0;
/**
 * tag标签的内边距bottom
 */
static CGFloat const kMQTagItemBottomEdgeInsets = 4.0;
/**
 * tag标签的内边距Left
 */
static CGFloat const kMQTagItemLeftEdgeInsets = 8.0;
/**
 * tag标签的内边距Right
 */
static CGFloat const kMQTagItemRightEdgeInsets = 8.0;
/**
 * tag标签的垂直间距
 */
static CGFloat const kMQTagItemVerticalSpacing = 10.0;
/**
 * tag标签的水平间距
 */
static CGFloat const kMQTagItemHorizontalSpacing = 5.0;

@interface MQTagListView ()

@property(nonatomic, assign) CGFloat cacheMaxWidth;
@property(nonatomic, strong) NSArray *cacheTitleArr;
@property(nonatomic, strong) UIColor *tagBackgroundColor;
@property(nonatomic, strong) UIColor *tagTitleColor;
@property(nonatomic, assign) CGFloat tagFontSize;
@property(nonatomic, assign) BOOL needBorder;
@end

@implementation MQTagListView

-(instancetype)initWithTitleArray:(NSArray *)titleArr
                      andMaxWidth:(CGFloat)maxWidth
               tagBackgroundColor:(nonnull UIColor *)backgroundColor
                    tagTitleColor:(nonnull UIColor *)titleColor
                      tagFontSize:(CGFloat)size
                       needBorder:(BOOL)needBorder {
    if (self = [super init]) {
        self.cacheTitleArr = titleArr;
        self.tagBackgroundColor = backgroundColor;
        self.tagTitleColor = titleColor;
        self.tagFontSize = size;
        self.needBorder = needBorder;
        for (int i = 0; i < titleArr.count; i++) {
            NSString *title = titleArr[i];
            UIButton *btn = [self getTagItemWithTitle:title maxWidth:maxWidth];
            btn.tag = 1000 + i;
            [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        [self updateLayoutWithMaxWidth:maxWidth];
    }
    return self;
}

-(void)updateLayoutWithMaxWidth:(CGFloat)maxWidth {
    if (self.cacheTitleArr && maxWidth != self.cacheMaxWidth) {
        CGFloat height = 0;
        CGFloat tagTempWidth = 0;
        for (int i = 0; i < self.cacheTitleArr.count; i++) {
            UIButton *btn = [self viewWithTag:1000 + i];
            CGFloat btnHeight = btn.bounds.size.height;
            CGFloat btnWidth = btn.bounds.size.width;
            if (height == 0) {
                height = btnHeight;
            }
            if (btnWidth > maxWidth) {
                btnWidth = maxWidth;
            }
            CGFloat tempWidth = btnWidth;
            if (tagTempWidth != 0) {
                tempWidth += kMQTagItemHorizontalSpacing;
            }
            // 判断是否需要换行
            if (tagTempWidth + tempWidth <= maxWidth) {
                tagTempWidth += tempWidth;
            } else {
                tagTempWidth = btnWidth;
                height += kMQTagItemVerticalSpacing + btnHeight;
            }
            btn.frame = CGRectMake(tagTempWidth - btnWidth, height - btnHeight, btnWidth, btnHeight);
        }
        self.bounds = CGRectMake(0, 0, maxWidth, height);
        self.cacheMaxWidth = maxWidth;
    }
}

-(UIButton *)getTagItemWithTitle:(NSString *)title maxWidth:(CGFloat)maxWidth  {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    if (self.tagBackgroundColor) {
        [btn setBackgroundColor:self.tagBackgroundColor];
    }
    [btn setTitleColor:self.tagTitleColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:self.tagFontSize];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 5.0;
    if (self.needBorder) {
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [[UIColor grayColor] CGColor];
    }
    btn.contentEdgeInsets = UIEdgeInsetsMake(kMQTagItemTopEdgeInsets, kMQTagItemLeftEdgeInsets, kMQTagItemBottomEdgeInsets, kMQTagItemRightEdgeInsets);
    [btn sizeToFit];
    btn.bounds = CGRectMake(btn.bounds.origin.x, btn.bounds.origin.y, btn.bounds.size.width > maxWidth ? maxWidth : btn.bounds.size.width, btn.bounds.size.height);
    return btn;
}


-(void)clickButton:(UIButton *)btn {
    NSInteger index = btn.tag - 1000;
    if (self.mqTagListSelectedIndex) {
        self.mqTagListSelectedIndex(index);
    }
}

@end
