//
//  NSError+MQConvenient.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2017/1/19.
//  Copyright © 2017年 Meiqia. All rights reserved.
//

#import "NSError+MQConvenient.h"

@implementation NSError(MQConvenient)

+ (NSError *)reason:(NSString *)reason {
    NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey : reason}];
    return error;
}

+ (NSError *)reason:(NSString *)reason code:(NSInteger)code {
    NSError *error = [NSError errorWithDomain:@"" code:code userInfo:@{NSLocalizedFailureReasonErrorKey : reason}];
    return error;
}

+ (NSError *)reason:(NSString *)reason code:(NSInteger) code domain:(NSString *)domain {
    NSError *error = [NSError errorWithDomain:domain code:0 userInfo:@{NSLocalizedFailureReasonErrorKey : reason}];
    return error;
}

- (NSString *)reason {
    id reason = [self.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    if ([reason isKindOfClass:NSString.class]) {
        return (NSString *)reason;
    } else {
        return @"";
    }
}

- (NSString *)shortDescription {
    return [NSString stringWithFormat:@"%@ (%d)", [self reason], (int)self.code];
}

@end
