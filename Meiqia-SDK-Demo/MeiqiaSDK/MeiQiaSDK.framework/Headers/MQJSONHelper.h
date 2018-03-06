//
//  NSObject+JSON.h
//  MeiQiaSDK
//
//  Created by ian luo on 16/4/7.
//  Copyright © 2016年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQJSONHelper:NSObject

+ (NSString *)JSONStringWith:(id)obj;

+ (id)createWithJSONString:(NSString *)jsonString;

@end
