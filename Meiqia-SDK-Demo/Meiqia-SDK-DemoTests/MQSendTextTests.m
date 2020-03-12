//
//  MQSendTextTests.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/11/28.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MeiQiaSDK/MeiqiaSDK.h>
#import <XCTest/XCTest.h>

@interface MQSendTextTests : XCTestCase
@property (nonatomic, strong) NSString *appKey;

@end

@implementation MQSendTextTests

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

- (void)testSendTextMessageBeforeOnline {
    XCTestExpectation *expectation = [self expectationWithDescription:@"sendTextMessageBeforeOnline"];
    
    [MQManager endCurrentConversationWithCompletion:^(BOOL success, NSError *error) {
        
        [MQManager sendTextMessageWithContent:@"testSendTextMessageBeforeOnline" completion:^(MQMessage *sendedMessage, NSError *error) {
            NSAssert(error == nil, [error description]);
            NSAssert([[[MQManager getCurrentAgent] agentId] length] != 0, @"分配客服失败");
            NSAssert([MQManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
            NSAssert([MQManager getCurrentState] == MQStateAllocatedAgent, @"状态设置错误");
            [expectation fulfill];
            [MQManager endCurrentConversationWithCompletion:nil];
        }];
    }];
    
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testSendTextMessageAfterOnline {
    XCTestExpectation *expectation = [self expectationWithDescription:@"sendTextMessageBeforeOnline"];
    
    [MQManager endCurrentConversationWithCompletion:^(BOOL success, NSError *error) {
        
        [MQManager setClientOnlineWithCustomizedId:[MQManager getCurrentClientId] success:^(MQClientOnlineResult result, MQAgent *agent, NSArray<MQMessage *> *messages) {
            [MQManager sendTextMessageWithContent:@"testSendTextMessageAfterOnline" completion:^(MQMessage *sendedMessage, NSError *error) {
                NSAssert(error == nil, [error localizedDescription]);
                NSAssert([MQManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
                NSAssert([MQManager getCurrentState] == MQStateAllocatedAgent, @"状态设置错误");
                [expectation fulfill];
                [MQManager endCurrentConversationWithCompletion:nil];
            }];
        } failure:nil receiveMessageDelegate:nil];
    }];
    
    
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testSendTextMessageWhenConversationFinishedRemote {
    XCTestExpectation *expectation = [self expectationWithDescription:@"sendTextMessageBeforeOnline"];
    
    [MQManager endCurrentConversationWithCompletion:^(BOOL success, NSError *error) {
    
        Class c = NSClassFromString(@"MQStateManager");
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL s = @selector(enterState:withValue:);
#pragma clang diagnostic pop
        NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:[c methodSignatureForSelector:s]];
        invoke.target = c;
        invoke.selector = s;
        NSUInteger v = 5;
        [invoke setArgument:&v atIndex:2];
        [invoke invoke];
        
        NSAssert([MQManager getCurrentState] == MQStateAllocatedAgent, @"测试条件错误，状态应该是 MQStateAllocatedAgent");
        
        [MQManager sendTextMessageWithContent:@"testSendTextMessageWhenConversationFinished" completion:^(MQMessage *sendedMessage, NSError *error) {
            NSAssert(error == nil, [error localizedDescription]);
            NSAssert([MQManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
            NSAssert([MQManager getCurrentState] == MQStateAllocatedAgent, @"状态设置错误");
            [expectation fulfill];
            [MQManager endCurrentConversationWithCompletion:nil];
        }];
        
    }];
    
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
    
}

@end
