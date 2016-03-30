//
//  MQChatViewStyle.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/3/29.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MQAssetUtil.h"

typedef NS_ENUM(NSUInteger, MQChatViewStyleType) {
    MQChatViewStyleTypeDefault,
};

@interface MQChatViewStyle : NSObject

@property (nonatomic, copy) UIColor *incomingMsgTextColor;
@property (nonatomic, copy) UIColor *incomingBubbleColor;
@property (nonatomic, copy) UIColor *outgoingMsgTextColor;
@property (nonatomic, copy) UIColor *outgoingBubbleColor;
@property (nonatomic, copy) UIColor *eventTextColor;
@property (nonatomic, copy) UIColor *redirectAgentNameColor;
@property (nonatomic, copy) UIColor *navTitleColor;
@property (nonatomic, copy) UIColor *navBarTintColor;
@property (nonatomic, copy) UIColor *navBarColor;
@property (nonatomic, copy) UIColor *pullRefreshColor;

@property (nonatomic, strong) UIImage *incomingDefaultAvatarImage;
@property (nonatomic, strong) UIImage *outgoingDefaultAvatarImage;
@property (nonatomic, strong) UIImage *messageSendFailureImage;
@property (nonatomic, strong) UIImage *photoSenderImage;
@property (nonatomic, strong) UIImage *photoSenderHighlightedImage;
@property (nonatomic, strong) UIImage *voiceSenderImage;
@property (nonatomic, strong) UIImage *voiceSenderHighlightedImage;
@property (nonatomic, strong) UIImage *keyboardSenderImage;
@property (nonatomic, strong) UIImage *keyboardSenderHighlightedImage;
@property (nonatomic, strong) UIImage *resignKeyboardImage;
@property (nonatomic, strong) UIImage *resignKeyboardHighlightedImage;
@property (nonatomic, strong) UIImage *incomingBubbleImage;
@property (nonatomic, strong) UIImage *outgoingBubbleImage;
@property (nonatomic, strong) UIImage *imageLoadErrorImage;

@property (nonatomic, assign) UIEdgeInsets bubbleImageStretchInsets;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, copy  ) NSString *incomingMsgSoundFileName;
@property (nonatomic, copy  ) NSString *outgoingMsgSoundFileName;

+ (instancetype)createStyle:(MQChatViewStyle)style;

@end
