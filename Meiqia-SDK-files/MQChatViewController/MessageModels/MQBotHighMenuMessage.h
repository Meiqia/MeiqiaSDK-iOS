//
//  MQBotHighMenuMessage.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/12/28.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import "MQBaseMessage.h"
#import "MQPageDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQBotHighMenuMessage : MQBaseMessage

@property (nonatomic, strong) NSArray<MQPageDataModel *> *menuList;

// 每页显示的最大条数
@property (nonatomic, assign) NSInteger pageMaxSize;

// 机器人的欢迎语
@property (nonatomic, copy) NSString *content;

/** 富文本消息 */
@property (nonatomic, copy) NSString *richContent;

/**
 * 初始化message
 */
- (instancetype)initWithMenuData:(NSArray<MQPageDataModel *> *)menus contentText:(NSString *)text pageSize:(NSInteger)size;

@end

NS_ASSUME_NONNULL_END
