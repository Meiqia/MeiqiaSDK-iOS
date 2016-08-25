//
//  MQBotMenuAnswerCellModel.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/24.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"

@class MQBotAnswerMessage;
@interface MQBotMenuAnswerCellModel : NSObject <MQCellModelProtocol>

@property (nonatomic, strong) NSArray *menus;
@property (nonatomic, strong) NSString *menuTitle;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) BOOL isEvaluated;
@property (nonatomic, copy) NSString *avatarURL;

- (instancetype)initCellModelWithMessage:(MQBotAnswerMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator;

@end
