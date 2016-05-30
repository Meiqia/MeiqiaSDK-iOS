//
//  MCRecorderView.h
//  Meiqia
//
//  Created by Injoy on 16/5/10.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCRecorderViewDelegate <NSObject>

//- (NSString *)voiceFilePath;

- (void)recordEnd;

- (void)recordStarted;

- (void)recordCanceld;

@end

@interface MCRecorderView : UIView

@property (nonatomic, strong) id<MCRecorderViewDelegate> delegate;

@property (nonatomic, strong, readonly) UILabel *tipLabel;

- (void)changeVolumeLayerDiameter:(CGFloat)dia;

@end
