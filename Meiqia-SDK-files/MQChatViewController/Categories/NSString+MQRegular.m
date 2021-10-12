//
//  NSString+MQRegular.m
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/26.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "NSString+MQRegular.h"

@implementation NSString (MQRegular)

- (BOOL)mq_match:(NSString *)pattern
{
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *results = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    return results.count > 0;
}

- (BOOL)mq_isQQ
{
    return [self mq_match:@"^[1-9]\\d{4,10}$"];
}

- (BOOL)mq_isPhoneNumber
{
    return [self mq_match:@"^1[35789]\\d{9}$"];
}

- (BOOL)mq_isTelNumber
{
    return [self mq_match:@"^((0\\d{2,3}-\\d{7,8})|(1[345789]\\d{9}))$"];
}

- (NSString *)mq_textContent
{
    NSString *resultContent = self;
    resultContent = [resultContent stringByReplacingOccurrencesOfString:@"<[^>]+>\\s+(?=<)|<[^>]+>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange (0, resultContent.length)];
    return resultContent;
}


@end
