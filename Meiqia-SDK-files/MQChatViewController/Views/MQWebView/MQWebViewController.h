//
//  MQWebViewController.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/15.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQWebViewController : UIViewController

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *contentHTML;
@property (nonatomic, strong) UIWebView *webView;

@end
