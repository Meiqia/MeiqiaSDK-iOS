//
//  MQMessageFormViewStyle.h
//  MQChatViewControllerDemo
//
//  Created by bingoogol on 16/5/11.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+MQHex.h"
#import "MQChatViewStyle.h"

typedef NS_ENUM(NSUInteger, MQMessageFormViewStyleType) {
    MQMessageFormViewStyleTypeDefault,
    MQMessageFormViewStyleTypeBlue,
    MQMessageFormViewStyleTypeGreen,
    MQMessageFormViewStyleTypeDark,
};

@interface MQMessageFormViewStyle : NSObject

@property (nonatomic, copy) UIColor *navTitleColor;

/**
 * 设置导航栏上的元素颜色；
 * @param tintColor 导航栏上的元素颜色
 */
@property (nonatomic, copy) UIColor *navBarTintColor;

/**
 * 设置导航栏的背景色；
 * @param barColor 导航栏背景颜色
 */
@property (nonatomic, copy) UIColor *navBarColor;

/**
 *  留言表单界面背景色
 *
 * @param backgroundColor
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 *  顶部引导文案颜色
 *
 * @param introTextColor
 */
@property (nonatomic, strong) UIColor *introTextColor;

/**
 *  输入框上方提示文案的颜色
 *
 * @param inputTipTextColor
 */
@property (nonatomic, strong) UIColor *inputTipTextColor;

/**
 *  输入框placeholder文字颜色
 *
 * @param inputPlaceholderTextColor
 */
@property (nonatomic, strong) UIColor *inputPlaceholderTextColor;

/**
 *  输入框文字颜色
 *
 * @param inputTextColor
 */
@property (nonatomic, strong) UIColor *inputTextColor;

/**
 *  输入框上下边框颜色
 *
 * @param inputTopBottomBorderColor
 */
@property (nonatomic, strong) UIColor *inputTopBottomBorderColor;

/**
 *  添加图片的文字颜色
 *
 * @param addPictureTextColor
 */
@property (nonatomic, strong) UIColor *addPictureTextColor;

/**
 *  删除图片的图标
 *
 * @param deleteImage
 */
@property (nonatomic, strong) UIImage *deleteImage;

/**
 *  添加图片的图标
 *
 * @param addImage
 */
@property (nonatomic, strong) UIImage *addImage;

+ (instancetype)defaultStyle;

+ (instancetype)blueStyle;

+ (instancetype)darkStyle;

+ (instancetype)greenStyle;

@end
