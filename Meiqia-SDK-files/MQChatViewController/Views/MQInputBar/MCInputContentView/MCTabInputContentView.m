//
//  MCTabInputContentView.m
//  Meiqia
//
//  Created by Injoy on 16/4/14.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import "MCTabInputContentView.h"

@implementation MCTabInputContentView
{
    CALayer *topBoder;
    UIView *tabBackgroud;
}

-(instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textField = [[MEIQIA_HPGrowingTextView alloc] init];
        self.textField.placeholder = @"输入消息 ...";
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
        
//        self.filterView = [[DMFilterView alloc] initWithStrings:strings containerView:self.textField];
    }
    return self;
}

//- (void)changeTitles:(NSArray<NSString *> *)strings
//{
//    self.filterView = [[DMFilterView alloc] initWithStrings:strings containerView:self.textField];
//}

//-(void)setFilterView:(DMFilterView *)filterView
//{
//    if(self.filterView) {
//        [_filterView removeFromSuperview];
//        _filterView = nil;
//    }
//    
//    [filterView setTitlesColor:[UIColor colorWithRed:90/255.0 green:105/255.0 blue:120/255.0 alpha:1]];
//    [filterView setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:253/255.0 alpha:1]];
//    [filterView setSelectedItemBackgroundColor:[UIColor whiteColor]];
//    [filterView setSelectedItemTopBackgroundColor:[UIColor colorWithRed:23/255.0 green:199/255.0 blue:209/255.0 alpha:1]];
//    [filterView setSelectedItemTopBackroundColorHeight:0];
//    filterView.draggable = NO;
//    filterView.delegate = self;
//    
//    _filterView = filterView;
//    [tabBackgroud addSubview:_filterView];
//    [tabBackgroud removeConstraints:self.constraints];
//    
//    self.filterView.translatesAutoresizingMaskIntoConstraints = NO;
//    CGFloat width = [self.filterView titlesCount] * self.frame.size.width / 4;
//    [tabBackgroud addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_filterView]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_filterView)]];
//    [tabBackgroud addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-0-[_filterView(%f)]", width] options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_filterView)]];
//    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContentView:userObjectChange:)]) {
//        [self.delegate inputContentView:self userObjectChange:[self.filterView titleAtIndex:self.filterView.selectedIndex]];
//    }
//}

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
        [self.delegate inputContentViewShouldReturn:self content:self.textField.text userObject:nil];
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
            [self.delegate inputContentViewShouldReturn:self content:growingTextView.text userObject:nil];
            
            growingTextView.text = @"";
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

//#pragma make - DMFilterViewDelegate
//-(void)filterView:(DMFilterView *)filterView didSelectedAtIndex:(NSInteger)index
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContentView:userObjectChange:)]) {
//        [self.delegate inputContentView:self userObjectChange:[self.filterView titleAtIndex:index]];
//    }
//}

@end
