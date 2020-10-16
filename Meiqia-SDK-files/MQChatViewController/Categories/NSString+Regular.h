//
//  NSString+Regular.h
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/26.
//  Copyright © 2020 ijinmao. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Regular)

- (BOOL)isQQ;

- (BOOL)isPhoneNumber;

- (BOOL)isTelNumber;

@end

NS_ASSUME_NONNULL_END
