//
//  MQChatEmojize.m
//  MQChatViewControllerDemo
//
//  Created by ijinmao on 15/11/23.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MQChatEmojize.h"

static NSDictionary *_emojiAliases;
static NSDictionary *_emojiToStrAliases;

@implementation MQChatEmojize

- (NSString *)emojizedStringWithString:(NSString *)string
{
    return [self emojizedStringWithString:string];
}

- (NSString *)emojiToStringWithString:(NSString *)string
{
    return [self emojiToStringWithString:string];
}

+ (NSString *)emojiToStringWithString:(NSString*)text
{
    if (!self) return @"";
    
    __block NSString* temp = text;
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        NSString *code = self.emojiToStringAliases[substring];
        if (code) {
            temp = [temp stringByReplacingOccurrencesOfString:substring withString:code];
        }
    }];
    return temp;
}

+ (NSString *)emojizedStringWithString:(NSString *)text
{
    if (!text)
        return @"";
    
    static dispatch_once_t onceToken;
    static NSRegularExpression *regex = nil;
    dispatch_once(&onceToken, ^{
        regex = [[NSRegularExpression alloc] initWithPattern:@"(:[a-z0-9-+_]+:)" options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    
    __block NSString *resultText = text;
    NSRange matchingRange = NSMakeRange(0, [resultText length]);
    [regex enumerateMatchesInString:resultText options:NSMatchingReportCompletion range:matchingRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result && ([result resultType] == NSTextCheckingTypeRegularExpression) && !(flags & NSMatchingInternalError)) {
            NSRange range = result.range;
            if (range.location != NSNotFound) {
                NSString *code = [text substringWithRange:range];
                NSString *unicode = self.emojiAliases[code];
                if (unicode) {
                    resultText = [resultText stringByReplacingOccurrencesOfString:code withString:unicode];
                }
            }
        }
    }];
    return resultText;
}

+ (NSDictionary *)emojiAliases {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emojiAliases = EMOJI_HASH;
    });
    return _emojiAliases;
}

+ (NSDictionary *)emojiToStringAliases {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emojiToStrAliases= [[NSDictionary alloc] initWithObjects:[EMOJI_HASH allKeys] forKeys:[EMOJI_HASH allValues]];
    });
    return _emojiToStrAliases;
}

+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}
@end
