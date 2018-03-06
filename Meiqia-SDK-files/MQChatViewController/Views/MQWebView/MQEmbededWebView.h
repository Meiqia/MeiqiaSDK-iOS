//
//  MQEmbededWebView.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQEmbededWebView : UIWebView

@property (nonatomic, copy)void(^loadComplete)(CGFloat);
@property (nonatomic, copy)void(^tappedLink)(NSURL *);

- (void)loadHTML:(NSString *)html WithCompletion:(void(^)(CGFloat))block;

@end
