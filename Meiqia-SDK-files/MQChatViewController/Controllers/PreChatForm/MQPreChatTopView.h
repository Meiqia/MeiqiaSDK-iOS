//
//  MQPreChatTopView.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2023/3/1.
//  Copyright © 2023 MeiQia Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MQPreChatTopView : UIView

- (instancetype)initWithHTMLText:(NSString *)text maxWidth:(CGFloat)maxWidth;

- (CGFloat)getTopViewHeight;

@end

NS_ASSUME_NONNULL_END
