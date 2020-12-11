//
//  MQRadioGroup.m
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/26.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQRadioGroup.h"

@implementation MQRadioGroup

-(id)initWithFrame:(CGRect)frame WithCheckBtns:(NSArray *)checkBtns
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _selectTextArr=[[NSMutableArray alloc] init];
        _selectValueArr=[[NSMutableArray alloc] init];
        for (id checkBtn in checkBtns) {
            [self addSubview:checkBtn];
        }
        [self commonInit];
    }
    return self;
}
-(void)commonInit
{
    for (UIView *checkBtn in self.subviews) {
        if ([checkBtn isKindOfClass:[MQRadioButton class]]) {
            if (((MQRadioButton*)checkBtn).selectedAll) {
                [(MQRadioButton*)checkBtn addTarget:self action:@selector(selectedAllCheckBox:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [(MQRadioButton*)checkBtn addTarget:self action:@selector(checkboxBtnChecked:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}
-(void)checkboxBtnChecked:(MQRadioButton *)sender
{
    if (self.isCheck) {
        sender.selected=!sender.selected;
        if (sender.selected) {
            [_selectTextArr addObject:((MQRadioButton *)sender).text];
            [_selectValueArr addObject:((MQRadioButton *)sender).value];
        }else{
            for (id checkBtn in self.subviews) {
                if ([checkBtn isKindOfClass:[MQRadioButton class]]) {
                    if (((MQRadioButton *)checkBtn).selectedAll) {
                        [(MQRadioButton *)checkBtn setSelected:NO];
                    }
                }
            }
            [_selectTextArr removeObject:((MQRadioButton *)sender).text];
            [_selectValueArr removeObject:((MQRadioButton *)sender).value];
        }
    }else{
        for (id checkBtn in self.subviews) {
            if ([checkBtn isKindOfClass:[MQRadioButton class]]) {
                [(MQRadioButton *)checkBtn setSelected:NO];
            }
        }
        sender.selected=YES;
        self.selectText = ((MQRadioButton *)sender).text;
        self.selectValue = ((MQRadioButton *)sender).value;
    }
}
-(void)selectedAllCheckBox:(MQRadioButton *)sender
{
    sender.selected=!sender.selected;
    [_selectTextArr removeAllObjects];
    [_selectValueArr removeAllObjects];
    for (id checkBtn in self.subviews) {
        if ([checkBtn isKindOfClass:[MQRadioButton class]]) {
            if (!((MQRadioButton *)checkBtn).selectedAll) {
                [(MQRadioButton *)checkBtn setSelected:sender.selected];
                if (((MQRadioButton *)checkBtn).selected) {
                    [_selectTextArr addObject:((MQRadioButton *)checkBtn).text];
                    [_selectValueArr addObject:((MQRadioButton *)checkBtn).value];
                }
            }
        }
    }
}
@end
