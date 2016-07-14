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

@implementation MQPreChatFormViewModel

- (void)requestPreChatServeyDataIfNeed:(void(^)(MQPreChatData *data, NSError *error))block {
    NSString *userDefinedClientId = [MQChatViewConfig sharedConfig].MQClientId;
    NSString *userDefinedCostomId = [MQChatViewConfig sharedConfig].customizedId;
    
    __weak typeof(self) wself = self;
    [MQServiceToViewInterface requestPreChatServeyDataIfNeedWithClientId:userDefinedClientId customizId:userDefinedCostomId action:^(MQPreChatData *data, NSError *error) {
        __strong typeof (wself) sself = wself;
        sself.formData = data;
        
        if (data.isUseCapcha) {
            MQPreChatFormItem *captchaItem = [MQPreChatFormItem new];
            captchaItem.type = MQPreChatFormItemInputTypeCaptcha;
            captchaItem.displayName = @"验证码";
            captchaItem.isOptional = @(NO);
            captchaItem.filedName = kCaptchaValue;
            data.form.formItems = [data.form.formItems arrayByAddingObject:captchaItem];
        }
        
        block(data, error);
    }];
}

- (void)setValue:(id)value forFieldIndex:(NSInteger)fieldIndex {
    NSString *filedName = [(MQPreChatFormItem *)self.formData.form.formItems[fieldIndex] filedName];
    if (value) {
        [self.filledFieldValue setObject:value forKey:filedName];
    } else {
        [self.filledFieldValue removeObjectForKey:filedName];
    }
    MQInfo(@"valued changed: %@", self.filledFieldValue);
}

- (NSMutableDictionary *)filledFieldValue {
    if (!_filledFieldValue) {
        _filledFieldValue = [NSMutableDictionary new];
    }
    return _filledFieldValue;
}

- (id)valueForFieldIndex:(NSInteger)fieldIndex {
    NSString *filedName = [(MQPreChatFormItem *)self.formData.form.formItems[fieldIndex] filedName];
    return [self.filledFieldValue objectForKey:filedName];
}

- (void)requestCaptchaComplete:(void(^)(UIImage *image))block {
    if (block == nil) return;
    
    __weak typeof(self) wself = self;
    [MQServiceToViewInterface getCaptchaComplete:^(NSString *token, UIImage *image) {
        __strong typeof (wself) sself = wself;
        sself.captchaToken = token;
        [self.filledFieldValue setObject:token forKey:kCaptchaToken];
        block(image);
    }];
}

- (NSArray *)submitFormCompletion:(void(^)(id response, NSError *e))block {
    NSArray *unsatisfiedIndexs = [self auditInputs:self.filledFieldValue];
    
    if (unsatisfiedIndexs.count == 0) {
        //do submition
        [MQServiceToViewInterface submitPreChatForm:self.filledFieldValue completion:^(id r, NSError *e) {
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
            NSString *filedName = [(MQPreChatFormItem *)self.formData.form.formItems[i] filedName];
            if (![self.filledFieldValue objectForKey:filedName]) {
                [unsatisfiedIndexs addObject:@(i)];
            }
        }
        i ++;
    }
    
    return unsatisfiedIndexs;
}

@end
