//
//  MCRecorderView.m
//  Meiqia
//
//  Created by Injoy on 16/5/10.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import "MQRecorderView.h"
//#import "mobile-Swift.h"
#import "MQAssetUtil.h"
#import "MQChatAudioRecorder.h"
#import "MQToast.h"

@interface MQRecorderView()<MQChatAudioRecorderDelegate>



@end

@implementation MQRecorderView
{
    UIView *recordButton;
    UIImageView *micImageView;
    CALayer *volumeLayer;
    
    MQChatAudioRecorder *recorder;
    UILongPressGestureRecognizer *longGesture;
    CGPoint point;
    CGFloat recordTime;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.font = [UIFont systemFontOfSize:18];
    _tipLabel.textColor = [UIColor colorWithRed:118/255.0 green:125/255.0 blue:133/255.0 alpha:1];
    _tipLabel.text = @"按住说话";
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_tipLabel];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tipLabel]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_tipLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[_tipLabel(25)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_tipLabel)]];
    
    CGFloat micImageViewWH = 48;
    CGFloat recordButtonWH = 90;
    micImageView = [[UIImageView alloc] initWithImage:[MQAssetUtil imageFromBundleWithName:@"rectangle9Copy5"]];
    recordButton = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - recordButtonWH) / 2, 100, recordButtonWH, recordButtonWH)];
    recordButton.backgroundColor = [UIColor colorWithRed: 23/255.0 green: 199/255.0 blue: 209/255.0 alpha: 1];
    [recordButton setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin)];
    recordButton.layer.cornerRadius = recordButtonWH / 2;
    
    micImageView.frame = CGRectMake((recordButtonWH - 48)/2, (recordButtonWH - 48)/2, micImageViewWH, micImageViewWH);
    [recordButton addSubview:micImageView];
    [self addSubview:recordButton];
    [micImageView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin)];


    longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    longGesture.delaysTouchesBegan = NO;
    longGesture.delaysTouchesEnded = NO;
    longGesture.minimumPressDuration = 0;
    [recordButton addGestureRecognizer:longGesture];
    
    volumeLayer = [CALayer layer];
    volumeLayer.opacity = 0.25;
    [self changeVolumeLayerDiameter:volumeLayer.frame.size.width];
    [self.layer insertSublayer:volumeLayer below:recordButton.layer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    volumeLayer.position = CGPointMake(self.center.x, volumeLayer.position.y);
}

- (void)changeVolumeLayerDiameter:(CGFloat)dia_ {
    
    CGFloat dia = dia_ > 1 ? dia_ : recordButton.frame.size.width + 8 * sqrt(dia_ * 100);
    
    CGRect frame = CGRectMake(recordButton.center.x - dia/2, recordButton.center.y - dia/2, dia, dia);
    volumeLayer.frame = frame;
    volumeLayer.cornerRadius = dia/2;
    volumeLayer.backgroundColor = recordButton.backgroundColor.CGColor;
    
    CGFloat time = [self getRecordTime];
    if (time >= 50) {
        if (point.y < 50) {
            self.tipLabel.text = [NSString stringWithFormat:@"录音将在%li秒后结束", (long)(60 - time)];
        }else{
            self.tipLabel.text = [NSString stringWithFormat:@"录音将在%li秒后发送", (long)(60 - time)];
        }
    }
}

- (CGFloat)getRecordTime {
    if (recordTime > 0) {
        return CFAbsoluteTimeGetCurrent() - recordTime;
    } else {
        return 0;
    }
}

- (void)panGestureRecognizerAction:(UIGestureRecognizer*)sender {
    point = [sender locationInView:self];
    if(sender.state == UIGestureRecognizerStateBegan) {
        recordTime = CFAbsoluteTimeGetCurrent();
        
        if ([self.delegate respondsToSelector:@selector(recordStarted)]) {
            [self.delegate recordStarted];
        }
        self.tipLabel.text = @"手指上滑，取消发送";
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        if (point.y < 50) {
            if ([self.delegate respondsToSelector:@selector(recordCanceld)]) {
                [self.delegate recordCanceld];
            }
        }else{
            //录音时间需要大于1秒
            if ([self getRecordTime] < 1) {
                [MQToast showToast:@"录音时间太短" duration:0.2 window:self.window];
                if ([self.delegate respondsToSelector:@selector(recordCanceld)]) {
                    [self.delegate recordCanceld];
                }
            }else{
                if ([self.delegate respondsToSelector:@selector(recordEnd)]) {
                    [self.delegate recordEnd];
                }
            }
            
        }
        [self reUI];
    } else if(sender.state == UIGestureRecognizerStateChanged) {
            if (point.y < 50) {
                if ([self getRecordTime] < 50) {
                    self.tipLabel.text = @"松开手指，取消发送";
                }
                micImageView.image = [MQAssetUtil imageFromBundleWithName:@"exit_recording"];
                recordButton.backgroundColor = [UIColor colorWithRed: 150/255.0 green: 159/255.0 blue: 170/255.0 alpha: 1];
            }else{
                if ([self getRecordTime] < 50) {
                    self.tipLabel.text = @"手指上滑，取消发送";
                }
                micImageView.image = [MQAssetUtil imageFromBundleWithName:@"rectangle9Copy5"];
                recordButton.backgroundColor = [UIColor colorWithRed: 23/255.0 green: 199/255.0 blue: 209/255.0 alpha: 1];
            }
    }
}

- (void)reUI {
    recordTime = -1;
    [self changeVolumeLayerDiameter:recordButton.frame.size.width];
    self.tipLabel.text = @"按住说话";
    micImageView.image = [MQAssetUtil imageFromBundleWithName:@"rectangle9Copy5"];
    recordButton.backgroundColor = [UIColor colorWithRed: 23/255.0 green: 199/255.0 blue: 209/255.0 alpha: 1];
}

@end
