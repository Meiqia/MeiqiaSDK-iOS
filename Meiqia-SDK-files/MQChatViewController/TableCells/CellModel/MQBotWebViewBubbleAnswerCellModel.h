//
//  MQBotWebViewBubbleAnswerCellModel.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQWebViewBubbleCellModel.h"

@class MQBotRichTextMessage;
@interface MQBotWebViewBubbleAnswerCellModel : NSObject <MQCellModelProtocol>

@property (nonatomic, assign) BOOL isEvaluated;
/**
 * @brief 问题是否已解决的标记
 */
@property (nonatomic, assign) BOOL solved;
@property (nonatomic, copy) NSString *avatarPath;
@property (nonatomic, copy) NSString *messageId;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) void(^avatarLoaded)(UIImage *);
@property (nonatomic, copy) CGFloat(^cellHeight)(void);

@property (nonatomic, assign) CGFloat cachedWebViewHeight;
@property (nonatomic, assign) BOOL needShowFeedback;

- (id)initCellModelWithMessage:(MQBotRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator;

- (void)bind;

@end
