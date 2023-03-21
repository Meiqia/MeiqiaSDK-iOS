//
//  MQMessageFormChoiceView.m
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/12/7.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import "MQMessageFormChoiceView.h"
#import "MQMessageFormConfig.h"

static CGFloat const kMQMessageFormSpacing   = 16.0;
static CGFloat const kMQMessageFormChoiceItemHeigh   = 50.0;
static CGFloat const kMQMessageFormChoiceItemLeading   = 30.0;
static CGFloat const kMQMessageFormChoiceIconHeigh   = 20.0;

@interface MQMessageFormChoiceView()

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIView *choiceView;

@property (nonatomic, strong) MQMessageFormInputModel *inputModel;

@property (nonatomic, strong) NSMutableArray *choiceItemArr;

@end

@implementation MQMessageFormChoiceView

- (instancetype)initWithModel:(MQMessageFormInputModel *)model {
    self = [super init];
    if (self) {
        self.choiceItemArr = [[NSMutableArray alloc] init];
        self.inputModel = model;
        [self initTipLabelWithModel:model];
        [self initChoiceItemWithModel:model];
    }
    return self;
}

- (void)initTipLabelWithModel:(MQMessageFormInputModel *)model {
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.text = model.tip;
    [self refreshTipLabelFrame];
    self.tipLabel.font = [UIFont systemFontOfSize:14];
    self.tipLabel.textColor = [MQMessageFormConfig sharedConfig].messageFormViewStyle.tipTextColor;
    
    if (model.isRequired) {
        NSString *text = [NSString stringWithFormat:@"%@%@", self.tipLabel.text, @"*"];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedText addAttribute:NSForegroundColorAttributeName value:self.tipLabel.textColor range:NSMakeRange(0, model.tip.length)];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(model.tip.length, 1)];
        self.tipLabel.attributedText = attributedText;
    }
    [self addSubview:self.tipLabel];
}

- (void)initChoiceItemWithModel:(MQMessageFormInputModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.choiceView = [[UIView alloc] init];
    self.choiceView.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < model.metainfo.count; i++) {
        NSString *content = model.metainfo[i];
        MQMessageFormChoiceItem *item = [[MQMessageFormChoiceItem alloc] initWithItemContent:content];
        item.frame = CGRectMake(0, i * kMQMessageFormChoiceItemHeigh, screenWidth, kMQMessageFormChoiceItemHeigh);
        item.tag = 1000 + i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choiceItemWith:)];
        [item addGestureRecognizer:tap];
        [self.choiceView addSubview:item];
        [self.choiceItemArr addObject:item];
    }
    self.choiceView.frame = CGRectMake(0, CGRectGetMaxY(self.tipLabel.frame), screenWidth, kMQMessageFormChoiceItemHeigh * self.choiceItemArr.count);
    [self addSubview:self.choiceView];
}

- (void)refreshChoiceItemFrame {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.choiceView.frame = CGRectMake(0, CGRectGetMaxY(self.tipLabel.frame), screenWidth, kMQMessageFormChoiceItemHeigh * self.choiceItemArr.count);
    for (int i = 0; i < self.choiceItemArr.count; i++) {
        MQMessageFormChoiceItem *item = self.choiceItemArr[i];
        [item refreshFrame];
        item.frame = CGRectMake(0, i * kMQMessageFormChoiceItemHeigh, screenWidth, kMQMessageFormChoiceItemHeigh);
    }
}

- (void)refreshTipLabelFrame {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    [self.tipLabel sizeToFit];
    self.tipLabel.frame = CGRectMake(kMQMessageFormSpacing, kMQMessageFormSpacing, screenWidth - kMQMessageFormSpacing * 2, self.tipLabel.frame.size.height + kMQMessageFormSpacing / 2);
}

- (void)refreshFrameWithScreenWidth:(CGFloat)screenWidth andY:(CGFloat)y {
    [super refreshFrameWithScreenWidth:screenWidth andY:y];
    
    [self refreshTipLabelFrame];
    [self refreshChoiceItemFrame];
    self.frame = CGRectMake(0, y, screenWidth, CGRectGetMaxY(self.choiceView.frame));
}

- (void)choiceItemWith:(UITapGestureRecognizer *)sender {
    NSInteger tag = sender.view.tag;
    MQMessageFormChoiceItem *item = [self viewWithTag:tag];
    if (self.inputModel.inputModelType == InputModelTypeSingleChoice) {
        for (int i = 0; i < self.choiceItemArr.count; i++) {
            MQMessageFormChoiceItem *tempItem = self.choiceItemArr[i];
            if (tempItem == item) {
                tempItem.isChoice = YES;
            } else {
                tempItem.isChoice = NO;
            }
        }
    } else {
        item.isChoice = !item.isChoice;
    }
}

- (id)getContentValue {
    if (self.inputModel.inputModelType == InputModelTypeSingleChoice) {
        for (MQMessageFormChoiceItem *item in self.choiceItemArr) {
            if (item.isChoice) {
                return [item getItemValue];
            }
        }
        return @"";
    } else {
        NSMutableArray *arr = [NSMutableArray array];
        for (MQMessageFormChoiceItem *item in self.choiceItemArr) {
            if (item.isChoice) {
                [arr addObject:[item getItemValue]];
            }
        }
        return arr;
    }
}

@end



@interface MQMessageFormChoiceItem()

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) MQMessageFormInputModel *inputModel;

@property (nonatomic, copy) NSString *content;

@end

@implementation MQMessageFormChoiceItem

- (instancetype)initWithItemContent:(NSString *)content {
    self = [super init];
    if (self) {
        self.content = content;
        [self initContentSubViewsWith:content];
        [self refreshFrame];
        self.isChoice = NO;
    }
    return self;
}

- (void)initContentSubViewsWith:(NSString *)content {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [MQMessageFormConfig sharedConfig].messageFormViewStyle.unselectedImage;
    [self addSubview:self.imageView];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.textColor = [MQMessageFormConfig sharedConfig].messageFormViewStyle.contentTextColor;
    self.contentLabel.text = content;
    [self addSubview:self.contentLabel];
}

- (void)refreshFrame {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.imageView.frame = CGRectMake(kMQMessageFormChoiceItemLeading, kMQMessageFormSpacing, kMQMessageFormChoiceIconHeigh, kMQMessageFormChoiceIconHeigh);
    self.contentLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame)+ kMQMessageFormSpacing, kMQMessageFormSpacing, screenWidth - CGRectGetMaxY(self.imageView.frame) -  2 *kMQMessageFormSpacing, kMQMessageFormChoiceIconHeigh);
}

- (void)setIsChoice:(BOOL)isChoice{
    _isChoice = isChoice;
    if (isChoice) {
        self.imageView.image = [MQMessageFormConfig sharedConfig].messageFormViewStyle.selectedImage;
    } else {
        self.imageView.image = [MQMessageFormConfig sharedConfig].messageFormViewStyle.unselectedImage;
    }
}

- (NSString *)getItemValue {
    return self.content;
}

@end
