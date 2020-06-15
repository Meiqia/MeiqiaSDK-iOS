//
//  MQCardInfo.h
//  MeiQiaSDK
//
//  Created by qipeng_yuhao on 2020/5/25.
//  Copyright © 2020 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MQCardInfoMeta : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *value;

@end

typedef enum : NSUInteger {
    MQMessageCardTypeText                    = 0, // 文本
    MQMessageCardTypeDateTime                = 1, // 时间
    MQMessageCardTypeRadio                   = 2, // 单选框
    MQMessageCardTypeCheckbox                  = 3, // 复选框
    MQMessageCardTypeNone                  = 4
} MQMessageCardType;


@interface MQCardInfo : NSObject

@property (nonatomic, copy) NSString * label;

@property (nonatomic, strong) NSArray<MQCardInfoMeta *> *metaData;

@property (nonatomic, strong) NSArray<MQCardInfoMeta *> *metaInfo;

@property (nonatomic, copy) NSString * name;

@property (nonatomic, assign) NSInteger contentId;

@property (nonatomic, assign) MQMessageCardType cardType;


- (id)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
