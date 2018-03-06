//
//  MCButtonGroupBar.m
//  Meiqia
//
//  Created by Injoy on 16/4/1.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import "MQButtonGroupBar.h"


@implementation MQButtonGroupBar

- (_Nonnull instancetype)initWithFrame:(CGRect)frame buttons:(NSArray * _Nonnull)buttons delegate:(id<MQButtonGroupBarDelegate> _Nullable)delegate
{
    if (self = [super initWithFrame:frame]) {
        _buttons = buttons.mutableCopy;
        _delegate = delegate;
    }
    return self;
}

-(instancetype)init
{
    if (self = [super init]) {
        _buttons = [NSMutableArray new];
    }
    return self;
}

- (void)setButtons:(NSMutableArray<UIButton *> *)buttons
{
    if (_buttons) {
        for(UIButton *btn in _buttons) {
            [btn removeFromSuperview];
        }
    }
    
    _buttons = buttons;
    [self setup];
}

- (void)setPadding:(UIEdgeInsets)padding
{
    _padding = padding;
    [self setup];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setup];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self setup];
}

- (void)setup
{
    if (self.buttons.count == 0) return;
    
    CGSize availableSize = CGSizeMake(
                                      self.frame.size.width - self.padding.left - self.padding.right,
                                      self.frame.size.height - self.padding.top - self.padding.bottom
                                      );
    
//    CGFloat buttonContainerWidth = availableSize.width / self.buttons.count;
    CGFloat buttonContainerWidth = availableSize.width / 5;
    
    CGFloat lastContainerX = self.padding.left;
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(lastContainerX, 0, buttonContainerWidth, availableSize.height)];
        UIButton *button = self.buttons[i];
        button.frame = CGRectMake((buttonContainerWidth - button.frame.size.width) / 2,
                                  (availableSize.height - button.frame.size.height) / 2,
                                  button.frame.size.width, button.frame.size.height);
        
        [buttonContainer addSubview:button];
        [self addSubview:buttonContainer];
        
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        lastContainerX = lastContainerX + buttonContainer.frame.size.width;
    }
}

- (void)buttonAction:(UIButton *)sender {
    NSUInteger index = [self.buttons indexOfObject:sender];
    if (index != NSNotFound) {
        if ([self.delegate respondsToSelector:@selector(buttonGroup:didClickButton:formGroupIndex:)]) {
            [self.delegate buttonGroup:self didClickButton:sender formGroupIndex:index];
        }
    }
}

- (void)addButton:(UIButton * _Nonnull)button
{
    [self.buttons addObject:button];
    [self refreshDisplay];
}

- (void)removeButtonsWithIndex:(NSUInteger)index
{
    if (self.buttons.count != 0 && self.buttons.count - 1 >= index) {
        [self.buttons removeObjectAtIndex:index];
    }
    
    [self refreshDisplay];
}

- (void)refreshDisplay
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    [self setup];
}

@end
