//
//  MCTabInputContentView.h
//  Meiqia
//
//  Created by Injoy on 16/4/14.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQInputContentView.h"
#import "MEIQIA_HPGrowingTextView.h"

@interface MQTabInputContentView : MQInputContentView <UITextFieldDelegate>

@property (strong, nonatomic) MEIQIA_HPGrowingTextView *textField;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setupButtons;

@end
