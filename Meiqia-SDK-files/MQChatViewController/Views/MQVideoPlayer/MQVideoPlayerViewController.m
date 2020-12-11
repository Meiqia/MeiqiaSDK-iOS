//
//  MQVideoPlayerViewController.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/26.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQVideoPlayerViewController.h"
#import "MQChatFileUtil.h"

@interface MQVideoPlayerViewController ()

@property (nonatomic, copy) NSString * mediaPath;

@property (nonatomic, copy) NSString * mediaServerPath;

@end

@implementation MQVideoPlayerViewController

- (instancetype)initPlayerWithLocalPath:(NSString *)localPath serverPath:(NSString *)serverPath {
    if (self = [super init]) {
        self.mediaPath = localPath;
        self.mediaServerPath = serverPath;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.mediaPath.length > 0 && [MQChatFileUtil fileExistsAtPath:self.mediaPath isDirectory:NO]) {
        self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.mediaPath]];
    } else {
        self.player = [AVPlayer playerWithURL:[NSURL URLWithString:self.mediaServerPath]];
    }
    self.showsPlaybackControls = YES;
}

@end
