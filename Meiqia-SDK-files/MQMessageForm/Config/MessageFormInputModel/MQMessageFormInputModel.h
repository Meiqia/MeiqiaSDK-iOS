//
//  MQMessageFormInputModel.h
//  MeiQiaSDK
//
//  Created by bingoogolapple on 16/5/6.
//  Copyright © 2016年 MeiQia Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    InputModelTypeText               = 0, //文字
    InputModelTypeNumber             = 1, //数字
    InputModelTypeTime               = 2, //日期
    InputModelTypeSingleChoice       = 3, //单选
    InputModelTypeMultipleChoice     = 4, //多选
} FormInputModelType;

/**
 * 留言表单界面输入框模型
 */
@interface MQMessageFormInputModel : NSObject

/** 留言表单输入框上方的提示文案 */
@property (nonatomic, copy) NSString *tip;

/** 留言表单输入框placeholder */
@property (nonatomic, copy) NSString *placeholder;

/** 留言表单输入框text */
@property (nonatomic, copy) NSString *text;

/** 上传服务器是对应的key */
@property (nonatomic, copy) NSString *key;

/** 是否是必填 */
@property (nonatomic, assign) BOOL isRequired;

/** 输入框是否是单行 */
@property (nonatomic, assign) BOOL isSingleLine;

/** 留言的类型 */
@property (nonatomic, assign) FormInputModelType inputModelType;

/** 多选，单选类型中的选项内容 */
@property (nonatomic, strong) NSArray<NSString *> *metainfo; 

@end
