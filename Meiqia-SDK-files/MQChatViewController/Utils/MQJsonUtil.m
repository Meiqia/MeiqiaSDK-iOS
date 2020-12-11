//
//  MQJsonUtil.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQJsonUtil.h"

@implementation MQJsonUtil

+ (NSString *)JSONStringWith:(id)obj {
    if (obj && obj != [NSNull null]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&error];
        if (error) {
            NSLog(@"fail to convert to json string:%@",error);
        }
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (id)createWithJSONString:(NSString *)jsonString {
    
    if (![jsonString isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    id ret = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"fail to init from json string: %@ \n ERROR:%@",jsonString, error);
    }
    return ret;
}

@end
