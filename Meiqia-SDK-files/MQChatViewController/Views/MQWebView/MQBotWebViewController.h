//
//  MQBotWebViewController.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/9.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQWebViewController.h"

@class MQBotRichTextMessage;
@interface MQBotWebViewController : MQWebViewController

@property (nonatomic, strong)MQBotRichTextMessage *message;
@property (nonatomic, copy) void(^botEvaluateDidTapUseful)(NSString *);
@property (nonatomic, copy) void(^botEvaluateDidTapUseless)(NSString *);

@end
