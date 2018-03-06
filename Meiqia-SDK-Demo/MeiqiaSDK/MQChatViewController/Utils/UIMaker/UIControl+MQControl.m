//
//  UIControl+MQControl.m
//  Meiqia-SDK-Demo
//
//  Created by xulianpeng on 2018/1/11.
//  Copyright © 2018年 Meiqia. All rights reserved.
//

#import "UIControl+MQControl.h"
#import <objc/runtime.h>

// TouchDown/TouchUp事件的key
static const void *s_XLPButtonTouchDownKey = "s_XLPButtonTouchDownKey";
static const void *s_XLPButtonTouchUpKey = "s_XLPButtonTouchUpKey";
static const void *s_XLPValueChangedKey = "s_XLPValueChangedKey";


@implementation UIControl (MQControl)
- (void)setXlp_touchDown:(XLPButtonDownBlock)xlp_touchDown {
    objc_setAssociatedObject(self, s_XLPButtonTouchDownKey, xlp_touchDown, OBJC_ASSOCIATION_COPY);
    
    [self removeTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    if (xlp_touchDown) {
        [self addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
    }
}

- (XLPButtonDownBlock)xlp_touchDown {
    XLPButtonDownBlock downBlock = objc_getAssociatedObject(self, s_XLPButtonTouchDownKey);
    return downBlock;
}

- (void)setXlp_touchUpInside:(XLPButtonUpInsideBlock)xlp_touchUpInside {
    objc_setAssociatedObject(self, s_XLPButtonTouchUpKey, xlp_touchUpInside, OBJC_ASSOCIATION_COPY);
    
    [self removeTarget:self action:@selector(onTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    
    if (xlp_touchUpInside) {
        [self addTarget:self action:@selector(onTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (XLPButtonUpInsideBlock)xlp_touchUpInside {
    XLPButtonUpInsideBlock upBlock = objc_getAssociatedObject(self, s_XLPButtonTouchUpKey);
    return upBlock;
}

- (void)setXlp_valueChangedBlock:(XLPValueChangedBlock)xlp_valueChangedBlock{
    objc_setAssociatedObject(self, s_XLPValueChangedKey, xlp_valueChangedBlock, OBJC_ASSOCIATION_COPY);
    
    [self removeTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    if (xlp_valueChangedBlock) {
        [self addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
}

- (XLPValueChangedBlock)xlp_valueChangedBlock {
    XLPValueChangedBlock block = objc_getAssociatedObject(self, s_XLPValueChangedKey);
    return block;
}

- (void)onValueChanged:(id)sender {
    XLPValueChangedBlock block = [self xlp_valueChangedBlock];
    
    if (block) {
        block(sender);
    }
}

- (void)onTouchUp:(UIButton *)sender {
    XLPButtonUpInsideBlock touchUp = [self xlp_touchUpInside];
    
    if (touchUp) {
        touchUp(sender);
    }
}

- (void)onTouchDown:(UIButton *)sender {
    XLPButtonDownBlock touchDown = [self xlp_touchDown];
    
    if (touchDown) {
        touchDown(sender);
    }
}
@end
