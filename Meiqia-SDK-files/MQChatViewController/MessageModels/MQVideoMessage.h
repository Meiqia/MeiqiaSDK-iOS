//
//  MQVideoMessage.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/23.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQVideoMessage : MQBaseMessage

/// 消息video 本地缓存path,无缓存则为空
@property (nonatomic, copy) NSString *videoPath;

/// 消息video 服务器url
@property (nonatomic, copy) NSString *videoUrl;

/// 消息video 第一帧的图片url
@property (nonatomic, copy) NSString *thumbnailUrl;

/// video 过期时间
@property (nonatomic, strong) NSDate* expireTime;

- (instancetype)initWithVideoServerPath:(NSString *)videoPath;

- (void)handleAccessoryData:(NSDictionary *)accessoryData;

@end

NS_ASSUME_NONNULL_END
