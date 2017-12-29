//
//  MQBotWebViewController.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/9.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQBotWebViewController.h"
#import "MQBotRichTextMessage.h"
#import "UIView+MQLayout.h"
#import "UIImage+MQGenerate.h"

#define HeightButtonView 60
#define WidthSepLine 1
#define ColorBackground [UIColor whiteColor]
#define ColorText [UIColor colorWithRed:22/255.0 green:199/255.0 blue:209/255.0 alpha:1]
#define ColorLine [UIColor colorWithRed:242/255.0 green:242/255.0 blue:247/255.0 alpha:1]
#define WidthEvaluateButton self.view.viewWidth / 2 - 1

@interface MQBotWebViewController()

@property (nonatomic, strong) UIView *evaluateButtons;
@property (nonatomic, strong) UIView *evaluatedIndicatorView;

@end

@implementation MQBotWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.message.questionId.integerValue > 0) {
        UIEdgeInsets inescts = self.webView.scrollView.contentInset;
        [self.webView.scrollView setContentInset:UIEdgeInsetsMake(inescts.top, inescts.left, HeightButtonView, inescts.right)];
        
        UIView *view;
        if (!self.message.isEvaluated) {
            view = [self createEvaluateView];
        } else {
            view = [self createEvaluatedView];
        }
        
        [view align:(ViewAlignmentBottomLeft) relativeToPoint:self.view.leftBottomCorner];
        [self.view addSubview:view];
    }
}

- (UIView *)createEvaluateView {
    UIView * containerView = [UIView new];
    containerView.backgroundColor = ColorLine;
    containerView.viewSize = CGSizeMake(self.view.viewWidth, HeightButtonView);
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIButton *usefullButton = [UIButton new];
    [usefullButton setBackgroundImage:[UIImage SquareImageWithColor:ColorBackground andSize:CGSizeMake(1, 1)] forState:(UIControlStateNormal)];
    [usefullButton setTitleColor:ColorText forState:UIControlStateNormal];
    [usefullButton setViewOrigin:CGPointMake(0, WidthSepLine)];
    [usefullButton setViewSize:CGSizeMake(WidthEvaluateButton, HeightButtonView - WidthSepLine)];
    usefullButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    [usefullButton addTarget:self action:@selector(rateAsUsefull) forControlEvents:(UIControlEventTouchUpInside)];
    [usefullButton setTitle:@"有用" forState:(UIControlStateNormal)];
    [containerView addSubview:usefullButton];
    
    UIButton *useLessButton = [UIButton new];
    [useLessButton setBackgroundImage:[UIImage SquareImageWithColor:ColorBackground andSize:CGSizeMake(WidthEvaluateButton, HeightButtonView)] forState:(UIControlStateNormal)];
    [useLessButton setTitleColor:ColorText forState:UIControlStateNormal];
    [useLessButton setViewSize:usefullButton.viewSize];
    [useLessButton setViewOrigin:CGPointMake(usefullButton.viewRightEdge + WidthSepLine, WidthSepLine)];
    useLessButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [useLessButton addTarget:self action:@selector(rateAsUseless) forControlEvents:(UIControlEventTouchUpInside)];
    [useLessButton setTitle:@"没用" forState:(UIControlStateNormal)];
    [containerView addSubview:useLessButton];
    
    return containerView;
}

- (UIView *)createEvaluatedView {
    UIView * containerView = [UIView new];
    containerView.backgroundColor = ColorLine;
    containerView.viewSize = CGSizeMake(self.view.viewWidth, HeightButtonView);
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [UILabel new];
    [label setText:@"已反馈"];
    [label setViewWidth:self.view.viewWidth];
    [label setViewHeight:HeightButtonView - WidthSepLine];
    [label setViewY:WidthSepLine];
    [label setTextAlignment:(NSTextAlignmentCenter)];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setBackgroundColor:[UIColor whiteColor]];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [containerView addSubview:label];
    
    return containerView;
}

- (void)rateAsUsefull {
    if (self.botEvaluateDidTapUseful) {
        self.botEvaluateDidTapUseful(self.message.messageId);
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rateAsUseless {
    if (self.botEvaluateDidTapUseless) {
        self.botEvaluateDidTapUseless(self.message.messageId);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
