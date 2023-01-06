//
//  MQPageDataSource.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/12/26.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MQPageDataModel : NSObject

@property (nonatomic, copy) NSString *titleStr;

@property (nonatomic, strong) NSArray *contentArr;

@end

NS_ASSUME_NONNULL_END
