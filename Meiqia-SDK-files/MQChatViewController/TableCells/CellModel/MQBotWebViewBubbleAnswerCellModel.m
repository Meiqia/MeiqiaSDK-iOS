//
//  MQBotWebViewBubbleAnswerCellModel.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQBotWebViewBubbleAnswerCellModel.h"
#import "MQBotRichTextMessage.h"
#import "MQBotWebViewBubbleAnswerCell.h"
#import "MQServiceToViewInterface.h"

@interface MQBotWebViewBubbleAnswerCellModel()

@property (nonatomic, strong)MQBotRichTextMessage *message;
@property (nonatomic, strong)UIImage *avatarImage;

@end

@implementation MQBotWebViewBubbleAnswerCellModel

- (id)initCellModelWithMessage:(MQBotRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        self.avatarPath = message.userAvatarPath;
        self.messageId = message.messageId;
        self.content = message.content;
        self.isEvaluated = message.isEvaluated;
        self.content = message.content;
    }
    return self;
}

- (void)bind {
    
    if (self.avatarImage) {
        if (self.avatarLoaded) {
            self.avatarLoaded(self.avatarImage);
        }
    } else {
        [MQServiceToViewInterface downloadMediaWithUrlString:self.avatarPath progress:nil completion:^(NSData *mediaData, NSError *error) {
            if (mediaData) {
                self.avatarImage = [UIImage imageWithData:mediaData];
                if (self.avatarLoaded) {
                    self.avatarLoaded(self.avatarImage);
                }
            }
        }];
    }
}

#pragma mark -

- (void)didEvaluate {
    self.isEvaluated = YES;
}

- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 200;
}

- (MQBotWebViewBubbleAnswerCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MQBotWebViewBubbleAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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
