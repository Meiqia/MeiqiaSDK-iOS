//
//  MQRichTextMessage.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQRichTextMessage.h"

@implementation MQRichTextMessage

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.url = @"https://developer.apple.com/ios/";
        self.content = @"The iOS 10 SDK includes new APIs and services that enable new categories of apps and features. Your apps can now extend to Messages, Siri, Phone, and Maps to provide more engaging functionality like never before.";
        self.iconPath = @"https://dbd6j53uzcole.cloudfront.net/assets/images/icons/project-types/project-icon_ios.e4c7d03f.svg";
    }
    return self;
}

@end
