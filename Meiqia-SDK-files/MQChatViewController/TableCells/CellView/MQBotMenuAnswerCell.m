//
//  MQBotMenuAnswerCell.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/8/24.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQBotMenuAnswerCell.h"
#import "MQChatViewConfig.h"
#import "MQImageUtil.h"
#import "UIView+MQLayout.h"
#import "MQBotMenuAnswerCellModel.h"

@interface MQBotMenuAnswerCell()

@property (nonatomic, strong) MQBotMenuAnswerCellModel *cellModel;
@property (nonatomic, strong) UIImageView *itemsView;
@property (nonatomic, strong) UIImageView *avatarImageView;

@end

@implementation MQBotMenuAnswerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.itemsView];
        
    }
    return self;
}

- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {

}

#pragma mark - lazy load

- (UIImageView *)itemsView {
    if (!_itemsView) {
        _itemsView = [UIImageView new];
        _itemsView.userInteractionEnabled = true;
        UIImage *bubbleImage = [MQChatViewConfig sharedConfig].incomingBubbleImage;
        if ([MQChatViewConfig sharedConfig].incomingBubbleColor) {
            bubbleImage = [MQImageUtil convertImageColorWithImage:bubbleImage toColor:[MQChatViewConfig sharedConfig].incomingBubbleColor];
        }
        bubbleImage = [bubbleImage resizableImageWithCapInsets:[MQChatViewConfig sharedConfig].bubbleImageStretchInsets];
        _itemsView.image = bubbleImage;
    }
    return _itemsView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.viewSize = CGSizeMake(kMQCellAvatarDiameter, kMQCellAvatarDiameter);
        _avatarImageView.image = [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage;
        if ([MQChatViewConfig sharedConfig].enableRoundAvatar) {
            _avatarImageView.layer.masksToBounds = YES;
            _avatarImageView.layer.cornerRadius = _avatarImageView.viewSize.width/2;
        }
    }
    return _avatarImageView;
}

@end
