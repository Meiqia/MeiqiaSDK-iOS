//
//  MQBotHighMenuMessage.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/12/28.
//  Copyright © 2022 MeiQia Inc. All rights reserved.
//

#import "MQBotHighMenuMessage.h"

@implementation MQBotHighMenuMessage

- (instancetype)initWithMenuData:(NSArray<MQPageDataModel *> *)menus contentText:(NSString *)text pageSize:(NSInteger)size{
    if (self = [super init]) {
        self.pageMaxSize = size;
        self.content = text;
        self.menuList = [[NSArray alloc] initWithArray:menus];
    }
    return self;
}

@end
