//
//  MQModel.h
//  MeiQiaSDK
//
//  Created by ian luo on 16/6/23.
//  Copyright © 2016年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 使用 MQModel 的对象需要实现的方法
/// 映射的对象包含 3 种
/// 1. 本对象的属性
/// 2. 一个带有返回值，返回给指定属性的方法（结尾用 >:属性名）
/// 3. 一个没有返回值的方法（结尾用 >:）
@protocol MQMappable <NSObject>

/// 返回服务端 json 字段到本对象字段的映射
- (NSDictionary *)fromServerMapping;

/// 返回本对象字段到数据库字段的映射
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
