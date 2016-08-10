//
//  MQRichTextViewCell.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQChatBaseCell.h"
#import "MQBotEvaluatable.h"

@interface MQRichTextViewCell : MQChatBaseCell

- (void)botEvaluateDidTapUsefulWithMessageId:(NSString *)messageId;

- (void)botEvaluateDidTapUselessWithMessageId:(NSString *)messageId;

@end
