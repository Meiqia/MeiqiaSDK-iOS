//
//  MQOnlineTests.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/11/28.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <MeiQiaSDK/MeiQiaSDK.h>

@interface MQOnlineTests: XCTestCase
@property (nonatomic, strong) NSString *appKey;
@end

@implementation MQOnlineTests

- (void)setUp {
    self.appKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppKey"];
}

- (void)tearDown {

}

- (void)testUserOnlineWithClientId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserOnlineWithClientId"];
    
    [MQManager initWithAppkey:self.appKey completion:^(NSString *clientId, NSError *error) {
       [MQManager setClientOnlineWithClientId:clientId success:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
           [expectation fulfill];
       } failure:nil receiveMessageDelegate:nil];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testUserOnlineWithCustomizedId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserOnlineWithCustomizedId"];
    
    [MQManager initWithAppkey:self.appKey completion:^(NSString *clientId, NSError *error) {
        [MQManager setClientOnlineWithCustomizedId:[[NSUUID UUID]UUIDString] success:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
            [expectation fulfill];
        } failure:nil receiveMessageDelegate:nil];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testUserOnlineWithCurrentId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserOnlineWithCurrentId"];
    
    [MQManager initWithAppkey:self.appKey completion:^(NSString *clientId, NSError *error) {
       [MQManager setCurrentClientOnlineWithSuccess:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
           [expectation fulfill];
       } failure:nil receiveMessageDelegate:nil];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
