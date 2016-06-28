//
//  MQRichTextMessage.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQBaseMessage.h"

@interface MQRichTextMessage : MQBaseMessage

@property (nonatomic, copy)NSString *thumbnail;
@property (nonatomic, copy)NSString *summary;
@property (nonatomic, copy)NSString *content;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
