//
//  MQProductCardMessage.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2021/9/1.
//  Copyright © 2021 2020 MeiQia. All rights reserved.
//

#import "MQProductCardMessage.h"

@implementation MQProductCardMessage

- (instancetype)initWithPictureUrl:(NSString *)pictureUrl title:(NSString *)title description:(NSString *)desc productUrl:(NSString *)productUrl andSalesCount:(long)count
{
    if (self = [super init]) {
        self.pictureUrl = pictureUrl;
        self.title  = title;
        self.desc = desc;
        self.productUrl  = productUrl;
        self.salesCount = count;
    }
    return self;
}

@end
