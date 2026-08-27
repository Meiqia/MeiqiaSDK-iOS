//
//  SceneDelegate.m
//  Meiqia-SDK-Demo
//

#import "SceneDelegate.h"
#import <MeiQiaSDK/MQManager.h>

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions API_AVAILABLE(ios(13.0)) {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }

    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    window.rootViewController = [storyboard instantiateInitialViewController];
    [window makeKeyAndVisible];
    self.window = window;
}

- (void)sceneWillEnterForeground:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    [MQManager openMeiqiaService];
}

- (void)sceneDidEnterBackground:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    [MQManager closeMeiqiaService];
}

@end
