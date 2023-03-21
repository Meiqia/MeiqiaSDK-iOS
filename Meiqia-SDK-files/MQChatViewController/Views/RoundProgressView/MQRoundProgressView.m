//
//  RoundProgressView.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/27.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQRoundProgressView.h"

#define kBorderWith 10
@interface MQRoundProgressView ()

@property (nonatomic, strong) UIView *centerView;
@property (strong, nonatomic) CAShapeLayer *outLayer;
@property (strong, nonatomic) CAShapeLayer *progressLayer;

@end

@implementation MQRoundProgressView

- (instancetype)initWithFrame:(CGRect)frame centerView:(UIView *)centerView {
    if (self = [super initWithFrame:frame]) {
        self.centerView = centerView;
        [self drawProgress];
    }
    return self;
}

- (void)drawProgress {
    CGFloat radius = self.bounds.size.width / 2.0; // 半径
    CGFloat startAngle = -M_PI/2.0; // 起始角度
    CGFloat endAngle = M_PI * 3.0/2.0; // 结束角度
    UIBezierPath *loopPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    self.outLayer = [CAShapeLayer layer];
    self.outLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    self.outLayer.fillColor = [UIColor clearColor].CGColor;
    self.outLayer.lineWidth = kBorderWith;
    self.outLayer.path = loopPath.CGPath;
    [self.layer addSublayer:self.outLayer];
    
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.strokeColor = [UIColor blackColor].CGColor;
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.strokeStart = 0;
    self.progressLayer.strokeEnd = 0;
    self.progressLayer.lineWidth = kBorderWith;
    self.progressLayer.path = loopPath.CGPath;
    [self.layer addSublayer:self.progressLayer];
    
    self.centerView.frame = self.bounds;
    [self addSubview:self.centerView];
}

- (void)updateProgress:(CGFloat)progress {
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:0.5];
    self.progressLayer.strokeEnd = progress;
    [CATransaction commit];
}

- (void)setProgressColor:(UIColor *)progressColor {
    self.progressLayer.strokeColor = progressColor.CGColor;
}

- (void)setProgressHidden:(BOOL)progressHidden {
    self.progressLayer.hidden = progressHidden;
    self.outLayer.hidden = progressHidden;
}

@end
