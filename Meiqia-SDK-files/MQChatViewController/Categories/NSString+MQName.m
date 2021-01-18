//
//  NSString+MQName.m
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/29.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "NSString+MQName.h"

@implementation NSString (MQName)

- (NSString *)resetName{
    if (!self) {
        return @"";
    }
    if ([self isEqualToString:@"name"] || [self isEqualToString:@"姓名"]) {
        return @"name";
    }else if ([self isEqualToString:@"contact"] || [self isEqualToString:@"联系人"]) {
        return @"contact";
    }else if ([self isEqualToString:@"gender"] || [self isEqualToString:@"性别"]) {
        return @"gender";
    }else if ([self isEqualToString:@"qq"] || [self isEqualToString:@"QQ"]) {
        return @"qq";
    }else if ([self isEqualToString:@"tel"] || [self isEqualToString:@"电话"]) {
        return @"tel";
    }else if ([self isEqualToString:@"weibo"] || [self isEqualToString:@"微博"]) {
        return @"weibo";
    }else if ([self isEqualToString:@"weixin"] || [self isEqualToString:@"微信"]) {
        return @"weixin";
    }else if ([self isEqualToString:@"email"] || [self isEqualToString:@"邮箱"]) {
        return @"email";
    }else if ([self isEqualToString:@"address"] || [self isEqualToString:@"地址"]) {
        return @"address";
    }else if ([self isEqualToString:@"age"] || [self isEqualToString:@"年龄"]) {
        return @"age";
    }else if ([self isEqualToString:@"comment"] || [self isEqualToString:@"备注"]) {
        return @"comment";
    }else {
        return @"";
    }
}


@end
