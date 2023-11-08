//
//  MQEmbededWebView.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQEmbededWebView.h"
#import "UIView+MQLayout.h"
#import "MQImageViewerViewController.h"
#import "UIViewController+MQHieriachy.h"

@interface MQEmbededWebView()<WKNavigationDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, assign) NSInteger requestCount;

@property (nonatomic, strong) NSMutableArray *allUrlArray;
@property (nonatomic, strong) NSMutableArray *finalImagesUrl;

@property (nonatomic, strong) NSString *requestURLString;

@end

@implementation MQEmbededWebView

- (instancetype)init {
    if (self = [super init]) {
        self.allUrlArray = [NSMutableArray array];
        self.finalImagesUrl = [NSMutableArray array];
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
    self.requestURLString = htmlStr;
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
    
    NSString *requestString = navigationAction.request.URL.absoluteString;
    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
        // 创建视图并显示图片
        [self showBigImage:imageUrl];
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
    
    static  NSString * const jsGetImages =
        @"function getImages(){\
        var objs = document.getElementsByTagName(\"img\");\
        var imgScr = '';\
        for(var i=0;i<objs.length;i++){\
        imgScr = imgScr + objs[i].src +'MQindex'+ i +'M+Q';\
        (function(arg){\
        objs[arg].onclick=function(){\
        document.location=\"myweb:imageClick:\"+this.src + 'MQindex' + arg;\
        };\
        })(i); \
        };\
        return imgScr;\
        };";

    [webView evaluateJavaScript:jsGetImages completionHandler:^(id _Nullable result, NSError * _Nullable error) {
    }];
    [webView evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (!error && [result isKindOfClass:[NSString class]]) {
            NSString *urlResurlt = result;
            self.allUrlArray = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"M+Q"]];
            if (self.allUrlArray.count >= 2) {
                [self.allUrlArray removeLastObject];// 此时数组为每一个图片的url
            }
            
            // 最后的图片数组
            [self getFinalImagesUrls];
        }
    }];
}

#pragma mark - 获取最后所有图片
- (void)getFinalImagesUrls {
    // 分解出所有图片的链接地址
    [self.finalImagesUrl removeAllObjects];
    for (int i = 0; i < self.allUrlArray.count; i++) {
        NSArray *imageIndex = [NSMutableArray arrayWithArray:[self.allUrlArray[i] componentsSeparatedByString:@"MQindex"]];
        NSString *imgStr = imageIndex.firstObject;
        // 这里出现了一个问题就是拿到的所有的图片有一个链接是web本身页面的地址 不知道怎么产生的 在这里判断下去掉
        if (![imgStr isEqualToString:self.requestURLString]) {
            [self.finalImagesUrl addObject:imgStr];
        }
    }
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

#pragma mark 显示大图片
- (void)showBigImage:(NSString *)imageUrl {
    
    NSArray *imageIndex = [NSMutableArray arrayWithArray:[imageUrl componentsSeparatedByString:@"MQindex"]];
    NSString *indexStr = imageIndex.lastObject;
    
    MQImageViewerViewController *viewerVC = [MQImageViewerViewController new];
    viewerVC.imagePaths = self.finalImagesUrl;
    viewerVC.currentIndex = indexStr.integerValue;
    __weak MQImageViewerViewController *wViewerVC = viewerVC;
    [viewerVC setSelection:^(NSUInteger index) {
        __strong MQImageViewerViewController *sViewerVC = wViewerVC;
        [sViewerVC dismiss];
    }];
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [viewerVC showOn:[UIViewController mq_topMostViewController] fromRectArray:[NSArray arrayWithObject:[NSValue valueWithCGRect:[self convertRect:self.frame toView:[UIApplication sharedApplication].keyWindow]]]];
}
@end
