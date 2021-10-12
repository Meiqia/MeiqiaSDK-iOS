//
//  NSString+MQRegular.h
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/26.
//  Copyright © 2020 MeiQia. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MQRegular)

- (BOOL)mq_isQQ;

- (BOOL)mq_isPhoneNumber;

- (BOOL)mq_isTelNumber;

/**
 * 去掉<a><span><html> 标签
 */
- (NSString*)mq_textContent;

@end

NS_ASSUME_NONNULL_END
