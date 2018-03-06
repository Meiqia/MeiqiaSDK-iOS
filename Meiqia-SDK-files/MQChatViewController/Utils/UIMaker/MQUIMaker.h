//
//  MQUIMaker.h
//  Meiqia-SDK-Demo
//
//  Created by xulianpeng on 2018/1/11.
//  Copyright © 2018年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "UIControl+MQControl.h"
@interface MQUIMaker : NSObject
+ (UIButton *)xlpInitWithFrame:(CGRect)frame Title:(NSString*)title titleColor:(UIColor *)color font:(UIFont *)font backColor:(UIColor *)backColor image:(NSString *)imageName backImage:(NSString *)backImageName corner:(CGFloat)cornerRadius superView:(UIView *)superView touchUpInside:(XLPButtonUpInsideBlock)touchUpInside;
+ (UIButton *)xlpInitWithFrame:(CGRect)frame image:(UIImage *)image backImage:(UIImage *)backImage corner:(CGFloat)cornerRadius superView:(UIView *)superView touchUpInside:(XLPButtonUpInsideBlock)touchUpInside;
@end
