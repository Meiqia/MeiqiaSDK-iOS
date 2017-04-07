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
#import "MQFileDownloadMessage.h"
#import "MQRichTextMessage.h"

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
            toMessage = richTextMessage;
            break;
        }
        default:
            break;
    }
    toMessage.messageId = plainMessage.messageId;
    toMessage.date = plainMessage.createdOn;
    toMessage.userName = plainMessage.messageUserName;
    toMessage.userAvatarPath = plainMessage.messageAvatar;
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

@end
