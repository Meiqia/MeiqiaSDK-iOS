//
//  MQPhotoCardMessage.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQPhotoCardMessage.h"

@implementation MQPhotoCardMessage

-(instancetype)initWithImagePath:(NSString *)path andUrlPath:(NSString *)url {
    if (self = [super init]) {
        self.imagePath = path;
        self.targetUrl  = url;
    }
    return self;
}


@end
