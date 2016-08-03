//
//  MQModel.h
//  MeiQiaSDK
//
//  Created by ian luo on 16/6/23.
//  Copyright © 2016年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MQMappable <NSObject>

- (NSDictionary *)fromServerMapping;

- (NSDictionary *)toDBMapping;

@optional
- (id)transformWithKey:(NSString *)key value:(id)value;

@end

@interface MQModel : NSObject<MQMappable>

@property (nonatomic, strong) id rawData;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSString *)outputJSON;

- (NSDictionary *)fromServerMapping;

- (NSDictionary *)toDBMapping;

@end

@interface MQModel (TransformData)

- (NSString *)JSONString:(id)jsonObj;

- (id)objWithJSON:(NSString *)jsonString;

@end
