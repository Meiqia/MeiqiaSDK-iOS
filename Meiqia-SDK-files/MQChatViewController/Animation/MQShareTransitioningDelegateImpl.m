//
//  MQShareTransitioningDelegateImpl.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/3/20.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQShareTransitioningDelegateImpl.h"
#import "MQAnimatorPush.h"

@implementation MQShareTransitioningDelegateImpl

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    MQAnimatorPush *animator = (MQAnimatorPush *)self.interactiveTransitioning;
    animator.isPresenting = YES;
    return animator;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    MQAnimatorPush *animator = (MQAnimatorPush *)self.interactiveTransitioning;
    animator.isPresenting = NO;
    return animator;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.interactive ? self.interactiveTransitioning : nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.interactive ? self.interactiveTransitioning : nil;
}

- (UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning> *)interactiveTransitioning {
    if (!_interactiveTransitioning) {
        _interactiveTransitioning = [MQAnimatorPush new];
    }
    return _interactiveTransitioning;
}

@end
