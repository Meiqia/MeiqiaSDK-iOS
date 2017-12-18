//
//  MQInputToolView.m
//  Meiqia
//
//  Created by xulianpeng on 2017/8/31.
//  Copyright © 2017年 Injoy. All rights reserved.
//

#import "MQInputToolView.h"

@implementation MQInputToolView
{
    UIView *buttonContainerView;
    NSLayoutConstraint *buttonContainerViewHeightConstraint;
    id resignFirstResponderBlock;
}

//@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame contentView:(MQInputContentView *)contentView; {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _functionViews = [[NSMutableArray alloc] init];
        
        _buttonGroupBar = [[MQButtonGroupBar alloc] init];
        [self addSubview:self.buttonGroupBar];
        
        _contentView = contentView;
        _contentView.layoutDelegate = self;
        [self addSubview:self.contentView];
        
        if (!self.contentView) {
            _contentView = [[MQInputContentView alloc] init];
        }
        
        buttonContainerView = [[UIView alloc] init];
        [self addSubview:buttonContainerView];
        
        
        [self setup];
    }
    return self;
}

- (void)selectShowFunctionViewWithIndex:(NSInteger)index
{
    NSAssert(index < self.functionViews.count, @"requested index is out of bounds");
    UIView *functionView = [self.functionViews objectAtIndex:index];
    for (UIView *view in buttonContainerView.subviews) {
        [view removeFromSuperview];
    }
    [buttonContainerView addSubview:functionView];
    
    [UIView animateWithDuration:0.25 animations:^{
        
       
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:willChangeHeight:)]) {
            [self.delegate inputBar:self willChangeHeight:self.contentView.frame.size.height + self.buttonGroupBar.frame.size.height + CGRectGetMaxY(functionView.frame)];
        }
        
        buttonContainerViewHeightConstraint.constant = CGRectGetMaxY(functionView.frame);
        [self setNeedsUpdateConstraints];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        _functionViewVisible = true;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:didChangeHeight:)]) {
            [self.delegate inputBar:self didChangeHeight:self.contentView.frame.size.height + self.buttonGroupBar.frame.size.height + buttonContainerViewHeightConstraint.constant];
        }
    }];
    
    
}

- (void)hideSelectedFunctionView
{
    CGFloat height = self.frame.size.height - buttonContainerViewHeightConstraint.constant;
    
    [UIView animateWithDuration:0.25 animations:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:willChangeHeight:)]) {
            [self.delegate inputBar:self willChangeHeight:height];
        }
        
        buttonContainerViewHeightConstraint.constant = 0;
        [self setNeedsUpdateConstraints];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        for (UIView *view in buttonContainerView.subviews) {
            [view removeFromSuperview];
        }
        _functionViewVisible = false;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:didChangeHeight:)]) {
            [self.delegate inputBar:self didChangeHeight:height];
        }
    }];
}

- (void)setInputView:(UIView *)inputView resignFirstResponderBlock:(void (^)())block
{
    _inputView = inputView;
    resignFirstResponderBlock = block;
}

- (void)setup
{
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.buttonGroupBar.translatesAutoresizingMaskIntoConstraints = NO;
    buttonContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.buttonGroupBar.padding = UIEdgeInsetsMake(0, 5, 0, 5);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_contentView]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_contentView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_buttonGroupBar]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_buttonGroupBar)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[buttonContainerView]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(buttonContainerView)]];
    
    buttonContainerViewHeightConstraint = [NSLayoutConstraint constraintWithItem:buttonContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self addConstraint:buttonContainerViewHeightConstraint];
    
    NSString *vfl = @"V:|-0-[_contentView]-0-[_buttonGroupBar(40)]-0-[buttonContainerView]-0-|";
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_contentView, _buttonGroupBar, buttonContainerView)]];
    
}

-(void)setContentViewDelegate:(id<MQInputContentViewDelegate>)contentViewDelegate
{
    self.contentView.delegate = contentViewDelegate;
}

-(void)setButtonGroupDelegate:(id<MQButtonGroupBarDelegate>)buttonGroupDelegate
{
    self.buttonGroupBar.delegate = buttonGroupDelegate;
}

-(id<MQButtonGroupBarDelegate>)buttonGroupDelegate
{
    return self.buttonGroupBar.delegate;
}

#pragma mark - Utilities
- (void)updateConstraint:(NSLayoutConstraint *)constraint withConstant:(CGFloat)constant
{
    if (constraint.constant == constant) {
        return;
    }
    
    constraint.constant = constant;
}

#pragma mark - Override
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)resignFirstResponder
{
    _inputView = nil;
    if (resignFirstResponderBlock) {
        ((void (^)())resignFirstResponderBlock)();
    }
    return [super resignFirstResponder];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

-(void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    //绘制顶部的边线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetRGBStrokeColor(context, 198/255.0, 203/255.0, 208/255.0, 1.0);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextStrokePath(context);
}

#pragma make - InputContentLayoutDelegate
- (void)inputContentView:(MQInputContentView *)inputContentView didChangeHeight:(CGFloat)height
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:didChangeHeight:)]) {
        [self.delegate inputBar:self didChangeHeight:height + self.buttonGroupBar.frame.size.height + buttonContainerViewHeightConstraint.constant];
    }
}

- (void)inputContentView:(MQInputContentView *)inputContentView willChangeHeight:(CGFloat)height
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:willChangeHeight:)]) {
        [self.delegate inputBar:self willChangeHeight:height + self.buttonGroupBar.frame.size.height + buttonContainerViewHeightConstraint.constant];
    }
}

- (void)inputContentTextDidChange:(NSString *)newString {
    if ([newString length] > 0) {
        if ([self.delegate respondsToSelector:@selector(textContentDidChange:)]) {
            [self.delegate textContentDidChange:newString];
        }
    }
}
@end
