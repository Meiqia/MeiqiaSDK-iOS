//
//  MCInputToolBar.h
//  Meiqia
//
//  Created by Injoy on 16/4/1.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQButtonGroupBar.h"
#import "MQInputContentView.h"

@class MQInputToolBar;

@protocol MQInputToolBarDelegate <UIToolbarDelegate>

@optional
- (void)inputBar:(MQInputToolBar *)inputBar willChangeHeight:(CGFloat)height;
- (void)inputBar:(MQInputToolBar *)inputBar didChangeHeight:(CGFloat)height;
- (void)textContentDidChange:(NSString *)newString;

@end


@interface MQInputToolBar : UIToolbar <MQInputContentViewDelegate, MQInputContentViewLayoutDelegate>

@property (weak, nonatomic) id<MQInputToolBarDelegate> delegate;
@property (weak, nonatomic) id<MQInputContentViewDelegate> contentViewDelegate;
@property (weak, nonatomic) id<MQButtonGroupBarDelegate> buttonGroupDelegate;

@property (strong, nonatomic, readonly) MQInputContentView *contentView;

@property (strong, nonatomic, readonly) MQButtonGroupBar *buttonGroupBar;

@property (strong, nonatomic) UIView *inputView;

/** 扩展功能的view，显示在MCButtonGroupBar下面 */
@property (strong, nonatomic, readonly) NSMutableArray<UIView *> *functionViews;
/** 功能View当前是否可见 */
@property (assign, nonatomic, readonly) BOOL functionViewVisible;

- (instancetype)initWithFrame:(CGRect)frame contentView:(MQInputContentView *)contentView;

/**
 *  显示一个functionView
 *
 *  @param index functionViews的下标，用于指定显示哪个functionView
 */
- (void)selectShowFunctionViewWithIndex:(NSInteger)index;

/**
 *  隐藏当前显示的functionView
 */
- (void)hideSelectedFunctionView;

/**
 *  给inputView复制，并设置当InputBar失去焦点时的回调。
 */
- (void)setInputView:(UIView *)inputView resignFirstResponderBlock:(void (^)())block;

@end
