//
//  MQRichTextViewModel.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"

@class MQRichTextMessage;
@interface MQRichTextViewModel : NSObject <MQCellModelProtocol>

@property (nonatomic, copy) CGFloat(^cellHeight)(void);
@property (nonatomic, copy) void(^avatarLoaded)(UIImage *);
@property (nonatomic, copy) void(^iconLoaded)(UIImage *);
@property (nonatomic, copy) void(^modelChanges)(NSString *url, NSString *content, NSString *iconPath, NSString *htmlString);

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *iconPath;
@property (nonatomic, strong) UIImage *avartarImage;
@property (nonatomic, strong) UIImage *iconImage;

- (void)openFrom:(UIViewController *)cv;

- (void)load;

- (id)initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator;

@end
