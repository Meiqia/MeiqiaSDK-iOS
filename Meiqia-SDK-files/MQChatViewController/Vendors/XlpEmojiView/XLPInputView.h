//
//  XLPInputView.h
//  Meiqia-SDK-Demo
//
//  Created by xulianpeng on 2018/1/10.
//  Copyright © 2018年 Meiqia. All rights reserved.
//

#import <UIKit/UIKit.h>

#define emojikeyboardHeight 260
#define bottomHeight 30 // 底部按钮的高度
#define emojCellWidth  54
#define emojCellHeight 42
#define emojiBackColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]

@protocol XLPInputViewDelegate  <NSObject>

@optional
- (void)XLPInputViewObtainEmojiStr:(NSString *)emojiStr;
- (void)XLPInputViewDeleteEmoji;
- (void)XLPInputViewSendEmoji;

@end
@interface XLPInputView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,weak)id<XLPInputViewDelegate>xlpInputViewDelegate;

@end
