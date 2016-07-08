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
            data.form.formItems = [data.form.formItems arrayByAddingObject:captchaItem];
        }
        
        block(data, error);
    }];
}

- (void)setValue:(id)value forFieldIndex:(NSInteger)fieldIndex {
    if (value) {
        [self.filledFieldValue setObject:value forKey:@(fieldIndex)];
    } else {
        [self.filledFieldValue removeObjectForKey:@(fieldIndex)];
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
    return [self.filledFieldValue objectForKey:@(fieldIndex)];
}

- (void)requestCaptchaComplete:(void(^)(UIImage *image))block {
    if (block == nil) return;
    
    [MQServiceToViewInterface getCaptchaComplete:^(NSString *token, UIImage *image) {
        self.captchaToken = token;
        
        block(image);
    }];
}

- (NSArray *)submitForm {
    NSArray *unsatisfiedInputs = [self audioInputs:self.filledFieldValue];
    
    if (unsatisfiedInputs.count == 0) {
        //do submition
    }
    
    return unsatisfiedInputs;
}

- (NSArray *)audioInputs:(NSDictionary *)inputs {
    NSMutableArray *unsatifiledFileds = [NSMutableArray new];
    
    int i = 0;
    for (MQPreChatFormItem *item in self.formData.form.formItems) {
        if (!item.isOptional.boolValue) {
            if (![self.filledFieldValue objectForKey:@(i)]) {
                [unsatifiledFileds addObject:@(i)];
            }
        }
        i ++;
    }
    
    return unsatifiledFileds;
}

@end
