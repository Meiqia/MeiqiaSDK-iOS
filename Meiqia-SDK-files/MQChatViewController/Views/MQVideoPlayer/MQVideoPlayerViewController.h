//
//  MQVideoPlayerViewController.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/26.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MQVideoPlayerViewController : AVPlayerViewController

- (instancetype)initPlayerWithLocalPath:(NSString *)localPath serverPath:(NSString *)serverPath;

@end

NS_ASSUME_NONNULL_END
