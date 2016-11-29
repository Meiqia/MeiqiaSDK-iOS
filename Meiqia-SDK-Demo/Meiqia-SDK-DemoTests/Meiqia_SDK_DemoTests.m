//
//  Meiqia_SDK_DemoTests.m
//  Meiqia-SDK-DemoTests
//
//  Created by ijinmao on 15/12/9.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MeiQiaSDK/MeiQiaSDK.h>

@interface Meiqia_SDK_DemoTests : XCTestCase
@property (nonatomic, strong) NSString *appKey;

@end

@implementation Meiqia_SDK_DemoTests

- (void)setUp {
    [super setUp];
    self.appKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppKey"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    __block BOOL waitingForInitComplete = YES;
    BOOL isInitInTheAir = NO;
    do {
        if (!isInitInTheAir) {
            isInitInTheAir = YES;
            [MQManager initWithAppkey:self.appKey completion:^(NSString *clientId, NSError *error) {
                waitingForInitComplete = NO;
            }];
        }
    } while (waitingForInitComplete);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test111Example {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
