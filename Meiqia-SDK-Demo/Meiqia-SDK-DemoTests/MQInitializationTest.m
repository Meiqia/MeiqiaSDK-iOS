//
//  MQInitializationTest.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/11/28.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <MeiQiaSDK/MeiqiaSDK.h>

@interface MQInitializationTest : XCTestCase
@property (nonatomic, strong) NSString *appKey;
@end


@implementation MQInitializationTest

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

- (void)testInitAndGetClientId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testInitAndGetClientId"];
    
    [MQManager initWithAppkey:self.appKey completion:^(NSString *clientId, NSError *error) {
        NSAssert(error == nil, [error localizedDescription]);
        NSAssert(clientId.length > 0, @"分配顾客 id 失败");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testInitNewClient {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testInitNewClient"];
    
    [MQManager createClient:^(NSString *clientId, NSError *error) {
        NSAssert(error == nil, [error localizedDescription]);
        NSAssert(clientId.length > 0, @"分配顾客 id 失败");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

@end
