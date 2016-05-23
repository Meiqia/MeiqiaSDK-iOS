//
//  MCKeyboardController.m
//  Meiqia
//
//  Created by Injoy on 16/4/15.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import "MCKeyboardController.h"

static void * kMCKeyboardControllerKeyValueObservingContext = &kMCKeyboardControllerKeyValueObservingContext;

@interface MCKeyboardController () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) BOOL isObserving;

@property (weak, nonatomic) UIView *keyboardView;

@end

@implementation MCKeyboardController

- (instancetype)initWithResponders:(NSArray *)responders
                       contextView:(UIView *)contextView
              panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
                          delegate:(id<MCKeyboardControllerDelegate>)delegate
{
    NSParameterAssert(responders != nil);
    NSParameterAssert(contextView != nil);
    NSParameterAssert(panGestureRecognizer != nil);
    for (NSObject *responder in responders) {
         NSParameterAssert([responder isKindOfClass:UIView.class]);
    }
    
    if (self = [self init]) {
        _responders = responders;
        _contextView = contextView;
        _panGestureRecognizer = panGestureRecognizer;
        _delegate = delegate;
        _keyboardStatus = MCKeyboardStatusHide;
    }
    return self;
}

- (void)dealloc
{
    [self removeKeyboardFrameObserver];
    [self unregisterForNotifications];
    _panGestureRecognizer = nil;
    _delegate = nil;
}

#pragma mark - Setters

- (void)setKeyboardView:(UIView *)keyboardView
{
    if (_keyboardView) {
        [self removeKeyboardFrameObserver];
    }
    
    _keyboardView = keyboardView;
    
    if (keyboardView && !_isObserving) {
        [_keyboardView addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(frame))
                           options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                           context:kMCKeyboardControllerKeyValueObservingContext];
        
        _isObserving = YES;
    }
}


- (void)beginListeningForKeyboard
{
    for (UIView *responder in self.responders) {
        if (responder.inputAccessoryView == nil) {
            if ([responder respondsToSelector:@selector(setInputAccessoryView:)]) {
                [responder performSelector:@selector(setInputAccessoryView:) withObject:[[UIView alloc] init]];
            }
        }
    }

    [self registerForNotifications];
}

- (void)endListeningForKeyboard
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setKeyboardViewHidden:NO];
    self.keyboardView = nil;
}

