//
//  MQBotMenuWebViewBubbleAnswerCellModel.h
//  Meiqia-SDK-Demo
//
//  Created by xulianpeng on 2017/9/26.
//  Copyright © 2017年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQWebViewBubbleCellModel.h"

@class MQBotRichTextMessage;
@interface MQBotMenuWebViewBubbleAnswerCellModel : NSObject<MQCellModelProtocol>

//xlp
@property (nonatomic, strong) NSArray *menus;
@property (nonatomic, copy) NSString *menuTitle;
@property (nonatomic, copy) NSString *menuFootnote;

@property (nonatomic, assign) BOOL isEvaluated;
@property (nonatomic, copy) NSString *avatarPath;
@property (nonatomic, copy) NSString *messageId;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) void(^avatarLoaded)(UIImage *);
@property (nonatomic, copy) CGFloat(^cellHeight)(void);

@property (nonatomic, assign) CGFloat cachedWebViewHeight;

- (id)initCellModelWithMessage:(MQBotRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator;

- (void)didEvaluate;

- (void)bind;
@end
