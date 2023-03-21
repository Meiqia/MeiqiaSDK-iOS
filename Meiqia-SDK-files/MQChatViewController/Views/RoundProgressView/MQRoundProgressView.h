//
//  RoundProgressView.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/27.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQRoundProgressView : UIView

@property (strong, nonatomic) UIColor *progressColor;

@property (assign, nonatomic) BOOL progressHidden;

- (instancetype)initWithFrame:(CGRect)frame centerView:(UIView *)centerView;

- (void)updateProgress:(CGFloat)progress;

@end
