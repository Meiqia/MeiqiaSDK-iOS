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

@interface MQPreChatData : MQModel

@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSNumber *isUseCapcha;
@property (nonatomic, strong) NSNumber *hasSubmittedForm;
@property (nonatomic, strong) MQPreChatMenu *menu;
@property (nonatomic, strong) MQPreChatForm *form;

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

@interface MQPreChatForm : MQModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) NSArray *formItems;

@end

@interface MQPreChatFormItem : MQModel

@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *filedName;
@property (nonatomic, assign) MQPreChatFormItemInputType type;
@property (nonatomic, strong) NSNumber *isOptional;
@property (nonatomic, strong) NSArray *choices;
@property (nonatomic, strong) NSNumber *isIgnoreReturnCustomer;

@end