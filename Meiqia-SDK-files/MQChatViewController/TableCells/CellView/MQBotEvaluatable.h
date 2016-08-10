//
//  MQBotEvaluatable.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/10.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MQBotEvaluatable <NSObject>

- (void)botEvaluateDidTapUsefulWithMessageId:(NSString *)messageId;

- (void)botEvaluateDidTapUselessWithMessageId:(NSString *)messageId;

@end

@protocol MQBotEvaluateDelegate <NSObject>

@required
- (void)evaluateBotAnswer:(BOOL)isUseful messageId:(NSString *)messageId ;

@end
