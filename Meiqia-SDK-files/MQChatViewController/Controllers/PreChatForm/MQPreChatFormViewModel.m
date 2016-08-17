//
//  MQPreChatFormViewModel.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/7/6.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQPreChatFormViewModel.h"
#import "MQChatViewConfig.h"
#import <MeiqiaSDK/MeiqiaSDK.h>
#import "MQServiceToViewInterface.h"
#import "NSArray+MQFunctional.h"
#import "MQChatViewConfig.h"

@implementation MQPreChatFormViewModel

- (void)requestPreChatServeyDataIfNeed:(void(^)(MQPreChatData *data, NSError *error))block {
    __weak typeof(self) wself = self;
    [MQServiceToViewInterface requestPreChatServeyDataIfNeedCompletion:^(MQPreChatData *data, NSError *error) {
        __strong typeof (wself) sself = wself;
        sself.formData = [self filterFormData:data];
        
        if (data.isUseCapcha.boolValue) {
            MQPreChatFormItem *captchaItem = [MQPreChatFormItem new];
            captchaItem.type = MQPreChatFormItemInputTypeCaptcha;
            captchaItem.displayName = @"验证码";
            captchaItem.isOptional = @(NO);
            captchaItem.filedName = kCaptchaValue;
            data.form.formItems = [data.form.formItems arrayByAddingObject:captchaItem];
        }
        
        block(sself.formData, error);
    }];
}

- (MQPreChatData *)filterFormData:(MQPreChatData *)formData {
    
    if ([formData.menu.status isEqualToString:@"close"] && [formData.form.status isEqualToString:@"close"]) {
        return nil;
    } else {
        NSMutableArray *filteredMenuItens = [NSMutableArray new];
        NSString *groupId = [MQChatViewConfig sharedConfig].scheduledGroupId;
        NSString *agentId = [MQChatViewConfig sharedConfig].scheduledAgentId;
        
        [formData.menu.menuItems enumerateObjectsUsingBlock:^(MQPreChatMenuItem *menuItem, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *target = nil;
            if ([menuItem targetKind]) {
                if ([[menuItem target] isEqualToString:@"group"]) {
                    target = groupId;
                } else if ([[menuItem target] isEqualToString:@"agent"]) {
                    target = agentId;
                }
            }
            if (target) {
                if ([target isEqualToString:menuItem.target]) {
                    [filteredMenuItens addObject:menuItem];
                }
            } else {
                [filteredMenuItens addObject:menuItem];
            }
        }];
        formData.menu.menuItems = filteredMenuItens;
        
        if (formData.hasSubmittedForm.boolValue) {
            NSMutableArray *filteredFormItems = [NSMutableArray new];
            [formData.form.formItems enumerateObjectsUsingBlock:^(MQPreChatFormItem *formItem, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![formItem isIgnoreReturnCustomer].boolValue) {
                    [filteredFormItems addObject:formItem];
                }
            }];
            formData.form.formItems = filteredFormItems;
        }
    }
    
    return formData;
}

- (void)setValue:(id)value forFieldIndex:(NSInteger)fieldIndex {
    if (value) {
        [self.filledFieldValue setObject:value forKey:@(fieldIndex)];
    } else {
        [self.filledFieldValue removeObjectForKey:@(fieldIndex)];
    }
//    MQInfo(@"valued changed: %@", self.filledFieldValue);
}

- (UIKeyboardType)keyboardtypeForType:(NSString *)type {
    static dispatch_once_t onceToken;
    static NSDictionary *map;
    dispatch_once(&onceToken, ^{
        map = @{
                @"qq":@(UIKeyboardTypeNumberPad),
                @"weibo":@(UIKeyboardTypeDefault),
                @"age":@(UIKeyboardTypeNumberPad),
                @"email":@(UIKeyboardTypeEmailAddress),
                @"tel":@(UIKeyboardTypePhonePad),
                @"wechat":@(UIKeyboardTypeDefault),
                @"name":@(UIKeyboardTypeDefault),
                @"gender":@(-1),
                };
    });
    
    return (UIKeyboardType)[map[type] intValue];
}

- (NSMutableDictionary *)filledFieldValue {
    if (!_filledFieldValue) {
        _filledFieldValue = [NSMutableDictionary new];
    }
    return _filledFieldValue;
}

- (id)valueForFieldIndex:(NSInteger)fieldIndex {
//    NSString *filedName = [(MQPreChatFormItem *)self.formData.form.formItems[fieldIndex] filedName];
    return [self.filledFieldValue objectForKey:@(fieldIndex)];
}

- (void)requestCaptchaComplete:(void(^)(UIImage *image))block {
    if (block == nil) return;
    
    __weak typeof(self) wself = self;
    [MQServiceToViewInterface getCaptchaWithURLComplete:^(NSString *token, NSString *url) {
        if (url.length > 0) {
            [MQServiceToViewInterface downloadMediaWithUrlString:url progress:nil completion:^(NSData *mediaData, NSError *error) {
                UIImage *image = [UIImage imageWithData:mediaData];
                __strong typeof (wself) sself = wself;
                if (token) {
                    sself.captchaToken = token;
                }
                block(image);
            }];
        }
    }];
}

- (NSArray *)submitFormCompletion:(void(^)(id response, NSError *e))block {
    NSArray *unsatisfiedIndexs = [self auditInputs:self.filledFieldValue];
    
    if (unsatisfiedIndexs.count == 0) {
        //replace params key to server defined filed name
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        for (NSNumber *key in self.filledFieldValue.allKeys) {
            MQPreChatFormItem *item = self.formData.form.formItems[key.integerValue];
            params[item.filedName] = self.filledFieldValue[key];
        }
        
        params[kCaptchaToken] = self.captchaToken;
        
        [MQServiceToViewInterface submitPreChatForm:params completion:^(id r, NSError *e) {
            
            if (e.userInfo[@"com.alamofire.serialization.response.error.data"]) {
                NSData *data = e.userInfo[@"com.alamofire.serialization.response.error.data"];
                NSDictionary *info = [MQJSONHelper createWithJSONString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                if ([info isKindOfClass:[NSDictionary class]]) {
                    if (info[@"captcha_needed"]) {
                        e = [NSError errorWithDomain:info[@"message"] code:0 userInfo:nil];
                    }
                }
            }
            
            return block(r, e);
        }];
    } else {
        block(nil, [NSError errorWithDomain:@"请填写完整标记部分的内容" code:1 userInfo:nil]);
    }
    
    return unsatisfiedIndexs;
}

- (NSArray *)auditInputs:(NSDictionary *)inputs {
    NSMutableArray *unsatisfiedIndexs = [NSMutableArray new];
    
    int i = 0;
    for (MQPreChatFormItem *item in self.formData.form.formItems) {
        if (!item.isOptional.boolValue) {
            if (![self.filledFieldValue objectForKey:@(i)]) {
                [unsatisfiedIndexs addObject:@(i)];
            }
        }
        i ++;
    }
    
    return unsatisfiedIndexs;
}

@end
