//
//  MCButtonGroupBar.h
//  Meiqia
//
//  Created by Injoy on 16/4/1.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MQButtonGroupBar;

/**
 *  「MCButtonGroupBarDelegate」协议定义的方法是与「MCButtonGroupBar」对象进行交互的
 */
@protocol MQButtonGroupBarDelegate <NSObject>

@optional

/**
 *  告诉委托按钮组栏中的一个按钮被点击了
 *
 *  @param buttonGroupBar 发送这一事件的按钮组栏的对象
 *  @param sender         这个按钮接收到了点击事件
 *  @param index          接收到点击事件的按钮，在按钮组中的下标
 */
- (void)buttonGroup:(nonnull MQButtonGroupBar *)buttonGroupBar
     didClickButton:(nonnull UIButton *)sender
     formGroupIndex:(NSUInteger)index;

@end

@interface MQButtonGroupBar : UIView

/**
 *  显示在界面上的按钮数组，它们将按顺序从左向右显示，这个值必须是非空的
 * 
 *  @discussion 如果直接使用这个数组的「addObject」方法添加按钮，可能不会即时在按钮组栏上看到改变，建议使用按钮组栏的「addButtons:」函数添加按钮。
 */
@property (strong, nonatomic, nonnull) NSMutableArray<UIButton *> *buttons;

/** 这个View的4个边与最近按钮的间隔 */
@property (assign, nonatomic         ) UIEdgeInsets padding;

/** 这个对象充当按钮组栏的委托 */
@property (weak, nonatomic, nullable  ) id<MQButtonGroupBarDelegate> delegate;

/**
 *  创建一个会显示一排按钮的矩形的视图
 *
 *  @return 如果初始化成功，将是一个「MCButtonGroupBar」对象，否则为 nil
 */
- (_Nonnull instancetype)init;

/**
 *  使用框架、按钮、代理，创建一个会显示一排按钮的矩形的视图
 *
 *  @param frame   一个定义视图大小的矩形框架，这个值必须是非零非空的
 *  @param buttons 显示在界面上的按钮数组，它们将按顺序从左向右显示，这个值必须是非空的
 *  @param delegate 这个对象充当按钮组栏的委托
 *
 *  @return 如果初始化成功，将是一个「MCButtonGroupBar」对象，否则为 nil
 */
- (_Nonnull instancetype)initWithFrame:(CGRect)frame buttons:(NSArray * _Nonnull)buttons delegate:(id<MQButtonGroupBarDelegate> _Nullable)delegate;

/**
 *  向self.buttons数组中添加一个按钮，并更新视图
 *
 *  @param button 添加到
 */
- (void)addButton:(UIButton * _Nonnull)button;

/**
 *  使用下标移除一个self.buttons数组中的按钮，并更新视图
 *
 *  @param index 被移除的按钮在self.buttons数组中的下标
 */
- (void)removeButtonsWithIndex:(NSUInteger)index;

@end
