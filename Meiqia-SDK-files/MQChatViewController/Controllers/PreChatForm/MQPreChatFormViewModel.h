//
//  MQPreChatFormViewModel.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/7/6.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MeiqiaSDK/MeiqiaSDK.h>

@interface MQPreChatFormViewModel : NSObject

typedef void(^CompleteBlock)(NSDictionary *userInfo);

@property (nonatomic, strong) MQPreChatData *formData;
@property (nonatomic, copy) NSString *captchaToken;
@property (nonatomic, strong) NSMutableDictionary *filledFieldValueDic;

//xlp 本地询前表单 提交过
@property (nonatomic, assign) BOOL hasSubmittedFormLocalBool;

/**
 获取询前表单的数据，如果不需要显示，则返回 nil，需要则返回获取到的数据
 */
- (void)requestPreChatServeyDataIfNeed:(void(^)(MQPreChatData *data, NSError *error))block;

- (void)requestCaptchaComplete:(void(^)(UIImage *image))block;

- (NSArray *)submitFormCompletion:(void(^)(id response, NSError *e))block;

- (void)setValue:(id)value forFieldIndex:(NSInteger)fieldIndex;

- (id)valueForFieldIndex:(NSInteger)fieldIndex;

- (UIKeyboardType)keyboardtypeForType:(NSString *)type;

@end
