//
//  MQEmbededWebView.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQEmbededWebView.h"
#import "UIView+MQLayout.h"

@interface MQEmbededWebView()<WKNavigationDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, assign) NSInteger requestCount;

@end

@implementation MQEmbededWebView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = false;
        self.navigationDelegate = self;
//        self.configuration.dataDetectorTypes = UIDataDetectorTypeNone;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.scrollEnabled = NO;
        self.clipsToBounds = YES;
//        self.configuration.dataDetectorTypes = UIDataDetectorTypeNone;
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
    NSString *htmlStr = [NSString stringWithFormat:@"<html><head><meta content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0\" name=\"viewport\"><style type=\"text/css\">img{display: inline-block;max-width: 100%%}</style></head><body>%@</body></html>",html];
    self.viewHeight = 0;
    [self loadHTMLString:htmlStr baseURL:nil];//xlp 修改
//    [self loadHTMLString:html baseURL:[[NSBundle mainBundle]bundleURL]];  //不能这样修改 否则导致富文本不显示

    self.loadComplete = block;
    self.requestCount = 0;
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURLRequest *request = navigationAction.request;
    if (request.URL.path || [request.URL.absoluteString rangeOfString:@"tel:"].location != NSNotFound) {
        if (self.tappedLink) {
            self.tappedLink(request.URL);
        }
    }
    if (request.URL.path.length == 0) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
    
    self.requestCount ++;
    [self addSubview:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
    [self.loadingIndicator align:(ViewAlignmentCenter) relativeToPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    self.requestCount --;
    
    if (self.requestCount == 0) {
        [self.loadingIndicator stopAnimating];
    }
    
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result,NSError * _Nullable error){
        CGFloat height = [result doubleValue];
        if (self.loadComplete) {
            self.loadComplete(height);
        }
    }];
    
//    CGFloat height = [[webView  evaluateJavaScript:@"document.body.scrollHeight"] floatValue];
//    CGFloat height = [webView sizeThatFits:CGSizeZero].height;
//
//    if (self.loadComplete) {
//        self.loadComplete(height);
//    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.requestCount --;
    
    if (self.requestCount == 0) {
        [self.loadingIndicator stopAnimating];
    }
    
//    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    CGFloat height = [webView sizeThatFits:CGSizeZero].height;

    if (self.loadComplete) {
        self.loadComplete(height);
    }
}
@end
