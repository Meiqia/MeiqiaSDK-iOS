//
//  NSString+MQRegular.m
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/26.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "NSString+MQRegular.h"

@implementation NSString (MQRegular)

- (BOOL)match:(NSString *)pattern
{
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *results = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    return results.count > 0;
}

- (BOOL)isQQ
{
    return [self match:@"^[1-9]\\d{4,10}$"];
}

- (BOOL)isPhoneNumber
{
    return [self match:@"^1[35789]\\d{9}$"];
}

- (BOOL)isTelNumber
{
    return [self match:@"^((0\\d{2,3}-\\d{7,8})|(1[345789]\\d{9}))$"];
}

@end
