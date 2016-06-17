//
//  MCRecorderView.h
//  Meiqia
//
//  Created by Injoy on 16/5/10.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MQRecorderViewDelegate <NSObject>

//- (NSString *)voiceFilePath;

- (void)recordEnd;

- (void)recordStarted;

- (void)recordCanceld;

@end

@interface MQRecorderView : UIView

@property (nonatomic, weak) id<MQRecorderViewDelegate> delegate;

@property (nonatomic, strong, readonly) UILabel *tipLabel;

- (void)changeVolumeLayerDiameter:(CGFloat)dia;

@end
