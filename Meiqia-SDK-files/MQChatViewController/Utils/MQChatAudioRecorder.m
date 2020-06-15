//
//  MQChatAudioRecorder.h
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 15/11/2.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MQChatAudioRecorder.h"
#import "MEIQIA_MLAudioRecorder.h"
#import "MEIQIA_AmrRecordWriter.h"
#import "MQNamespacedDependencies.h"
#import "MEIQIA_MLAudioMeterObserver.h"
#import <UIKit/UIKit.h>
#import "MQBundleUtil.h"

@interface MQChatAudioRecorder() <MLAudioRecorderDelegate>
@property (nonatomic, strong) MLAudioRecorder *recorder;
@property (nonatomic, strong) AmrRecordWriter *amrWriter;
@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;

@end

@implementation MQChatAudioRecorder {
    //是否取消了录音
    BOOL isCancelRecording;
}

- (void)dealloc
{
    //音谱检测关联着录音类，录音类要停止了。所以要设置其audioQueue为nil
    self.meterObserver.audioQueue = nil;
    [self.recorder stopRecording];
}

- (instancetype)initWithMaxRecordDuration:(NSTimeInterval)duration {
    self = [super init];
    if (self) {
        isCancelRecording = false;
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        //初始化amr recorder
        AmrRecordWriter *amrWriter = [[AmrRecordWriter alloc]init];
        amrWriter.filePath = [path stringByAppendingPathComponent:@"record.amr"];
        amrWriter.maxSecondCount = duration;
        amrWriter.maxFileSize = 1024*256;
        self.amrWriter = amrWriter;
        
        //初始化音频属性的观察者
        MLAudioMeterObserver *meterObserver = [[MLAudioMeterObserver alloc]init];
        meterObserver.actionBlock = ^(NSArray *levelMeterStates,MLAudioMeterObserver *meterObserver){
            Float32 volume = [MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates];
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(didUpdateAudioVolume:)]) {
                    [self.delegate didUpdateAudioVolume:volume];
                }
            }
        };
        meterObserver.errorBlock = ^(NSError *error,MLAudioMeterObserver *meterObserver){
            [[[UIAlertView alloc]initWithTitle:[MQBundleUtil localizedStringForKey:@"record_error"] message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:[MQBundleUtil localizedStringForKey:@"user_confirm"], nil]show];
        };
        self.meterObserver = meterObserver;
        
        //初始化recorder
        MLAudioRecorder *recorder = [[MLAudioRecorder alloc]init];
        __weak __typeof(self)weakSelf = self;
        recorder.receiveStoppedBlock = ^{
            weakSelf.meterObserver.audioQueue = nil;
        };
        recorder.receiveErrorBlock = ^(NSError *error){
            weakSelf.meterObserver.audioQueue = nil;
            [[[UIAlertView alloc]initWithTitle:[MQBundleUtil localizedStringForKey:@"record_error"] message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:[MQBundleUtil localizedStringForKey:@"user_confirm"], nil]show];
        };
        
        recorder.bufferDurationSeconds = 0.25;
        recorder.fileWriterDelegate = self.amrWriter;
        recorder.delegate = self;
        self.recorder = recorder;
        
        //音频变化的系统通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionDidChangeInterruptionType:)
                                                     name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    }
    return self;
}

- (void)audioSessionDidChangeInterruptionType:(NSNotification *)notification{
    AVAudioSessionInterruptionType interruptionType = [[[notification userInfo]
                                                        objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (AVAudioSessionInterruptionTypeBegan == interruptionType){
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didBeginRecording)]) {
                [self.delegate didBeginRecording];
            }
        }
    }
    else if (AVAudioSessionInterruptionTypeEnded == interruptionType){
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didEndRecording)]) {
                [self.delegate didEndRecording];
            }
        }
    }
}

- (void)beginRecording {
    if (self.recorder.isRecording) {
        return ;
    }
    [self.recorder startRecording];
    self.meterObserver.audioQueue = self.recorder->_audioQueue;
}

- (void)cancelRecording {
    if (self.recorder.isRecording) {
        //取消录音
        isCancelRecording = true;
        [self.recorder stopRecording];
    }
}

- (void)setRecordMode:(MQRecordMode)recordMode {
    self.recorder.recordMode = recordMode;
}

- (MQRecordMode)recordMode {
    return self.recorder.recordMode;
}

- (void)setKeepSessionActive:(BOOL)keepSessionActive {
    self.recorder.keepSessionActive = keepSessionActive;
}

- (BOOL)keepSessionActive {
    return self.recorder.keepSessionActive;
}

- (BOOL)isRecording {
    return self.recorder.isRecording;
}

- (void)finishRecording {
    if (self.recorder.isRecording) {
        //取消录音
        [self.recorder stopRecording];
    }
}

- (void)didFinishRecord {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didFinishRecordingWithAMRFilePath:)]) {
            if (isCancelRecording) {
                isCancelRecording = false;
                return ;
            }
            [self.delegate didFinishRecordingWithAMRFilePath:self.amrWriter.filePath];
        }
    }
}

#pragma MLAudioRecorderDelegate
- (void)recordError:(NSError *)error {
    
}

- (void)recordStopped {
    [self didFinishRecord];
}


@end
