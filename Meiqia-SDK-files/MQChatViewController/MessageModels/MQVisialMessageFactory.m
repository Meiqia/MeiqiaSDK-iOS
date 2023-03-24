//
//  MQVisialMessageFactory.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 2016/11/17.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQVisialMessageFactory.h"
#import "MQTextMessage.h"
#import "MQImageMessage.h"
#import "MQVoiceMessage.h"
#import "MQCardMessage.h"
#import "MQFileDownloadMessage.h"
#import "MQRichTextMessage.h"
#import "MQWithDrawMessage.h"
#import "MQPhotoCardMessage.h"
#import "MQProductCardMessage.h"
#import "MQJsonUtil.h"
#import "MQVideoMessage.h"
#import "MQServiceToViewInterface.h"


@implementation MQVisialMessageFactory

- (MQBaseMessage *)createMessage:(MQMessage *)plainMessage {
    MQBaseMessage *toMessage;
    switch (plainMessage.contentType) {
        case MQMessageContentTypeBot: {
            // was handled by MQBotMessageFactory
            return nil;
        }
        case MQMessageContentTypeText: {
            MQTextMessage *textMessage = [[MQTextMessage alloc] initWithContent:plainMessage.content];
            textMessage.isSensitive = plainMessage.isSensitive;
            textMessage.tags = [self getMessageBottomTagModel:plainMessage];
            toMessage = textMessage;
            break;
        }
        case MQMessageContentTypeImage: {
            MQImageMessage *imageMessage = [[MQImageMessage alloc] initWithImagePath:plainMessage.content];
            toMessage = imageMessage;
            break;
        }
        case MQMessageContentTypeVoice: {
            MQVoiceMessage *voiceMessage = [[MQVoiceMessage alloc] initWithVoicePath:plainMessage.content];
            [voiceMessage handleAccessoryData:plainMessage.accessoryData];
            toMessage = voiceMessage;
            break;
        }
        case MQMessageContentTypeFile: {
            MQFileDownloadMessage *fileDownloadMessage = [[MQFileDownloadMessage alloc] initWithDictionary:plainMessage.accessoryData];
            toMessage = fileDownloadMessage;
            break;
        }
        case MQMessageContentTypeRichText: {
            MQRichTextMessage *richTextMessage = [[MQRichTextMessage alloc] initWithDictionary:plainMessage.accessoryData];
            richTextMessage.tags = [self getMessageBottomTagModel:plainMessage];
            toMessage = richTextMessage;
            break;
        }
        case MQMessageContentTypeCard: {
            MQCardMessage *cardMessage = [[MQCardMessage alloc] init];
            cardMessage.cardData = plainMessage.cardData;
            toMessage = cardMessage;
            break;
        }
        case MQMessageContentTypeHybrid: {
            toMessage = [self messageFromContentTypeHybrid:plainMessage toMQBaseMessage:toMessage];
            break;
        }
        case MQMessageContentTypeVideo: {
            MQVideoMessage *videoMessage = [[MQVideoMessage alloc] initWithVideoServerPath:plainMessage.content];
            [videoMessage handleAccessoryData:plainMessage.accessoryData];
            toMessage = videoMessage;
            break;
        }
        default:
            break;
    }
    // 消息撤回
    if (plainMessage.isMessageWithDraw) {
        MQWithDrawMessage *withDrawMessage = [[MQWithDrawMessage alloc] init];
        withDrawMessage.isMessageWithDraw = plainMessage.isMessageWithDraw;
        withDrawMessage.content = @"消息已被客服撤回";
        toMessage = withDrawMessage;
        if (![MQServiceToViewInterface getEnterpriseConfigWithdrawToastStatus]) {
            return nil;
        }
    }
    toMessage.messageId = plainMessage.messageId;
    toMessage.date = plainMessage.createdOn;
    toMessage.userName = plainMessage.messageUserName;
    toMessage.userAvatarPath = plainMessage.messageAvatar;
    toMessage.conversionId = plainMessage.conversationId;
    switch (plainMessage.sendStatus) {
        case MQMessageSendStatusSuccess:
            toMessage.sendStatus = MQChatMessageSendStatusSuccess;
            break;
        case MQMessageSendStatusFailed:
            toMessage.sendStatus = MQChatMessageSendStatusFailure;
            break;
        case MQMessageSendStatusSending:
            toMessage.sendStatus = MQChatMessageSendStatusSending;
            break;
        default:
            break;
    }
    switch (plainMessage.fromType) {
        case MQMessageFromTypeAgent:
        {
            toMessage.fromType = MQChatMessageIncoming;
            break;
        }
        case MQMessageFromTypeClient:
        {
            toMessage.fromType = MQChatMessageOutgoing;
            break;
        }
        case MQMessageFromTypeBot:
        {
            toMessage.fromType = MQChatMessageIncoming;
            break;
        }
        default:
            break;
    }
    return toMessage;
}

- (MQBaseMessage *)messageFromContentTypeHybrid:(MQMessage *)message toMQBaseMessage:(MQBaseMessage *)baseMessage {
    NSArray *contentArr = [NSArray array];
    contentArr = [MQJsonUtil createWithJSONString:message.content];
    if (contentArr.count > 0) {
        NSDictionary *contentDic = contentArr.firstObject;
        if ([contentDic[@"type"] isEqualToString:@"photo_card"]) {
            MQPhotoCardMessage *photoCard = [[MQPhotoCardMessage alloc] initWithImagePath:contentDic[@"body"][@"pic_url"] andUrlPath:contentDic[@"body"][@"target_url"]];
            baseMessage = photoCard;
        } else if ([contentDic[@"type"] isEqualToString:@"product_card"]) {
            MQProductCardMessage *productCard = [[MQProductCardMessage alloc] initWithPictureUrl:contentDic[@"body"][@"pic_url"] title:contentDic[@"body"][@"title"] description:contentDic[@"body"][@"description"] productUrl:contentDic[@"body"][@"product_url"]  andSalesCount:[contentDic[@"body"][@"sales_count"] longValue]];
            baseMessage = productCard;
        } else if ([contentDic[@"type"] isEqualToString:@"mini_program_card"]) {

        }
    }
    return baseMessage;
}

- (NSArray *)getMessageBottomTagModel:(MQMessage *)message
{
    if (message.accessoryData && [message.accessoryData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDic = [NSDictionary dictionaryWithDictionary:message.accessoryData];
        if ([dataDic objectForKey:@"operator_msg"] && ![[dataDic objectForKey:@"operator_msg"] isEqual:[NSNull null]]) {
            NSArray *tagArr = [dataDic objectForKey:@"operator_msg"];
            NSMutableArray *resultArr = [NSMutableArray array];
            for (NSDictionary * dic in tagArr) {
                [resultArr addObject:[[MQMessageBottomTagModel alloc] initWithDictionary:dic]];
            }
            if (resultArr.count > 0) {
                return resultArr;
            }
        }
    }
    return nil;
}

@end
