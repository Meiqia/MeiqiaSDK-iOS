//
//  MQEmbededWebView.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQEmbededWebView.h"
#import "UIView+MQLayout.h"

@interface MQEmbededWebView()<UIWebViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, assign) NSInteger requestCount;

@end

@implementation MQEmbededWebView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = false;
        self.delegate = self;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.scrollEnabled = NO;
        self.clipsToBounds = YES;
        self.dataDetectorTypes = UIDataDetectorTypeNone;
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    }
    return self;
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)loadHTML:(NSString *)html WithCompletion:(void(^)(CGFloat))block {
    self.viewHeight = 60;
    [self loadHTMLString:html baseURL:nil];
    self.loadComplete = block;
    self.requestCount = 0;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (request.URL.path) {
        if (self.tappedLink) {
            self.tappedLink(request.URL);
        }
    }
    
    return request.URL.path.length == 0;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.requestCount ++;
    [self addSubview:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
    [self.loadingIndicator align:(ViewAlignmentCenter) relativeToPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.requestCount --;
    
    
    if (self.requestCount == 0) {
        [self.loadingIndicator stopAnimating];
        CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
        if (self.loadComplete) {
            self.loadComplete(height);
        }
    }
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.requestCount --;
    
    
    if (self.requestCount == 0) {
        [self.loadingIndicator stopAnimating];
        CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
        if (self.loadComplete) {
            self.loadComplete(height);
        }
    }
}
@end
