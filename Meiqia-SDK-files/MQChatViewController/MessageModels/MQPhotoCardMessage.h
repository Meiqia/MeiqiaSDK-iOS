//
//  MQPhotoCardMessage.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQPhotoCardMessage : MQBaseMessage

@property (nonatomic, copy) NSString *imagePath;

@property (nonatomic, copy) NSString *targetUrl;


-(instancetype)initWithImagePath:(NSString *)path andUrlPath:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
