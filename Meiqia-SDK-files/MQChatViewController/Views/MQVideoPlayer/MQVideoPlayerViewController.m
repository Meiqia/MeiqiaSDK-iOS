//
//  MQVideoPlayerViewController.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/26.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQVideoPlayerViewController.h"
#import "MQChatFileUtil.h"
#import "MQBundleUtil.h"
#import "MQToast.h"
#import <Photos/Photos.h>

@interface MQVideoPlayerViewController ()

@property (nonatomic, copy) NSString * mediaPath;

@property (nonatomic, copy) NSString * mediaServerPath;

@property (nonatomic, strong) UIButton *saveButton;

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
    
    if (self.mediaPath.length > 0 && [MQChatFileUtil fileExistsAtPath:self.mediaPath isDirectory:NO]) {
        self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.mediaPath]];
    } else {
        self.player = [AVPlayer playerWithURL:[NSURL URLWithString:self.mediaServerPath]];
    }
    self.showsPlaybackControls = YES;
    
    // 添加保存按钮到 self.view，确保在系统播放控件之上
    [self.view addSubview:self.saveButton];
    self.saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.saveButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10],
        [self.saveButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-20]
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view bringSubviewToFront:self.saveButton];
}

#pragma mark - Lazy Load

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton new];
        [_saveButton setTitle:[MQBundleUtil localizedStringForKey:@"save_photo"] forState:UIControlStateNormal];
        [_saveButton sizeToFit];
        _saveButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _saveButton.layer.cornerRadius = 12;
        _saveButton.layer.masksToBounds = YES;
        _saveButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_saveButton setContentEdgeInsets:UIEdgeInsetsMake(10, 20, 10, 20)];
        [_saveButton addTarget:self action:@selector(saveVideo) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

#pragma mark - Save Video

- (void)saveVideo {
    if (self.mediaPath.length > 0 && [MQChatFileUtil fileExistsAtPath:self.mediaPath isDirectory:NO]) {
        [self saveVideoToAlbumWithPath:self.mediaPath];
    } else if (self.mediaServerPath.length > 0) {
        self.saveButton.enabled = NO;
        [self.saveButton setTitle:[MQBundleUtil localizedStringForKey:@"save_video_downloading"] forState:UIControlStateNormal];
        
        NSString *cachePath = [MQChatFileUtil getVideoCachePathWithServerUrl:self.mediaServerPath];
        if ([MQChatFileUtil fileExistsAtPath:cachePath isDirectory:NO]) {
            [self saveVideoToAlbumWithPath:cachePath];
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *encodedUrlStr = [weakSelf.mediaServerPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSURL *videoURL = [NSURL URLWithString:encodedUrlStr];
            NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (videoData && videoData.length > 0) {
                    [videoData writeToFile:cachePath atomically:YES];
                    [weakSelf saveVideoToAlbumWithPath:cachePath];
                } else {
                    weakSelf.saveButton.enabled = YES;
                    [weakSelf.saveButton setTitle:[MQBundleUtil localizedStringForKey:@"save_photo"] forState:UIControlStateNormal];
                    [MQToast showToast:[MQBundleUtil localizedStringForKey:@"save_photo_error"] duration:1.5 window:weakSelf.view.window];
                }
            });
        });
    }
}

- (void)saveVideoToAlbumWithPath:(NSString *)videoPath {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:videoPath]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.saveButton.enabled = YES;
            [self.saveButton setTitle:[MQBundleUtil localizedStringForKey:@"save_photo"] forState:UIControlStateNormal];
            if (success) {
                [MQToast showToast:[MQBundleUtil localizedStringForKey:@"save_video_success"] duration:1.5 window:self.view.window];
            } else {
                [MQToast showToast:[MQBundleUtil localizedStringForKey:@"save_photo_error"] duration:1.5 window:self.view.window];
            }
        });
    }];
}

@end


