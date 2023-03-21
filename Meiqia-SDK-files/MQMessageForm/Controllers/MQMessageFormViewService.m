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
    [MQServiceToViewInterface getEnterpriseConfigInfoWithCache:NO complete:^(MQEnterprise *enterprise, NSError *error) {
        if (enterprise && enterprise.configInfo) {
            action(enterprise.configInfo, nil);
        } else {
            action(nil, error);
        }
    }];
}

+ (void)submitMessageFormWithMessage:(NSString *)message clientInfo:(NSDictionary<NSString *,NSString *> *)clientInfo completion:(void (^)(BOOL, NSError *))completion {
    [MQServiceToViewInterface submitMessageFormWithMessage:message clientInfo:clientInfo completion:completion];
}

@end
