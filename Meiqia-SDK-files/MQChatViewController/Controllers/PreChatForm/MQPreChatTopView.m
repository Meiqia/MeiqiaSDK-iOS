//
//  MQPreChatTopView.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2023/3/1.
//  Copyright © 2023 MeiQia Inc. All rights reserved.
//

#import "MQPreChatTopView.h"
#import "TTTAttributedLabel.h"
#import "MQStringSizeUtil.h"

@interface MQPreChatTopView()<TTTAttributedLabelDelegate>

@property (nonatomic, strong) TTTAttributedLabel * attributedLabel;
@property (nonatomic, assign) CGFloat cacheMaxWidth;
@property (nonatomic, assign) CGFloat cacheContentHeight;
@property (nonatomic, copy) NSString *content;

@end

@implementation MQPreChatTopView

- (instancetype)initWithHTMLText:(NSString *)text maxWidth:(CGFloat)maxWidth {
    if (self = [super init]) {
        self.cacheMaxWidth = maxWidth;
        self.content = text;
        self.cacheContentHeight = [MQStringSizeUtil getHeightForAttributedText:[self getAttributedText] textWidth:maxWidth];
        
        self.attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, maxWidth, self.cacheContentHeight)];
        self.attributedLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber;
        self.attributedLabel.delegate = self;
        self.attributedLabel.numberOfLines = 0;
        self.attributedLabel.textAlignment = NSTextAlignmentLeft;
        self.attributedLabel.userInteractionEnabled = YES;
        self.attributedLabel.backgroundColor = [UIColor clearColor];
        [self.attributedLabel setText:[self getAttributedText]];
        
        [self addSubview:self.attributedLabel];
    }
    return self;
}

- (NSAttributedString *)getAttributedText {
    NSString *str = [NSString stringWithFormat:@"<head><style>img{width:%f !important;height:auto}p{font-size:%dpx}</style></head>%@",self.cacheMaxWidth,14,self.content];
    return [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
}

-(CGFloat)getTopViewHeight {
    return self.cacheContentHeight;
}

#pragma TTTAttributedLabelDelegate 点击事件

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    NSString *urlStr = [url absoluteString];
    if ([urlStr rangeOfString:@"://"].location == NSNotFound) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlStr]]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]]];
}

@end
