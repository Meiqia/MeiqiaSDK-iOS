//
//  MCTabInputContentView.m
//  Meiqia
//
//  Created by Injoy on 16/4/14.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import "MQTabInputContentView.h"
#import "MQBundleUtil.h"

@implementation MQTabInputContentView
{
    CALayer *topBoder;
    UIView *tabBackgroud;
}

-(instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textField = [[MEIQIA_HPGrowingTextView alloc] init];
//        self.textField.placeholder = @"输入消息 ...";
        //xlp
        self.textField.placeholder = [MQBundleUtil localizedStringForKey:@"input_content"];

        self.textField.font = [UIFont systemFontOfSize:15];
        self.textField.maxNumberOfLines = 8;
        self.textField.returnKeyType = UIReturnKeySend;
        self.textField.delegate = (id)self;
        [self addSubview:self.textField];

        topBoder = [CALayer layer];
        topBoder.backgroundColor = [UIColor colorWithRed:198/255.0 green:203/255.0 blue:208/255.0 alpha:1].CGColor;
        [self.layer addSublayer:topBoder];
        
        tabBackgroud = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        tabBackgroud.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:253/255.0 alpha:1];
        [self addSubview:tabBackgroud];
        
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        tabBackgroud.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[_textField]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(tabBackgroud, _textField)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tabBackgroud]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(tabBackgroud)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_textField]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_textField)]];
        
    }
    return self;
}



- (void)setupButtons {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContentView:userObjectChange:)]) {
        [self.delegate inputContentView:self userObjectChange:nil];
    }
}

-(void)setNeedsLayout
{
    [super setNeedsLayout];

    topBoder.frame = CGRectMake(0, 0, self.frame.size.width, 1);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContentViewShouldReturn:content:userObject:)])
    {
        return [self.delegate inputContentViewShouldReturn:self content:self.textField.text userObject:nil];
    }
    
    return YES;
}

- (BOOL)isFirstResponder
{
    return self.textField.isFirstResponder;
}

- (BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [self.textField resignFirstResponder];
}

- (UIView *)inputAccessoryView
{
    return [UIView new];
}

-(void)setInputAccessoryView:(UIView *)inputAccessoryView
{
    self.textField.inputAccessoryView = inputAccessoryView;
}

- (UIView *)inputView
{
    return self.textField.inputView;
}

- (void)setInputView:(UIView *)inputview
{
    self.textField.inputView = inputview;
}

#pragma make - HPGrowingTextViewDelegate
- (void)growingTextView:(MEIQIA_HPGrowingTextView *)growingTextView didChangeHeight:(float)height
{
    if (self.layoutDelegate && [self.layoutDelegate respondsToSelector:@selector(inputContentView:didChangeHeight:)]) {
        [self.layoutDelegate inputContentView:self didChangeHeight:self.textField.frame.size.height];
    }
}

- (void)growingTextView:(MEIQIA_HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    if (self.layoutDelegate && [self.layoutDelegate respondsToSelector:@selector(inputContentView:willChangeHeight:)]) {
        [self.layoutDelegate inputContentView:self willChangeHeight:height];
    }
}

- (BOOL)growingTextViewShouldReturn:(MEIQIA_HPGrowingTextView *)growingTextView
{
    if ([growingTextView.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputContentViewShouldReturn:content:userObject:)]) {
            BOOL should = [self.delegate inputContentViewShouldReturn:self content:growingTextView.text userObject:nil];
            if (should) {
                growingTextView.text = @"";
            }
            return should;
        }
    }
    return YES;
}

- (BOOL)growingTextViewShouldBeginEditing:(MEIQIA_HPGrowingTextView *)growingTextView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContentViewShouldBeginEditing:)]) {
        return [self.delegate inputContentViewShouldBeginEditing:self];
    }else{
        return true;
    }
}

- (void)growingTextViewDidChangeSelection:(MEIQIA_HPGrowingTextView *)growingTextView {
    if ([self.delegate respondsToSelector:@selector(inputContentTextDidChange:)]) {
        [self.delegate inputContentTextDidChange:growingTextView.text];
    }
}


@end
