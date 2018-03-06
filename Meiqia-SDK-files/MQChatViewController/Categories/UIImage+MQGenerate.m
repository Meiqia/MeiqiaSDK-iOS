//
//  UIImage+Generate.m
//  AutoGang
//
//  Created by ian luo on 14/11/7.
//  Copyright (c) 2014年 com.qcb008.QiCheApp. All rights reserved.
//

#import "UIImage+MQGenerate.h"

@implementation UIImage(MQGenerate)

+ (UIImage *)SquareImageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, ceil(size.width), ceil(size.height)));
    UIImage * image  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)EllipseImageWithColor:(UIColor *)color andSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
    CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
    UIImage * image  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)underLineSquarImageWithBGColor:(UIColor *)color1 lineColor:(UIColor *)color2 andSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color1.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, ceil(size.width), ceil(size.height)));
  
    CGFloat borderWidth = 1.0;
    CGContextSetFillColorWithColor(context, color2.CGColor);
    CGContextFillRect(context, CGRectMake(0, size.height - borderWidth, size.width, borderWidth));
    
    UIImage * image  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)getBlackGradientWithRect:(CGRect)rect
{
  
  UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  NSArray *gradientColors = [NSArray arrayWithObjects:(id)
                             [[UIColor blackColor] colorWithAlphaComponent:0.0].CGColor,
//                             [[UIColor blackColor] colorWithAlphaComponent:0.1].CGColor,
                             [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor,nil];
  
  CGFloat gradientLocations[] = {0.6, 1};
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) gradientColors, gradientLocations);
  
  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
  
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGGradientRelease(gradient);
  CGColorSpaceRelease(colorSpace);
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return image;
}

- (UIImage *)addContentInsect:(UIEdgeInsets)insect {
    CGSize currentSize =  self.size;
    
    CGRect renderRect = CGRectMake(insect.left, insect.top, currentSize.width - insect.left - insect.right, currentSize.height - insect.top - insect.bottom);
    
    UIGraphicsBeginImageContextWithOptions(currentSize, NO, 0);
    [self drawInRect:renderRect];
    UIImage * image  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
