//
//  MQTransitioningAnimation.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/3/20.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQTransitioningAnimation.h"

@interface MQTransitioningAnimation()

@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegateImpl;

@end


@implementation MQTransitioningAnimation

+ (instancetype)sharedInstance {
    static MQTransitioningAnimation *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MQTransitioningAnimation new];
    });
    
    return instance;
}

- (instancetype)init {

    if (self = [super init]) {
        self.transitioningDelegateImpl = [MQShareTransitioningDelegateImpl new];
    }
    return self;
}

+ (id <UIViewControllerTransitioningDelegate>)transitioningDelegateImpl {
    return [[self sharedInstance] transitioningDelegateImpl];
}

+ (CATransition *)createPresentingTransiteAnimation:(MQTransiteAnimationType)animation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    [transition setFillMode:kCAFillModeBoth];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    switch (animation) {
        case MQTransiteAnimationTypePush:
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromRight;
            break;
        case MQTransiteAnimationTypeDefault:
        default:
            break;
    }
    return transition;
}
+ (CATransition *)createDismissingTransiteAnimation:(MQTransiteAnimationType)animation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    [transition setFillMode:kCAFillModeBoth];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    switch (animation) {
        case MQTransiteAnimationTypePush:
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromLeft;
            break;
        case MQTransiteAnimationTypeDefault:
        default:
            break;
    }
    return transition;
}


@end
