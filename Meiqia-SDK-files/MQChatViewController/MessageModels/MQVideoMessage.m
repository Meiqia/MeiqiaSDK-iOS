//
//  MQVideoMessage.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/23.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQVideoMessage.h"
#import "MQChatFileUtil.h"

@implementation MQVideoMessage

- (instancetype)initWithVideoServerPath:(NSString *)videoPath {
    if (self = [super init]) {
       
        if ([[videoPath substringToIndex:4] isEqualToString:@"http"]) {
            
            NSArray *arr = [videoPath componentsSeparatedByString:@"/"];
            if (arr.count > 3) {
                NSDateFormatter *formater = [NSDateFormatter new];
                formater.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
                [formater setDateFormat:@"yyyyMMdd HH:mm:ss"];
                self.date = [formater dateFromString:[NSString stringWithFormat:@"%@ %@",arr[arr.count - 3], @"23:59:59"]];
            }
            
            NSString *mediaPath = [MQChatFileUtil getVideoCachePathWithServerUrl:videoPath];
            if ([MQChatFileUtil fileExistsAtPath:mediaPath isDirectory:NO]) {
                self.videoPath = mediaPath;
            } else {
                self.videoUrl = videoPath;
            }
        } else {
            self.videoPath = videoPath;
        }
    }
    return self;
}

- (void)handleAccessoryData:(NSDictionary *)accessoryData {
    
    if (accessoryData && [accessoryData isEqual:[NSNull null]]) {
        if ([accessoryData objectForKey:@"thumb_url"] && ![[accessoryData objectForKey:@"thumb_url"] isEqual:[NSNull null]]) {
            self.thumbnailUrl = [accessoryData objectForKey:@"thumb_url"];
        }
    }
}

@end
