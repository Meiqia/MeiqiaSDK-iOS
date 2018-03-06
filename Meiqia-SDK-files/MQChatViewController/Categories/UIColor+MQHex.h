//
//  UIColor+Hex.h
//  AutoGang
//
//  Created by luoxu on 14/12/20.
//  Copyright (c) 2014年 com.qcb008.QiCheApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor(MQHex)

+ (UIColor *)colorWithHexWithLong:(long)hexColor alpha:(CGFloat)a;

+ (UIColor *)colorWithHexWithLong:(long)hexColor;

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)getDarkerColorFromColor1:(UIColor *)color1 color2:(UIColor *)color2;

@end
