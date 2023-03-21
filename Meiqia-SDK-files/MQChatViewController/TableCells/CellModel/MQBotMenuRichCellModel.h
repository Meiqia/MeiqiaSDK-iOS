//
//  MQBotMenuRichCellModel.h
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/6/1.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"
#import "MQBotMenuMessage.h"


NS_ASSUME_NONNULL_BEGIN

@interface MQBotMenuRichCellModel : NSObject <MQCellModelProtocol>

@property (nonatomic, strong) MQBotMenuMessage *message;

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, copy) NSString *avatarPath;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) CGFloat(^cellHeight)(void);

@property (nonatomic, copy) void(^avatarLoaded)(UIImage *);

@property (nonatomic, assign) CGFloat cachedWetViewHeight;

- (void)bind;

- (id)initCellModelWithMessage:(MQBotMenuMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator;


@end

NS_ASSUME_NONNULL_END
