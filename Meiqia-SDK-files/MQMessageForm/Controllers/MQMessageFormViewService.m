//
//  MQMessageFormViewService.m
//  MeiQiaSDK
//
//  Created by bingoogolapple on 16/5/9.
//  Copyright © 2016年 MeiQia Inc. All rights reserved.
//

#import "MQMessageFormViewService.h"
#import "MQServiceToViewInterface.h"

@implementation MQMessageFormViewService

+ (void)getMessageFormConfigComplete:(void (^)(MQEnterpriseConfig *config, NSError *))action {
    [MQServiceToViewInterface getMessageFormConfigComplete:action];
}

+ (void)submitMessageFormWithMessage:(NSString *)message images:(NSArray *)images clientInfo:(NSDictionary<NSString *,NSString *> *)clientInfo completion:(void (^)(BOOL, NSError *))completion {
    [MQServiceToViewInterface submitMessageFormWithMessage:message images:images clientInfo:clientInfo completion:completion];
}

@end
