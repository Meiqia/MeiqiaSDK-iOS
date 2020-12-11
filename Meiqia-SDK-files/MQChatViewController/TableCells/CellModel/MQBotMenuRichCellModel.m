//
//  MQBotMenuRichCellModel.m
//  MQEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/6/1.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQBotMenuRichCellModel.h"
#import "MQBotMenuRichMessageCell.h"
#import "MQServiceToViewInterface.h"

@interface MQBotMenuRichCellModel()

@end

@implementation MQBotMenuRichCellModel

- (id)initCellModelWithMessage:(MQBotMenuMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        self.content = message.richContent?:message.content;
        self.avatarPath = message.userAvatarPath;
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

#pragma mark - 代理方法


- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 200;
}

- (MQBotMenuRichMessageCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MQBotMenuRichMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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

- (NSString *)getMessageConversionId {
    return self.message.conversionId;
}

- (void)updateCellSendStatus:(MQChatMessageSendStatus)sendStatus {
    self.message.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.message.messageId = messageId;
}

- (void)updateCellConversionId:(NSString *)conversionId {
    self.message.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.message.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
}
@end
