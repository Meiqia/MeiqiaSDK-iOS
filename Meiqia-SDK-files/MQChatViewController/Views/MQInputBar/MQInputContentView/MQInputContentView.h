//
//  MCInputContentView.h
//  Meiqia
//
//  Created by Injoy on 16/4/14.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MQInputContentView;

@protocol MQInputContentViewDelegate <NSObject>

@optional
/**
 *  用户点击return
 *
 *  @param content          输入内容
 *  @param object           当前自定义数据
 */
- (BOOL)inputContentViewShouldReturn:(MQInputContentView *)inputContentView content:(NSString *)content userObject:(NSObject *)object;

/**
 *  自定义数据改变
 *
 *  @param object           改变后的数据
 */
- (void)inputContentView:(MQInputContentView *)inputContentView userObjectChange:(NSObject *)object;

- (BOOL)inputContentViewShouldBeginEditing:(MQInputContentView *)inputContentView;

- (void)inputContentTextDidChange:(NSString *)newString;

@end

@protocol MQInputContentViewLayoutDelegate <NSObject>

@optional
- (void)inputContentView:(MQInputContentView *)inputContentView willChangeHeight:(CGFloat)height;
- (void)inputContentView:(MQInputContentView *)inputContentView didChangeHeight:(CGFloat)height;

@end


@interface MQInputContentView : UIView

@property (weak, nonatomic) id<MQInputContentViewDelegate> delegate;
@property (weak, nonatomic) id<MQInputContentViewLayoutDelegate> layoutDelegate;


@property (strong, nonatomic) UIView *inputView;
@property (strong, nonatomic) UIView *inputAccessoryView;

- (BOOL)isFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;

- (UIView *)inputView;
- (void)setInputView:(UIView *)inputview;

- (UIView *)inputAccessoryView;
- (void)setInputAccessoryView:(UIView *)inputAccessoryView;

@end
