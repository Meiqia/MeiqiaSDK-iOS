//
//  MQPreChatData.h
//  MeiQiaSDK
//
//  Created by ian luo on 16/7/6.
//  Copyright © 2016年 MeiQia Inc. All rights reserved.
//

#import "MQModel.h"

@class MQPreChatMenu,MQPreChatMenuItem,MQPreChatForm,MQPreChatFormItem;

extern NSString *const kCaptchaToken;
extern NSString *const kCaptchaValue;

typedef NS_ENUM(NSUInteger, MQPreChatFormItemInputType) {
    MQPreChatFormItemInputTypeSingleSelection,
    MQPreChatFormItemInputTypeMultipleSelection,
    MQPreChatFormItemInputTypeSingleLineText,
    MQPreCHatFormItemInputTypeMultipleLineText,
    MQPreChatFormItemInputTypeCaptcha,
};

// 询前表单的总的数据模型 包括客服分配表单 和 顾客信息收集表单
@interface MQPreChatData : MQModel

@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSNumber *isUseCapcha;
@property (nonatomic, strong) NSNumber *hasSubmittedForm; //表单是否已经提交
@property (nonatomic, strong) MQPreChatMenu *menu;  //客服分配表单 模型
@property (nonatomic, strong) MQPreChatForm *form;  // 顾客信息收集表单 模型




@end

@interface MQPreChatMenu : MQModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) NSArray *menuItems;

@end

@interface MQPreChatMenuItem : MQModel

@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *targetKind;
@property (nonatomic, copy) NSString *target;

@end

//询前表单 第二个页面 收集顾客信息页的 数据模型
@interface MQPreChatForm : MQModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) NSArray *formItems;

@end

// 收集顾客信息页面  cell的数据模型
@interface MQPreChatFormItem : MQModel

@property (nonatomic, copy) NSString *displayName; //对应的section的header的名字
@property (nonatomic, copy) NSString *filedName;
@property (nonatomic, assign) MQPreChatFormItemInputType type; //cell的类型  单行 多行  单选 多选 等
@property (nonatomic, strong) NSNumber *isOptional; //可选项  必选项
@property (nonatomic, strong) NSArray *choices; //单选 多选时  选择的row的数组
@property (nonatomic, strong) NSNumber *isIgnoreReturnCustomer; // 回头客 是否可忽略 选项

@end
