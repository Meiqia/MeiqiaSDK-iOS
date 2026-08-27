//
//  MQSceneTests.m
//  Meiqia-SDK-DemoTests
//

#import <XCTest/XCTest.h>

@interface MQSceneTests : XCTestCase
@end

@implementation MQSceneTests

- (void)testApplicationDeclaresSceneDelegateInInfoPlist {
    NSDictionary *plist = [NSBundle mainBundle].infoDictionary;
    NSDictionary *sceneManifest = plist[@"UIApplicationSceneManifest"];
    NSDictionary *sceneConfigurations = sceneManifest[@"UISceneConfigurations"];
    NSArray *applicationSessions = sceneConfigurations[@"UIWindowSceneSessionRoleApplication"];
    NSDictionary *firstConfiguration = applicationSessions.firstObject;

    XCTAssertEqualObjects(firstConfiguration[@"UISceneDelegateClassName"], @"SceneDelegate");
}

- (void)testSceneDelegateClassIsAvailable {
    Class sceneDelegateClass = NSClassFromString(@"SceneDelegate");

    XCTAssertNotNil(sceneDelegateClass);
    XCTAssertTrue([sceneDelegateClass conformsToProtocol:@protocol(UIWindowSceneDelegate)]);
}

@end
