//
//  MQTagListView.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2021/11/16.
//  Copyright © 2021 MeiQia Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MQTagListView : UIView

@property (nonatomic, copy) void(^mqTagListSelectedIndex)(NSInteger);

-(instancetype)initWithTitleArray:(NSArray *)titleArr
                      andMaxWidth:(CGFloat)maxWidth
               tagBackgroundColor:(UIColor *)backgroundColor
                    tagTitleColor:(UIColor *)titleColor
                      tagFontSize:(CGFloat)size
                       needBorder:(BOOL)needBorder;


-(void)updateLayoutWithMaxWidth:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
