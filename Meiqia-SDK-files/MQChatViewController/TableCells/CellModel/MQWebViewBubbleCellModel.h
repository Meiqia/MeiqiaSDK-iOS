//
//  MQMQWebViewBubbleCellModel.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"

@class MQRichTextMessage;
@interface MQWebViewBubbleCellModel : NSObject <MQCellModelProtocol>

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) CGFloat(^cellHeight)(void);
@property (nonatomic, copy) void(^avatarLoaded)(UIImage *);

@property (nonatomic, assign) CGFloat cachedWetViewHeight;

- (void)bind;

- (id)initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator;

@end
