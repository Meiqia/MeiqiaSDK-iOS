//
//  MQMessageFormBaseView.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/12/8.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MQMessageFormBaseView : UIView

- (void)refreshFrameWithScreenWidth:(CGFloat)screenWidth andY:(CGFloat)y;

/**
 *  查找UIView第一键盘响应者
 *
 *  @return UIView第一键盘响应者
 */
- (UIView *)findFirstResponderUIView;

/**
 *  获取填写的内容
 *
 *  @return id 内容
 */
- (id)getContentValue;

@end

NS_ASSUME_NONNULL_END