- (void)registerForNotifications
{
    [self unregisterForNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardDidShowNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardWillChangeFrameNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardDidChangeFrameNotification:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardDidHideNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveKeyboardWillShowNotification:(NSNotification *)notification
{
    for (UIView* responder in self.responders) {
        if ([responder isFirstResponder]) {
            _currentResponder = responder;
            break;
        }
    }
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        for(UIWindow* window in [[UIApplication sharedApplication] windows])
            if([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")])
                for(UIView* subView in window.subviews)
                    if([subView isKindOfClass:NSClassFromString(@"UIInputSetHostView")])
                        for(UIView* subsubView in subView.subviews)
                            if([subsubView isKindOfClass:NSClassFromString(@"UIInputSetHostView")])
                                self.keyboardView = subsubView;
    } else {
        self.keyboardView = self.currentResponder.inputAccessoryView.superview;
    }
    
    self.keyboardStatus = MCKeyboardStatusWillShow;
    [self setKeyboardViewHidden:NO];
    
    [self handleKeyboardNotification:notification completion:^(BOOL finished) {
        [self.panGestureRecognizer addTarget:self action:@selector(handlePanGestureRecognizer:)];
    }];
}

- (void)didReceiveKeyboardDidShowNotification:(NSNotification *)notification
{
    self.keyboardStatus = MCKeyboardStatusShowing;
    [self handleKeyboardNotification:notification completion:nil];
}

- (void)didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification
{
    if (self.keyboardStatus == MCKeyboardStatusHide) {
        self.keyboardStatus = MCKeyboardStatusWillShow;
    }
    [self handleKeyboardNotification:notification completion:nil];
}

- (void)didReceiveKeyboardDidChangeFrameNotification:(NSNotification *)notification
{
    self.keyboardStatus = MCKeyboardStatusShowing;
    [self setKeyboardViewHidden:NO];
    
    [self handleKeyboardNotification:notification completion:nil];
}

- (void)didReceiveKeyboardWillHideNotification:(NSNotification *)notification
{
    self.keyboardStatus = MCKeyboardStatusWillHide;
}

- (void)didReceiveKeyboardDidHideNotification:(NSNotification *)notification
{
    self.keyboardStatus = MCKeyboardStatusHide;
    self.keyboardView = nil;
    _currentResponder = nil;
    
    [self handleKeyboardNotification:notification completion:^(BOOL finished) {
        [self.panGestureRecognizer removeTarget:self action:NULL];
    }];
}

- (void)handleKeyboardNotification:(NSNotification *)notification completion:(void (^)(BOOL finished))completion
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardEndFrameConverted = [self.contextView convertRect:keyboardEndFrame fromView:nil];

    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         [self notifyKeyboardFrameNotificationForFrame:keyboardEndFrameConverted isImpressionOfGesture:NO];
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

#pragma mark - Utilities

- (void)setKeyboardViewHidden:(BOOL)hidden
{
    self.keyboardView.hidden = hidden;
    self.keyboardView.userInteractionEnabled = !hidden;
}

- (void)notifyKeyboardFrameNotificationForFrame:(CGRect)frame isImpressionOfGesture:(BOOL)isImpressionOfGesture
{
    [self.delegate keyboardController:self keyboardChangeFrame:frame isImpressionOfGesture:isImpressionOfGesture];
}

- (void)resetKeyboardAndTextView
{
    [self setKeyboardViewHidden:YES];
    [self removeKeyboardFrameObserver];
    [self.currentResponder resignFirstResponder];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kMCKeyboardControllerKeyValueObservingContext) {
        
        if (object == self.keyboardView && [keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {
            
            CGRect oldKeyboardFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
            CGRect newKeyboardFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            
            if (CGRectEqualToRect(newKeyboardFrame, oldKeyboardFrame) || CGRectIsNull(newKeyboardFrame)) {
                return;
            }
            
            CGRect keyboardEndFrameConverted = [self.contextView convertRect:newKeyboardFrame
                                                                    fromView:self.keyboardView.superview];
            [self notifyKeyboardFrameNotificationForFrame:keyboardEndFrameConverted isImpressionOfGesture:YES];
        }
    }
}

- (void)removeKeyboardFrameObserver
{
    if (!_isObserving) {
        return;
    }
    
    @try {
        [_keyboardView removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(frame))
                              context:kMCKeyboardControllerKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
    
    _isObserving = NO;
}

#pragma mark - Pan gesture recognizer

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan
{
    CGPoint touch = [pan locationInView:self.contextView.window];

    CGFloat contextViewWindowHeight = CGRectGetHeight(self.contextView.window.frame);
    
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
        // iOS7 当旋转时的bug
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            contextViewWindowHeight = CGRectGetWidth(self.contextView.window.frame);
        }
    }
    
    CGFloat keyboardViewHeight = CGRectGetHeight(self.keyboardView.frame);
    
    CGFloat dragThresholdY = (contextViewWindowHeight - keyboardViewHeight - self.keyboardTriggerPoint.y);
    
    CGRect newKeyboardViewFrame = self.keyboardView.frame;
    
    BOOL userIsDraggingNearThresholdForDismissing = (touch.y > dragThresholdY);
    
    self.keyboardView.userInteractionEnabled = !userIsDraggingNearThresholdForDismissing;
    
    switch (pan.state) {
        case UIGestureRecognizerStateChanged:
        {
            newKeyboardViewFrame.origin.y = touch.y + self.keyboardTriggerPoint.y;
            
            //bound frame between bottom of view and height of keyboard
            newKeyboardViewFrame.origin.y = MIN(newKeyboardViewFrame.origin.y, contextViewWindowHeight);
            newKeyboardViewFrame.origin.y = MAX(newKeyboardViewFrame.origin.y, contextViewWindowHeight - keyboardViewHeight);
            
            if (CGRectGetMinY(newKeyboardViewFrame) == CGRectGetMinY(self.keyboardView.frame)) {
                return;
            }
            
            [UIView animateWithDuration:0.0
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone
                             animations:^{
                                 self.keyboardView.frame = newKeyboardViewFrame;
                             }
                             completion:nil];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            BOOL keyboardViewIsHidden = (CGRectGetMinY(self.keyboardView.frame) >= contextViewWindowHeight);
            if (keyboardViewIsHidden) {
                [self resetKeyboardAndTextView];
                return;
            }
            
            CGPoint velocity = [pan velocityInView:self.contextView];
            BOOL userIsScrollingDown = (velocity.y > 0.0f);
            BOOL shouldHide = (userIsScrollingDown && userIsDraggingNearThresholdForDismissing);
            
            newKeyboardViewFrame.origin.y = shouldHide ? contextViewWindowHeight : (contextViewWindowHeight - keyboardViewHeight);
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut
                             animations:^{
                                 self.keyboardView.frame = newKeyboardViewFrame;
                             }
                             completion:^(BOOL finished) {
                                 self.keyboardView.userInteractionEnabled = !shouldHide;
                                 
                                 if (shouldHide) {
                                     [self resetKeyboardAndTextView];
                                 }
                             }];
        }
            break;
            
        default:
            break;
    }
}

@end
