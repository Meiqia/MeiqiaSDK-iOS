//
//  MQBundleUtil.m
//  MQChatViewControllerDemo
//
//  Created by Injoy on 15/11/16.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MQBundleUtil.h"
#import "MQChatViewController.h"
#import "MQChatFileUtil.h"
#import "MQCustomizedUIText.h"
#import "MQChatViewConfig.h"

@implementation MQBundleUtil

+ (NSBundle *)assetBundle
{
    static NSBundle *resourceBundle = nil;
    if (resourceBundle == nil) {
        resourceBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[MQChatViewController class]] pathForResource:@"MQChatViewAsset" ofType:@"bundle"]];
    }
    return resourceBundle;
}

+ (NSString *)localizedStringForKey:(NSString *)key
{
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([MQChatViewConfig sharedConfig].localizedLanguageStr && [MQChatViewConfig sharedConfig].localizedLanguageStr.length > 0) {
        language = [MQChatViewConfig sharedConfig].localizedLanguageStr;
    }
    if ([language hasPrefix:@"en"]) {
        language = @"en";
    } else if ([language hasPrefix:@"zh"]) {
        if ([language rangeOfString:@"Hans"].location != NSNotFound) {
            language = @"zh-Hans"; // 简体中文
        } else { // zh-Hant\zh-HK\zh-TW
            language = @"zh-Hant"; // 繁體中文
        }
    } else if ([language hasPrefix:@"ms"]) {
        language = @"ms"; // 马来语
    } else if ([language hasPrefix:@"id"]) {
        language = @"id"; // 印尼语
    } else {
        language = @"en";
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[MQBundleUtil assetBundle] pathForResource:language ofType:@"lproj"]];
    
    return [MQCustomizedUIText customiedTextForBundleKey:key] ?: [bundle localizedStringForKey:key value:nil table:@"MQChatViewController"];
}

@end
