//
//  MQChatFileUtil.m
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/30.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import "MQChatFileUtil.h"
#import <AVFoundation/AVFoundation.h>
#import "MQServiceToViewInterface.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MQChatFileUtil

+ (BOOL)fileExistsAtPath:(NSString*)path isDirectory:(BOOL)isDirectory
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
}

+ (BOOL)deleteFileAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

+(float)audioDuration:(NSString*)filePath
{
    return [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil].duration;
}

/** 获取音频长度 */
+ (NSTimeInterval)getAudioDurationWithData:(NSData *)audioData {
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    if (audioPlayer.duration) {
        return audioPlayer.duration;
    } else {
        return 0;
    }
}

+ (void)playSoundWithSoundFile:(NSString *)fileName {
//    NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
//    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:false];

    
    NSURL *filePath = [NSURL fileURLWithPath:fileName isDirectory:false];
    SystemSoundID soundID;
    
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    if (error) {
        NSLog(@"无法创建SystemSoundID");
    }
    else {
        AudioServicesPlaySystemSound(soundID);
    }
}

+ (BOOL)saveFileWithName:(NSString *)fileName data:(NSData *)data {
    if (![self fileExistsAtPath:DIR_RECEIVED_FILE isDirectory:YES]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DIR_RECEIVED_FILE withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *path = [DIR_RECEIVED_FILE stringByAppendingString:fileName];
    return [data writeToFile:path atomically:YES];
}

+ (id)getFileWithName:(NSString *)fileName {
    NSString *path = [DIR_RECEIVED_FILE stringByAppendingString:fileName];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if (error) {
        NSLog(@"FAIL TO READ FILE: %@ \n error:%@",path, error);
    }
    return data;
}

+ (float)getfileSizeAtPath:(NSString *)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize] / 1024.0;
    }
    return 0;
}

+ (float)getVideoLength:(NSURL *)fileUrl {
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:fileUrl options:dic];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

+(NSString *)getVideoPathWithName:(NSString *)videoName {

    NSString *directoryPath = DIR_RECEIVED_FILE;
    if (![self fileExistsAtPath:directoryPath isDirectory:YES]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * tempPath = [directoryPath stringByAppendingPathComponent:videoName];
    return tempPath;
}

+ (NSString *)getMd5WithString:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)getVideoCachePathWithServerUrl:(NSString *)serverUrl {
    NSURL *videoUrl = [NSURL URLWithString:serverUrl];
    NSString *videoName = [self getMd5WithString:serverUrl];
    NSString *videoExtension = [videoUrl pathExtension];
    NSString *directoryPath = DIR_RECEIVED_FILE;
    if (![self fileExistsAtPath:directoryPath isDirectory:YES]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * tempPath = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",videoName,videoExtension]];
    return tempPath;
}

+ (NSString *)saveVideoSourceWith:(NSURL *)fileUrl {
    NSInteger random = (arc4random() % 99999) + 45241;
    NSString *videoName = [NSString stringWithFormat:@"%qu%li",(unsigned long long)([[NSDate date] timeIntervalSince1970] * 1000),(long)random];
    NSString *resultPath = [self getVideoPathWithName:[NSString stringWithFormat:@"%@.mov",videoName]];
    NSURL *resultUrl = [NSURL fileURLWithPath:resultPath];
    BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtURL:fileUrl toURL:resultUrl error:nil];
    if (isSuccess) {
        return resultPath;
    }
    return  nil;
}

+ (UIImage *)getLocationVideoPreViewImage:(NSURL *)path {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

@end
