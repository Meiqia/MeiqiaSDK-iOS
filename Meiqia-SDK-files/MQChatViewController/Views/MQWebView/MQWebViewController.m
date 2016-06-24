//
//  MQWebViewController.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/15.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQWebViewController.h"
#import "MQAssetUtil.h"

@interface MQWebViewController()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) NSValue *backBarTitleOffset;

@end

@implementation MQWebViewController

- (void)viewDidLoad {
    self.webView = [UIWebView new];
    self.webView.delegate = self;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.webView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:@{@"webView":self.webView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:@{@"webView":self.webView}]];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[MQAssetUtil backArrow] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicator];
    
    self.backBarTitleOffset = [NSValue valueWithUIOffset:[[UIBarButtonItem appearance] backButtonTitlePositionAdjustmentForBarMetrics:(UIBarMetricsDefault)]];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -100) forBarMetrics:(UIBarMetricsDefault)];    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:[self.backBarTitleOffset UIOffsetValue] forBarMetrics:(UIBarMetricsDefault)];
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.indicator startAnimating];
    
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title.length > 0) {
        self.title = title;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    [self.indicator stopAnimating];
}



- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicator;
}
@end
