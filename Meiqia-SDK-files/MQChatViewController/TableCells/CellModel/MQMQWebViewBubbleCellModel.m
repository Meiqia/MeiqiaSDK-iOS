//
//  MQMQWebViewBubbleCellModel.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQMQWebViewBubbleCellModel.h"
#import "MQWebViewBubbleCell.h"
#import "MQTextMessage.h"

@interface MQMQWebViewBubbleCellModel()

@property (nonatomic, strong)MQTextMessage *message;

@end

@implementation MQMQWebViewBubbleCellModel

- (id)initCellModelWithMessage:(MQTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
    }
    return self;
}

#pragma mark -


- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 80;
}

- (MQWebViewBubbleCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MQWebViewBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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
