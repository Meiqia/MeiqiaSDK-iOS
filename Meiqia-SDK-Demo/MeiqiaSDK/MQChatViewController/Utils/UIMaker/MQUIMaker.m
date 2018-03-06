//
//  MQUIMaker.m
//  Meiqia-SDK-Demo
//
//  Created by xulianpeng on 2018/1/11.
//  Copyright © 2018年 Meiqia. All rights reserved.
//

#import "MQUIMaker.h"
//#import <UIKit/UIKit.h>
//#import <objc/runtime.h>
//#import "UIControl+MQControl.h"
@implementation MQUIMaker
+ (UIButton *)xlpInitWithFrame:(CGRect)frame Title:(NSString*)title titleColor:(UIColor *)color font:(UIFont *)font backColor:(UIColor *)backColor image:(NSString *)imageName backImage:(NSString *)backImageName corner:(CGFloat)cornerRadius superView:(UIView *)superView touchUpInside:(XLPButtonUpInsideBlock)touchUpInside{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    if (font != nil) {
        button.titleLabel.font = font;
    }
    if (title != nil) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    [button setTitleColor:color forState:UIControlStateNormal];
    
    [superView addSubview:button];
    
    if (imageName != nil){
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if (backImageName != nil){
        [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if (cornerRadius > 0) {
        button.layer.masksToBounds = YES;
        button.clipsToBounds = YES;
        button.layer.cornerRadius = cornerRadius;
    }
    button.xlp_touchUpInside = touchUpInside;
    [button setBackgroundColor:backColor];
    return button;
}

+ (UIButton *)xlpInitWithFrame:(CGRect)frame image:(UIImage *)image backImage:(UIImage *)backImage corner:(CGFloat)cornerRadius superView:(UIView *)superView touchUpInside:(XLPButtonUpInsideBlock)touchUpInside{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [superView addSubview:button];
    
    if (image != nil){
        [button setImage:image forState:UIControlStateNormal];
    }
    if (backImage != nil){
        [button setBackgroundImage:backImage forState:UIControlStateNormal];
    }
    if (cornerRadius > 0) {
        button.layer.masksToBounds = YES;
        button.clipsToBounds = YES;
        button.layer.cornerRadius = cornerRadius;
    }
    button.xlp_touchUpInside = touchUpInside;
    return button;
}


@end
