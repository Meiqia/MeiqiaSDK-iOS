//
//  MQChatTableView.m
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/30.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import "MQChatTableView.h"
#import "MQChatViewConfig.h"
#import "MQStringSizeUtil.h"
#import "MQBundleUtil.h"
#import "MQToolUtil.h"

static CGFloat const kMQChatScrollBottomDistanceThreshold = 128.0;

@interface MQChatTableView()

@end

@implementation MQChatTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    
    //xlp 适配iphonex todo
    if (MQToolUtil.kXlpObtainDeviceVersionIsIphoneX) {
        CGFloat newHeight = frame.size.height - 34;
        frame.size.height = newHeight;
    }
    
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        UITapGestureRecognizer *tapViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChatTableView:)];
        tapViewGesture.cancelsTouchesInView = false;
        self.userInteractionEnabled = true;
        [self addGestureRecognizer:tapViewGesture];
    }
    return self;
}

- (void)updateTableViewAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self numberOfRowsInSection:0]) {
        [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

/** 点击tableView的事件 */
- (void)tapChatTableView:(id)sender {
    if (self.chatTableViewDelegate) {
        if ([self.chatTableViewDelegate respondsToSelector:@selector(didTapChatTableView:)]) {
            [self.chatTableViewDelegate didTapChatTableView:self];
        }
    }
}

- (void)scrollToCellIndex:(NSInteger)index {
    if ([self numberOfRowsInSection:0] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (BOOL)isTableViewScrolledToBottom {
    if(self.contentOffset.y + self.frame.size.height + kMQChatScrollBottomDistanceThreshold > self.contentSize.height){
        return true;
    } else {
        return false;
    }
}

@end
