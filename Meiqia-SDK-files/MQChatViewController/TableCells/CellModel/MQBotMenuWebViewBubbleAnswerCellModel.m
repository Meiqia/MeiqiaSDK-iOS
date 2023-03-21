//
//  MQBotMenuWebViewBubbleAnswerCellModel.m
//  Meiqia-SDK-Demo
//
//  Created by xulianpeng on 2017/9/26.
//  Copyright © 2017年 Meiqia. All rights reserved.
//

#import "MQBotMenuWebViewBubbleAnswerCellModel.h"
#import "MQBotRichTextMessage.h"
#import "MQBotMenuWebViewBubbleAnswerCell.h"
#import "MQServiceToViewInterface.h"
#import "MQBotMenuCellModel.h"
#import "MQBundleUtil.h"

@interface MQBotMenuWebViewBubbleAnswerCellModel()

@property (nonatomic, strong)MQBotRichTextMessage *message;
@property (nonatomic, strong)UIImage *avatarImage;

@end

@implementation MQBotMenuWebViewBubbleAnswerCellModel
- (id)initCellModelWithMessage:(MQBotRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        self.avatarPath = message.userAvatarPath;
        self.messageId = message.messageId;
        self.isEvaluated = message.isEvaluated;
        self.solved = message.solved;
        self.content = message.content;
        
        self.menuTitle = message.menu.content;
        self.menus = message.menu.menu;
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

- (void)didEvaluate:(BOOL)solved {
    self.isEvaluated = YES;
    self.solved = solved;
}

- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 200;
}

- (MQBotMenuWebViewBubbleAnswerCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MQBotMenuWebViewBubbleAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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
