//
//  MQBotRickTextMessage.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/8.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQRichTextMessage.h"

@interface MQBotRichTextMessage : MQRichTextMessage

@property (nonatomic, strong) NSNumber *questionId;
@property (nonatomic, assign) BOOL isEvaluated;
@property (nonatomic, copy) NSString *subType;

@end
