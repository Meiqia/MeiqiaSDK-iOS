//
//  MQMQWebViewBubbleCellModel.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQWebViewBubbleCellModel.h"
#import "MQWebViewBubbleCell.h"
#import "MQRichTextMessage.h"
#import "MQServiceToViewInterface.h"

@interface MQWebViewBubbleCellModel()

/**
 * @brief 标签签的tagList
 */
@property (nonatomic, readwrite, strong) MQTagListView *cacheTagListView;
/**
 * @brief 标签的数据源
 */
@property (nonatomic, readwrite, strong) NSArray *cacheTags;

@property (nonatomic, strong)MQRichTextMessage *message;
@property (nonatomic, strong)UIImage *avatarImage;
@property (nonatomic, copy) NSString *avatarPath;

@end

@implementation MQWebViewBubbleCellModel

- (id)initCellModelWithMessage:(MQRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MQCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        self.content = message.content;
        self.avatarPath = message.userAvatarPath;
        if (message.tags) {
            CGFloat maxWidth = cellWidth - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarDiameter - kMQCellAvatarToBubbleSpacing - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing - kMQCellBubbleMaxWidthToEdgeSpacing;
            NSMutableArray *titleArr = [NSMutableArray array];
            for (MQMessageBottomTagModel * model in message.tags) {
                [titleArr addObject:model.name];
            }
            self.cacheTagListView = [[MQTagListView alloc] initWithTitleArray:titleArr andMaxWidth:maxWidth];
            self.cacheTags = message.tags;
        }
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


- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 200;
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
    CGFloat maxWidth = cellWidth - kMQCellAvatarToHorizontalEdgeSpacing - kMQCellAvatarDiameter - kMQCellAvatarToBubbleSpacing - kMQCellBubbleToTextHorizontalLargerSpacing - kMQCellBubbleToTextHorizontalSmallerSpacing - kMQCellBubbleMaxWidthToEdgeSpacing;
    [self.cacheTagListView updateLayoutWithMaxWidth:maxWidth];
}
@end
