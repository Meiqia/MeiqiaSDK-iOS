//
//  NSNull+Safe.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/5/31.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "NSNull+MQSafe.h"
#import <objc/runtime.h>

@implementation NSNull(MQSafe)

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    anInvocation.target = nil;
    [anInvocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if (!sig) {
        sig = [NSMethodSignature signatureWithObjCTypes:"^v^c"];
    }
    
    return sig;
}

@end
