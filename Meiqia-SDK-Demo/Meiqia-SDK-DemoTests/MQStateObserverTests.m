//
//  MQStateObserverTests.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/11/29.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MeiQiaSDK/MeiQiaSDK.h>
#import <XCTest/XCTest.h>

@interface MQStateObserverTests : XCTestCase

@property (nonatomic, strong) NSString *appKey;

@end

@implementation MQStateObserverTests

- (void)setUp {
    self.appKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppKey"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    __block BOOL waitingForInitComplete = YES;
    BOOL isInitInTheAir = NO;
    do {
        if (!isInitInTheAir) {
            isInitInTheAir = YES;
            [MQManager initWithAppkey:self.appKey completion:^(NSString *clientId, NSError *error) {
                NSAssert(error == nil, @"[error localizedDescription]");
                NSAssert([clientId length] != 0, @"分配顾客 id 失败");
                waitingForInitComplete = NO;
            }];
        }
    } while (waitingForInitComplete);
}

- (void)testStateObserverSetValue {
    NSString *key = @"test";
    
    [MQManager addStateObserverWithBlock:^(MQState oldState, MQState newState, NSDictionary *value, NSError *error) {
        NSAssert(newState == MQStateQueueing, @"get new state fail");
        NSAssert([value[@"1"] isEqualToString:@"1"], @"get value fail");
        [MQManager removeStateChangeObserverWithKey:key];
    } withKey:key];
    
    [self changeStateTo:MQStateQueueing object:@{@"1":@"1"} error:nil];
}

- (void)testStateObserverSetError {
    NSString *key = @"test";
    
    [MQManager addStateObserverWithBlock:^(MQState oldState, MQState newState, NSDictionary *value, NSError *error) {
        NSAssert(newState == MQStateOffline, @"get new state fail");
        NSAssert([[error domain] isEqualToString:@"offline"], @"get error fail");
        [MQManager removeStateChangeObserverWithKey:key];
    } withKey:key];
    
    [self changeStateTo:MQStateOffline object:nil error:[NSError errorWithDomain:@"offline" code:0 userInfo:nil]];
}

- (void)changeStateTo:(MQState)state object:(id)obj error:(NSError *)error {
    SEL s;
    id o;
    Class c = NSClassFromString(@"MQStateManager");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (error) {
        s = @selector(enterState:withError:);
        o = error;
    } else {
        s = @selector(enterState:withValue:);
        o = obj;
    }
    
#pragma clang diagnostic pop
    NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:[c methodSignatureForSelector:s]];
    invoke.target = c;
    invoke.selector = s;
    NSUInteger v = state;
    [invoke setArgument:&v atIndex:2];
    if (o) {
        [invoke setArgument:&o atIndex:3];
    }
    [invoke invoke];
}

@end
