//
//  MQPreChatCells.h
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/7/7.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+MQLayout.h"
#import "NSArray+MQFunctional.h"
#import <MeiqiaSDK/MeiqiaSDK.h>

#define TextFieldLimit 100

@interface MQPrechatSingleLineTextCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, copy) void(^valueChangedAction)(NSString *);
@property (nonatomic, strong) UITextField *textField;

@end


#pragma mark -

@interface MQPreChatMultiLineTextCell : UITableViewCell

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, copy) void(^heightChanged)(CGFloat);

@end

#pragma mark -

@interface MQPreChatSelectionCell : UITableViewCell

@end

#pragma mark -

@interface MQPreChatCaptchaCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *refreshCapchaButton;
@property (nonatomic, copy) void(^valueChangedAction)(NSString *);
@property (nonatomic, copy) void(^loadCaptchaAction)(UIButton *);

@end

#pragma mark -

@interface MQPreChatSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) MQPreChatFormItem *formItem;
@property (nonatomic, strong) UILabel *titelLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *isOptionalLabel;
@property (nonatomic, assign) BOOL shouldMark;

- (void)setStatus:(BOOL)isReady;

@end

#pragma mark -


