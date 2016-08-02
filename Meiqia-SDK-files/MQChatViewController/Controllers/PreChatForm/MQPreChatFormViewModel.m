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
        
        if (data.isUseCapcha) {
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
    }
    
    return formData;
}

- (void)setValue:(id)value forFieldIndex:(NSInteger)fieldIndex {
    NSString *filedName = [(MQPreChatFormItem *)self.formData.form.formItems[fieldIndex] filedName];
    if (value) {
        [self.filledFieldValue setObject:value forKey:filedName];
    } else {
        [self.filledFieldValue removeObjectForKey:filedName];
    }
//    MQInfo(@"valued changed: %@", self.filledFieldValue);
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
    [MQServiceToViewInterface getCaptchaWithURLComplete:^(NSString *token, NSString *url) {
        if (url.length > 0) {
            [MQServiceToViewInterface downloadMediaWithUrlString:url progress:nil completion:^(NSData *mediaData, NSError *error) {
                UIImage *image = [UIImage imageWithData:mediaData];
                __strong typeof (wself) sself = wself;
                sself.captchaToken = token;
                if (token) {
                    [sself.filledFieldValue setObject:token forKey:kCaptchaToken];
                }
                block(image);
            }];
        }
    }];
}

- (NSArray *)submitFormCompletion:(void(^)(id response, NSError *e))block {
    NSArray *unsatisfiedIndexs = [self auditInputs:self.filledFieldValue];
    
    if (unsatisfiedIndexs.count == 0) {
        //do submition
        
        [MQServiceToViewInterface submitPreChatForm:self.filledFieldValue completion:^(id r, NSError *e) {
            
            if (e.userInfo[@"com.alamofire.serialization.response.error.data"]) {
                NSData *data = e.userInfo[@"com.alamofire.serialization.response.error.data"];
                NSDictionary *info = [MQJSONHelper createWithJSONString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                if ([info isKindOfClass:[NSDictionary class]]) {
                    if (info[@"captcha_needed"]) {
                        e = [NSError errorWithDomain:@"验证码错误" code:0 userInfo:nil];
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
