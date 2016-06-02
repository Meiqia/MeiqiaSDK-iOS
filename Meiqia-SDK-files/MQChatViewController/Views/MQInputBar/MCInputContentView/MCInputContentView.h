//
//  MCInputContentView.h
//  Meiqia
//
//  Created by Injoy on 16/4/14.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCInputContentView;

@protocol MCInputContentViewDelegate <NSObject>

@optional
/**
 *  用户点击return
 *
 *  @param content          输入内容
 *  @param object           当前自定义数据
 */
- (BOOL)inputContentViewShouldReturn:(MCInputContentView *)inputContentView content:(NSString *)content userObject:(NSObject *)object;

/**
 *  自定义数据改变
 *
 *  @param object           改变后的数据
 */
- (void)inputContentView:(MCInputContentView *)inputContentView userObjectChange:(NSObject *)object;

- (BOOL)inputContentViewShouldBeginEditing:(MCInputContentView *)inputContentView;

- (void)inputContentTextDidChange:(NSString *)newString;

@end

@protocol MCInputContentViewLayoutDelegate <NSObject>

@optional
- (void)inputContentView:(MCInputContentView *)inputContentView willChangeHeight:(CGFloat)height;
- (void)inputContentView:(MCInputContentView *)inputContentView didChangeHeight:(CGFloat)height;

@end


@interface MCInputContentView : UIView

@property (weak, nonatomic) id<MCInputContentViewDelegate> delegate;
@property (weak, nonatomic) id<MCInputContentViewLayoutDelegate> layoutDelegate;


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
