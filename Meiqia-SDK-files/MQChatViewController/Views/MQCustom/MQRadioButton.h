//
//  MQRadioButton.h
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/25.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QRadioButtonDelegate;

@interface MQRadioButton : UIButton
 
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) NSString *selectedImgName;
@property (nonatomic, strong) NSString *unSelectedImgName;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) BOOL selectedAll;

@end

NS_ASSUME_NONNULL_END
