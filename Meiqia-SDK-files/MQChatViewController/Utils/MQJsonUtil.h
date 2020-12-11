//
//  MQJsonUtil.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MQJsonUtil : NSObject

+ (NSString *)JSONStringWith:(id)obj;

+ (id)createWithJSONString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
