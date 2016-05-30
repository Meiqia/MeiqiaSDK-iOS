//
//  MCInputToolBar.h
//  Meiqia
//
//  Created by Injoy on 16/4/1.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCButtonGroupBar.h"
#import "MCInputContentView.h"

@class MCInputToolBar;

@protocol MCInputToolBarDelegate <UIToolbarDelegate>

@optional
- (void)inputBar:(MCInputToolBar *)inputBar willChangeHeight:(CGFloat)height;
- (void)inputBar:(MCInputToolBar *)inputBar didChangeHeight:(CGFloat)height;
- (void)textContentDidChange:(NSString *)newString;

@end


@interface MCInputToolBar : UIToolbar <MCInputContentViewDelegate, MCInputContentViewLayoutDelegate>

@property (weak, nonatomic) id<MCInputToolBarDelegate> delegate;
@property (weak, nonatomic) id<MCInputContentViewDelegate> contentViewDelegate;
@property (weak, nonatomic) id<MCButtonGroupBarDelegate> buttonGroupDelegate;

@property (strong, nonatomic, readonly) MCInputContentView *contentView;

@property (strong, nonatomic, readonly) MCButtonGroupBar *buttonGroupBar;

@property (strong, nonatomic) UIView *inputView;

/** 扩展功能的view，显示在MCButtonGroupBar下面 */
@property (strong, nonatomic, readonly) NSMutableArray<UIView *> *functionViews;
/** 功能View当前是否可见 */
@property (assign, nonatomic, readonly) BOOL functionViewVisible;

- (instancetype)initWithFrame:(CGRect)frame contentView:(MCInputContentView *)contentView;

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
