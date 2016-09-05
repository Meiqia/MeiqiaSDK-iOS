//
//  MQMQWebViewBubbleCellModel.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"

@class MQTextMessage;
@interface MQMQWebViewBubbleCellModel : NSObject <MQCellModelProtocol>

@property (nonatomic, copy) CGFloat(^cellHeight)(void);

- (id)initCellModelWithMessage:(MQTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator;

@end
