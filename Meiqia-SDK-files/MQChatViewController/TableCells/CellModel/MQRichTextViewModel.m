//
//  MQRichTextViewModel.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQRichTextViewModel.h"
#import "MQRichTextMessage.h"
#import "MQRichTextViewCell.h"
#import "MQServiceToViewInterface.h"
#import "MQWebViewController.h"
#import "MQAssetUtil.h"
#import "MQBotWebViewController.h"
#import "MQBotRichTextMessage.h"

@interface MQRichTextViewModel()

@property (nonatomic, strong) MQRichTextMessage *message;

@end

@implementation MQRichTextViewModel

- (id)initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        self.summary = self.message.summary;
        self.iconPath = self.message.thumbnail;
        self.content = self.message.content;
    }
    return self;
}

//加载 UI 需要的数据，完成后通过 UI 绑定的 block 更新 UI
- (void)load {
    if (self.modelChanges) {
        self.modelChanges(self.message.summary, self.message.thumbnail, self.message.content);
    }
    
    __weak typeof(self)wself = self;
    [MQServiceToViewInterface downloadMediaWithUrlString:self.message.userAvatarPath progress:nil completion:^(NSData *mediaData, NSError *error) {
        if (mediaData) {
            __strong typeof (wself) sself = wself;
            sself.avartarImage = [UIImage imageWithData:mediaData];
            if (sself.avatarLoaded) {
                sself.avatarLoaded(sself.avartarImage);
            }
        }
    }];
    
    [MQServiceToViewInterface downloadMediaWithUrlString:self.message.thumbnail progress:nil completion:^(NSData *mediaData, NSError *error) {
        if (mediaData) {
            __strong typeof (wself) sself = wself;
            sself.iconImage = [UIImage imageWithData:mediaData];
            if (sself.iconLoaded) {
                sself.iconLoaded(sself.iconImage);
            }
        }
    }];
}

- (void)openFrom:(UINavigationController *)cv {
    
    MQWebViewController *webViewController;
    if ([self.message isKindOfClass:[MQBotRichTextMessage class]]) {
        webViewController = [MQBotWebViewController new];
        [(MQBotWebViewController *)webViewController setMessage:(MQBotRichTextMessage *)self.message];
        [(MQBotWebViewController *)webViewController setBotEvaluateDidTapUseful:self.botEvaluateDidTapUseful];
        [(MQBotWebViewController *)webViewController setBotEvaluateDidTapUseless:self.botEvaluateDidTapUseless];
    } else {
        webViewController = [MQWebViewController new];
    }
    
    webViewController.contentHTML = self.content;
    webViewController.title = @"图文消息";
    [cv pushViewController:webViewController animated:YES];
}


#pragma mark - 

- (void)didEvaluate {
    self.isEvaluated = true;
    if ([self.message isKindOfClass:[MQBotRichTextMessage class]]) {
        [(MQBotRichTextMessage *)self.message setIsEvaluated:self.isEvaluated];
    }
}

- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 80;
}

- (MQRichTextViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MQRichTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.message.date;
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (NSString *)getCellMessageId {
    return self.message.messageId;
}

- (void)updateCellSendStatus:(MQChatMessageSendStatus)sendStatus {
    self.message.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.message.messageId = messageId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.message.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
}
@end
