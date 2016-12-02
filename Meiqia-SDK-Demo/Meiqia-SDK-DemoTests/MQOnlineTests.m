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

- (void)tearDown {

}

- (void)testEndConversasion {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserOnlineWithClientId"];
    
    [MQManager setClientOnlineWithClientId:[MQManager getCurrentClientId] success:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
        [MQManager endCurrentConversationWithCompletion:^(BOOL success, NSError *error) {
            NSAssert(success, @"结束对话失败");
            NSAssert(error == nil, [error localizedDescription]);
            NSAssert([MQManager getCurrentAgent].agentId.length == 0, @"客服设置错误");
            NSAssert([MQManager getCurrentState] == MQStateUnallocatedAgent, @"状态设置错误");
            [expectation fulfill];
        }];
    } failure:^(NSError *error) {
        NSAssert(error == nil, [error localizedDescription]);
        [expectation fulfill];
    } receiveMessageDelegate:nil];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testUserOnlineWithClientId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserOnlineWithClientId"];
    NSString *clientId = [MQManager getCurrentClientId];
    [MQManager setClientOnlineWithClientId:clientId success:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
        NSAssert(agent.agentId.length != 0, @"分配客服失败");
        NSAssert([MQManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
        NSAssert([MQManager getCurrentState] == MQStateAllocatedAgent, @"状态设置错误");
        NSAssert([[MQManager getCurrentClientId] isEqualToString:clientId], @"用户 id 错误");
        [expectation fulfill];
        [MQManager endCurrentConversationWithCompletion:nil];
    } failure:^(NSError *error) {
        NSAssert(error == nil, [error description]);
        [expectation fulfill];
    } receiveMessageDelegate:nil];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testUserOnlineWithCustomizedId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserOnlineWithCustomizedId"];
    
    NSString *customizedId = [[NSUUID UUID]UUIDString];
    [MQManager setClientOnlineWithCustomizedId:customizedId success:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
        NSAssert(agent.agentId.length != 0, @"分配客服失败");
        NSAssert([MQManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
        NSAssert([MQManager getCurrentState] == MQStateAllocatedAgent, @"状态设置错误");
        NSAssert([[MQManager getCurrentCustomizedId] isEqualToString:customizedId], @"自定义用户 id 错误");
        [expectation fulfill];
        [MQManager endCurrentConversationWithCompletion:nil];
    } failure:^(NSError *error) {
        NSAssert(error == nil, [error description]);
        [expectation fulfill];
    } receiveMessageDelegate:nil];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testUserOnlineWithCurrentId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserOnlineWithCurrentId"];
    
    [MQManager setCurrentClientOnlineWithSuccess:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
        NSAssert(agent.agentId.length != 0, @"分配客服失败");
        NSAssert([MQManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
        NSAssert([MQManager getCurrentState] == MQStateAllocatedAgent, @"状态设置错误");
        [expectation fulfill];
        [MQManager endCurrentConversationWithCompletion:nil];
    } failure:^(NSError *error) {
        NSAssert(error == nil, [error description]);
        [expectation fulfill];
    } receiveMessageDelegate:nil];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
