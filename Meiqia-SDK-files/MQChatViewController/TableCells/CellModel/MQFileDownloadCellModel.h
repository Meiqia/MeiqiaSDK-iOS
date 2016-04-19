//
//  MQFileDownloadCellModel.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/4/6.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"

@class MQFileDownloadMessage;
typedef NS_ENUM(NSUInteger, FileDownloadStatus) {
    FileDownloadStatusNotDownloaded = 0,
    FileDownloadStatusDownloading,
    FileDownloadStatusDownloadComplete,
};

@interface MQFileDownloadCellModel : NSObject <MQCellModelProtocol>

@property (nonatomic, strong) id file;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileSize;
@property (nonatomic, strong) UIImage *avartarImage;
@property (nonatomic, assign) FileDownloadStatus fileDownloadStatus;
@property (nonatomic, copy) NSString *timeBeforeExpire;

@property (nonatomic, copy) void(^fileDownloadStatusChanged)(FileDownloadStatus);
@property (nonatomic, copy) void(^needsToUpdateUI)(void);
@property (nonatomic, copy) void(^avatarLoaded)(UIImage *);
@property (nonatomic, copy) CGFloat(^cellHeight)(void);
@property (nonatomic, assign) BOOL isExpired;

- (id)initCellModelWithMessage:(MQFileDownloadMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator;

- (void)startDownloadWitchProcess:(void(^)(CGFloat process))block;

- (void)cancelDownload;

- (void)openFile:(id)sender;

@end
