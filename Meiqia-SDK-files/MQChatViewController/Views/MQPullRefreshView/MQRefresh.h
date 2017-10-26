//
//  MQRefresh.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2017/2/20.
//  Copyright © 2017年 Meiqia. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - UITableView(MQRefresh)
/*
@class MQRefresh;
@interface UITableView(MQRefresh)

@property (nonatomic) MQRefresh *refreshView;

- (void)setupPullRefreshWithAction:(void(^)(void))action;
- (void)startAnimation;
- (void)stopAnimationCompletion:(void(^)(void))action;
- (void)setLoadEnded;

@end
*/
#import "MQChatTableView.h"
@class MQRefresh;
@interface MQChatTableView (MQRefresh)

@property (nonatomic) MQRefresh *refreshView;
- (void)setupPullRefreshWithAction:(void(^)(void))action;
- (void)startAnimation;
- (void)stopAnimationCompletion:(void(^)(void))action;
- (void)setLoadEnded;

@end


/****xlp分割*****/
typedef NS_ENUM(NSUInteger, MQRefreshStatus) {
    MQRefreshStatusNormal,
    MQRefreshStatusDraging,
    MQRefreshStatusTriggered,
    MQRefreshStatusLoading,
    MQRefreshStatusEnd,
};

#pragma mark - MQRefresh

@interface MQRefresh : UIView

@property (nonatomic, assign, readonly) MQRefreshStatus status;

- (BOOL)updateCustomViewForStatus:(MQRefreshStatus)status;
- (void)updateTextForStatus:(MQRefreshStatus)status;
- (void)setLoadEnd;
- (void)updateStatusWithTopOffset:(CGFloat)topOffset;
- (void)setText:(NSString *)text forStatus:(MQRefreshStatus)status;
- (void)setView:(UIView *)view forStatus:(MQRefreshStatus)status;
- (void)setIsLoading:(BOOL)isLoading;

@end
