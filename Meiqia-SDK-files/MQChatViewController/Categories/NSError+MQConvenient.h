//
//  NSError+MQConvenient.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2017/1/19.
//  Copyright © 2017年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError(MQConvenient)

+ (NSError *)reason:(NSString *)reason;

+ (NSError *)reason:(NSString *)reason code:(NSInteger)code;

+ (NSError *)reason:(NSString *)reason code:(NSInteger) code domain:(NSString *)domain;

- (NSString *)reason;

- (NSString *)shortDescription;

@end
