//
//  MQChatFileUtil.h
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/30.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DIR_RECEIVED_FILE [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/received_files/"]

@interface MQChatFileUtil : NSObject

//判断文件是否存在
+ (BOOL)fileExistsAtPath:(NSString*)path isDirectory:(BOOL)isDirectory;

//删除文件
+ (BOOL)deleteFileAtPath:(NSString *)_path;

+(float)audioDuration:(NSString *)filePath;

/** 获取音频长度 */
+ (NSTimeInterval)getAudioDurationWithData:(NSData *)audioData;

/**
 *  播放文件的声音
 *
 *  @param fileName 声音文件名字
 */
+ (void)playSoundWithSoundFile:(NSString *)fileName;

+ (BOOL)saveFileWithName:(NSString *)fileName data:(NSData *)data;

+ (id)getFileWithName:(NSString *)fileName;

/**
 *  获取单个文件大小，以kb为单位
 *
 */
+ (float)getfileSizeAtPath:(NSString *)filePath;

/**
 *  获取本地视频文件的时长
 *
 */
+ (float)getVideoLength:(NSURL *)fileUrl;

/**
 *  获取本地视频的缓存路径
 *
 * @param serverUrl 服务器的url
 * @return 返回改文件的缓存路径
 */
+ (NSString *)getVideoCachePathWithServerUrl:(NSString *)serverUrl;

/**
 *  暂时缓存视频路径，此路径的文件为mov格式的，调用美洽sdk发送视频时候才会压缩转换成MP4格式
 *
 * @param fileUrl 视频的原路径
 * @return 返回改文件的缓存路径
 */
+ (NSString *)saveVideoSourceWith:(NSURL *)fileUrl;

/**
 *  获取本地视频第一帧图片
 */
+ (UIImage*)getLocationVideoPreViewImage:(NSURL *)path;

@end
