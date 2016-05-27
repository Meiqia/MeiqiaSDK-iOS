//
//  MQMessageFormConfig.m
//  MQChatViewControllerDemo
//
//  Created by bingoogolapple on 16/5/8.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MQMessageFormConfig.h"
#import "MQMessageFormInputModel.h"
#import "MQBundleUtil.h"

@implementation MQMessageFormConfig

+ (instancetype)sharedConfig {
    static MQMessageFormConfig *_sharedConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfig = [[MQMessageFormConfig alloc] init];
    });
    return _sharedConfig;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setConfigToDefault];
    }
    return self;
}

- (void)setConfigToDefault {
    self.leaveMessageIntro = @"";
    self.messageFormViewStyle = [MQMessageFormViewStyle defaultStyle];
}

@end
