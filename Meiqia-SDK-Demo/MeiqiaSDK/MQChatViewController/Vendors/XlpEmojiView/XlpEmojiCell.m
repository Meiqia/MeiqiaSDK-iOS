//
//  XlpEmojiCell.m
//  Meiqia-SDK-Demo
//
//  Created by xulianpeng on 2018/1/10.
//  Copyright © 2018年 Meiqia. All rights reserved.
//

#import "XlpEmojiCell.h"

@implementation XlpEmojiCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.emojiLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 45, 35)];
        [self.contentView addSubview:self.emojiLabel];
        self.emojiLabel.font = [UIFont systemFontOfSize:30];
        
    }
    return self;
}
@end
