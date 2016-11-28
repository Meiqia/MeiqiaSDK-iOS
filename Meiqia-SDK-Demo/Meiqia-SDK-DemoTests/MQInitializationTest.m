//
//  MQInitializationTest.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/11/28.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <MeiQiaSDK/MeiQiaSDK.h>

@interface MQInitializationTest : XCTestCase
@property (nonatomic, strong) NSString *appKey;
@end


@implementation MQInitializationTest

- (void)setUp {
    self.appKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppKey"];
}

- (void)testInitAndGetClientId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testInitAndGetClientId"];
    
    [MQManager initWithAppkey:self.appKey completion:^(NSString *clientId, NSError *error) {
        if (error == nil && clientId.length > 0) {
            [expectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInitNewClient {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testInitNewClient"];
    
    [MQManager createClient:^(NSString *clientId, NSError *error) {
        if (error == nil && clientId.length > 0) {
            [expectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
