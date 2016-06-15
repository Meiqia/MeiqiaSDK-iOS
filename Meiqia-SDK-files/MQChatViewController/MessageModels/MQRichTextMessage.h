//
//  MQRichTextMessage.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQBaseMessage.h"

@interface MQRichTextMessage : MQBaseMessage

@property (nonatomic, copy)NSString *url;
@property (nonatomic, copy)NSString *iconPath;
@property (nonatomic, copy)NSString *content;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
