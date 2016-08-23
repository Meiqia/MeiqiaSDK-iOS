//
//  MQPreChatCells.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/7/7.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQPreChatCells.h"
#import "MQChatViewStyle.h"

@implementation MQPreChatSelectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSelectionStyle:(UITableViewCellSelectionStyleNone)];
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.textColor = [UIColor colorWithHexString:ebonyClay];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end

#pragma mark -

@implementation MQPrechatSingleLineTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textField = [[UITextField alloc] init];
        self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textField.delegate = self;
        self.textField.font = [UIFont systemFontOfSize:14];
        self.textField.textColor = [UIColor colorWithHexString:ebonyClay];
        self.textField.placeholder = @"输入";
        self.textField.viewWidth = self.contentView.viewWidth - 20;
        self.textField.viewHeight = self.viewHeight;
        [self.textField align:(ViewAlignmentMiddleLeft) relativeToPoint:CGPointMake(10, self.viewHeight / 2)];
        [self.contentView addSubview:self.textField];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([resultString length] < TextFieldLimit) {
        if (self.valueChangedAction) {
            self.valueChangedAction(resultString.length > 0 ? resultString : nil);
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (self.valueChangedAction) {
        self.valueChangedAction(textField.text);
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.valueChangedAction) {
        self.valueChangedAction(textField.text);
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if ((int)textField.keyboardType == -1) { //gender
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
        view.backgroundColor = [UIColor redColor];
        textField.inputAccessoryView = [self genderButtonsView];
    } else {
        textField.inputAccessoryView = nil;
    }
    
    return YES;
}

- (UIView *)genderButtonsView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:247/255.0 alpha:1];
    UIButton *maleButton = [self createButtonWithTitle:@"男"];
    UIButton *femalButton = [self createButtonWithTitle:@"女"];
    CGRect rect = femalButton.frame;
    rect.origin.x = 60;
    femalButton.frame = rect;
    [view addSubview:maleButton];
    [view addSubview:femalButton];
    
    return view;
}

- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    [button setTitle:title forState:(UIControlStateNormal)];
    [button setTitleColor:[UIColor darkGrayColor] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(fillTextWithButtonTitle:) forControlEvents:(UIControlEventTouchUpInside)];
    return button;
}

- (void)fillTextWithButtonTitle:(UIButton *)sender {
    self.textField.text = [sender titleForState:(UIControlStateNormal)];
    if (self.valueChangedAction) {
        self.valueChangedAction(self.textField.text);
    }
}

@end

#pragma mark -

@implementation MQPreChatMultiLineTextCell

- (instancetype)init {
    if (self = [super init]) {
        self.textView = [[UITextView alloc] init];
        [self.contentView addSubview:self.textView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

@end

#pragma mark -

@implementation MQPreChatCaptchaCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textField = [[UITextField alloc] init];
        self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textField.placeholder = @"输入";
        [self.textField setKeyboardType:(UIKeyboardTypeASCIICapable)];
        self.textField.font = [UIFont systemFontOfSize:14];
        self.textField.textColor = [UIColor colorWithHexString:ebonyClay];
        self.textField.viewWidth = self.contentView.viewWidth - 20;
        self.textField.viewHeight = self.viewHeight;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.delegate = self;
        [self.textField align:(ViewAlignmentMiddleLeft) relativeToPoint:CGPointMake(10, self.viewHeight / 2)];
        [self.contentView addSubview:self.textField];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.refreshCapchaButton = [UIButton new];
        self.refreshCapchaButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.refreshCapchaButton.viewSize = CGSizeMake(100, 40);
        self.accessoryView = self.refreshCapchaButton;
        [self.refreshCapchaButton addTarget:self action:@selector(refreshCaptchaButtonTapped) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return self;
}

- (void)refreshCaptchaButtonTapped {
    if (self.loadCaptchaAction) {
        self.loadCaptchaAction(self.refreshCapchaButton);
        self.textField.text = @"";
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([resultString length] < TextFieldLimit) {
        if (self.valueChangedAction) {
            self.valueChangedAction(resultString.length > 0 ? resultString : nil);
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

#pragma mark -

@implementation MQPreChatSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.titelLabel = [UILabel new];
    self.typeLabel = [UILabel new];
    self.isOptionalLabel = [UILabel new];
    self.isOptionalLabel.textColor = [UIColor redColor];
    [self addSubview:self.titelLabel];
    [self addSubview:self.typeLabel];
    [self addSubview:self.isOptionalLabel];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tintColor = [UIColor colorWithHexString:silver];
}

- (void)setStatus:(BOOL)isReady {
    self.shouldMark = !isReady;
    [self updateUI];
    self.shouldMark = NO;
}

- (void)setShouldMark:(BOOL)shouldMark {
    self.tintColor = shouldMark ? [UIColor redColor] : [UIColor colorWithHexString:silver];
}

- (void)updateUI {
    UIFont *font = [UIFont systemFontOfSize:14];
    
    self.titelLabel.text = self.formItem.displayName;
    self.titelLabel.textColor = self.tintColor;
    self.titelLabel.font = font;
    [self.titelLabel sizeToFit];
    self.typeLabel.text = self.formItem.type == MQPreChatFormItemInputTypeMultipleSelection ? @"(多选)" : @"";
    self.typeLabel.font = font;
    self.typeLabel.textColor = self.tintColor;
    [self.typeLabel sizeToFit];
    self.isOptionalLabel.text = self.formItem.isOptional.boolValue ? @"" : @"*";
    [self.isOptionalLabel sizeToFit];
    
    [self.titelLabel align:(ViewAlignmentMiddleLeft) relativeToPoint:CGPointMake(10, self.viewHeight / 2)];
    [self.typeLabel align:ViewAlignmentMiddleLeft relativeToPoint:CGPointMake(self.titelLabel.viewRightEdge + 10, self.viewHeight / 2)];
    [self.isOptionalLabel align:ViewAlignmentMiddleLeft relativeToPoint:CGPointMake(self.typeLabel.viewRightEdge, self.viewHeight / 2)];
}

- (void)setFormItem:(MQPreChatFormItem *)formItem {
    _formItem = formItem;
    [self updateUI];
}

@end
