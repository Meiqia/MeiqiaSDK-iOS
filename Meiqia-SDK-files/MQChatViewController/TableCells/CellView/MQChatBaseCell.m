//
//  MQChatBaseCell.m
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import "MQChatBaseCell.h"
#import "MQChatFileUtil.h"
#import "MQChatViewConfig.h"
#import "MQBundleUtil.h"
#import <Photos/Photos.h>

@implementation MQChatBaseCell {
    NSString *copiedText;
    UIImage *copiedImage;
    NSString *copiedVideoPath;
    NSString *copiedVideoServerPath;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.incomingBubbleImage = [MQChatViewConfig sharedConfig].incomingBubbleImage;
        self.outgoingBubbleImage = [MQChatViewConfig sharedConfig].outgoingBubbleImage;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setCellFrame:(CGRect)cellFrame {
    self.contentView.frame = cellFrame;
}

#pragma MQChatCellProtocol
- (void)updateCellWithCellModel:(id<MQCellModelProtocol>)model {
    NSAssert(NO, @"MQChatBaseCell的子类没有实现updateCellWithCellModel的协议方法");
}

#pragma 显示menu的方法
- (void)showMenuControllerInView:(UIView *)inView
                      targetRect:(CGRect)targetRect
                   menuItemsName:(NSDictionary *)menuItemsName
{
    [self becomeFirstResponder];
    //判断menuItem都有哪些
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    if ([menuItemsName[@"textCopy"] isKindOfClass:[NSString class]]) {
        copiedText = menuItemsName[@"textCopy"];
        UIMenuItem *copyTextItem = [[UIMenuItem alloc] initWithTitle:[MQBundleUtil localizedStringForKey:@"save_text"] action:@selector(copyTextSender:)];
        [menuItems addObject:copyTextItem];
    }
    if ([menuItemsName[@"imageCopy"] isKindOfClass:[UIImage class]]) {
        copiedImage = menuItemsName[@"imageCopy"];
        UIMenuItem *copyImageItem = [[UIMenuItem alloc] initWithTitle:[MQBundleUtil localizedStringForKey:@"save_photo"] action:@selector(copyImageSender:)];
        [menuItems addObject:copyImageItem];
    }
    if ([menuItemsName[@"videoCopy"] isKindOfClass:[NSString class]]) {
        copiedVideoPath = menuItemsName[@"videoCopy"];
        copiedVideoServerPath = menuItemsName[@"videoServerPath"];
        UIMenuItem *copyVideoItem = [[UIMenuItem alloc] initWithTitle:[MQBundleUtil localizedStringForKey:@"save_photo"] action:@selector(copyVideoSender:)];
        [menuItems addObject:copyVideoItem];
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:menuItems];
    [menu setTargetRect:targetRect inView:inView];
    [menu setMenuVisible:YES animated:YES];
    
}


#pragma mark 剪切板代理方法
-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copyTextSender:)) {
        return true;
    } else if (action == @selector(copyImageSender:)) {
        return true;
    } else if (action == @selector(copyVideoSender:)) {
        return true;
    } else {
        return false;
    }
}

-(void)copyTextSender:(id)sender {
    UIPasteboard *pasteboard=[UIPasteboard generalPasteboard];
    if (copiedText && copiedText.length > 0) {
        pasteboard.string = copiedText;
        [self.chatCellDelegate showToastViewInCell:self toastText:[MQBundleUtil localizedStringForKey:@"save_text_success"]];
    }
}

-(void)copyImageSender:(id)sender {
    UIImageWriteToSavedPhotosAlbum(copiedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

//保存到相册的回调
- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    if(error != NULL){
        [self.chatCellDelegate showToastViewInCell:self toastText:[MQBundleUtil localizedStringForKey:@"save_photo_error"]];
    }else{
        [self.chatCellDelegate showToastViewInCell:self toastText:[MQBundleUtil localizedStringForKey:@"save_photo_success"]];
    }
}

-(void)copyVideoSender:(id)sender {
    if (copiedVideoPath.length > 0 && [MQChatFileUtil fileExistsAtPath:copiedVideoPath isDirectory:NO]) {
        [self saveVideoToAlbumWithPath:copiedVideoPath];
    } else if (copiedVideoServerPath.length > 0) {
        NSString *cachePath = [MQChatFileUtil getVideoCachePathWithServerUrl:copiedVideoServerPath];
        if ([MQChatFileUtil fileExistsAtPath:cachePath isDirectory:NO]) {
            [self saveVideoToAlbumWithPath:cachePath];
            return;
        }
        // 提示正在下载
        [self.chatCellDelegate showToastViewInCell:self toastText:[MQBundleUtil localizedStringForKey:@"save_video_downloading"]];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *encodedUrlStr = [copiedVideoServerPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSURL *videoURL = [NSURL URLWithString:encodedUrlStr];
            NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (videoData && videoData.length > 0) {
                    [videoData writeToFile:cachePath atomically:YES];
                    [weakSelf saveVideoToAlbumWithPath:cachePath];
                } else {
                    [weakSelf.chatCellDelegate showToastViewInCell:weakSelf toastText:[MQBundleUtil localizedStringForKey:@"save_photo_error"]];
                }
            });
        });
    }
}

- (void)saveVideoToAlbumWithPath:(NSString *)videoPath {
    __weak typeof(self) weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:videoPath]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [weakSelf.chatCellDelegate showToastViewInCell:weakSelf toastText:[MQBundleUtil localizedStringForKey:@"save_video_success"]];
            } else {
                [weakSelf.chatCellDelegate showToastViewInCell:weakSelf toastText:[MQBundleUtil localizedStringForKey:@"save_photo_error"]];
            }
        });
    }];
}



@end
