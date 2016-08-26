//
//  MQBotMenuAnswerCellModel.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/24.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQBotMenuAnswerCellModel.h"
#import "MQBotAnswerMessage.h"
#import "MQBotMenuAnswerCell.h"
#import "MQBotMenuCellModel.h" //
#import "MQServiceToViewInterface.h"

@interface MQBotMenuAnswerCellModel()

@property (nonatomic, strong) MQBotAnswerMessage *message;

@end

@implementation MQBotMenuAnswerCellModel

- (instancetype)initCellModelWithMessage:(MQBotAnswerMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator {
 
    if (self = [super init]) {
        self.message = message;
        self.content = message.content;
        self.messageId = message.messageId;
        self.menuFootnote = kMQBotMenuTipText;
        self.menuTitle = message.menu.content;
        self.menus = message.menu.menu;
        self.isEvaluated = message.isEvaluated;
        
        __weak typeof(self)wself = self;
        [MQServiceToViewInterface downloadMediaWithUrlString:message.userAvatarPath progress:nil completion:^(NSData *mediaData, NSError *error) {
            if (mediaData) {
                __strong typeof (wself) sself = wself;
                sself.avatarImage = [UIImage imageWithData:mediaData];
                if (sself.avatarLoaded) {
                    sself.avatarLoaded(sself.avatarImage);
                }
            }
        }];
    }
    
    return self;
}


#pragma mark - delegate

- (CGFloat)getCellHeight {

    if (self.provoideCellHeight) {
        return self.provoideCellHeight();
    } else {
        return 200;
    }
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (MQChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MQBotMenuAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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

- (void)didEvaluate {
    self.isEvaluated = YES;
}

@end
