//
//  MQMessageFormInputView.h
//  MeiQiaSDK
//
//  Created by bingoogolapple on 16/5/6.
//  Copyright © 2016年 MeiQia Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQMessageFormInputModel.h"
#import "MQMessageFormBaseView.h"

@interface MQMessageFormInputView : MQMessageFormBaseView

- (instancetype)initWithScreenWidth:(CGFloat)screenW andModel:(MQMessageFormInputModel *)model;

@end
