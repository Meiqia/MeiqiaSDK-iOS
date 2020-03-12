//
//  XLPInputView.m
//  Meiqia-SDK-Demo
//
//  Created by xulianpeng on 2018/1/10.
//  Copyright © 2018年 Meiqia. All rights reserved.
//

#import "XLPInputView.h"
#import "XlpEmojiCell.h"
#import "MQAssetUtil.h"
#import "MQUIMaker.h"
#import "MQBundleUtil.h"



@implementation XLPInputView
{
    UICollectionView * emojiCollectionView;
    NSDictionary *emojiDic; //表情数据源
    NSMutableArray *bottomBtArr;//底部按钮数组
    UIButton * deleteBt;
    UIButton * returnBt;
}
//表情键盘的UI布局
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        bottomBtArr = [NSMutableArray new];
        [self obtainEmojis];
        [self layoutViewWithFrame:frame];
        [self layoutBottomBt];
    }
    return self;
}
- (void)obtainEmojis{
    
    NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
    NSString * fileRootPath = [[selfBundle bundlePath] stringByAppendingString:@"/MQChatViewAsset.bundle"];
    NSString * filePath = [fileRootPath stringByAppendingString:@"/MQEmojisList.plist"];
    emojiDic = [[NSDictionary dictionaryWithContentsOfFile:filePath] copy];
}
- (void)layoutViewWithFrame:(CGRect)frame{
    
    //初始化emojiCollectionView
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(emojCellWidth, emojCellHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    emojiCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0,frame.size.width, emojikeyboardHeight - bottomHeight) collectionViewLayout:layout];
    [self addSubview:emojiCollectionView];
    emojiCollectionView.delegate = self;
    emojiCollectionView.dataSource = self;
    emojiCollectionView.bounces = NO;
    
    emojiCollectionView.backgroundColor = emojiBackColor;
    [emojiCollectionView reloadData];
    [emojiCollectionView registerClass:[XlpEmojiCell class] forCellWithReuseIdentifier:@"XlpEmojiCell"];
}
#pragma mark  设置CollectionView的组数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return emojiDic.allKeys.count;
}

#pragma mark  设置CollectionView每组所包含的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString *key = emojiDic.allKeys[section];
    NSArray *sectionEmojiArr =  [emojiDic objectForKey:key];
    return sectionEmojiArr.count;
    
}

#pragma mark  设置CollectionCell的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XlpEmojiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XlpEmojiCell" forIndexPath:indexPath];
    NSString *key = emojiDic.allKeys[indexPath.section];
    NSArray *sectionEmojiArr =  [emojiDic objectForKey:key];
    NSString * emojiStr = sectionEmojiArr[indexPath.row];
    cell.emojiLabel.text = emojiStr;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *key = emojiDic.allKeys[indexPath.section];
    NSArray *sectionEmojiArr =  [emojiDic objectForKey:key];
    NSString * emojiStr = sectionEmojiArr[indexPath.row];
    if (self.xlpInputViewDelegate && [self.xlpInputViewDelegate respondsToSelector:@selector(XLPInputViewObtainEmojiStr:)]) {
        [self.xlpInputViewDelegate XLPInputViewObtainEmojiStr:emojiStr];
    }
}

- (void)layoutBottomBt{
    
    CGFloat mmWidth = 50;
    CGFloat aWidth = (self.frame.size.width - mmWidth * 2) / emojiDic.allKeys.count;
    
    deleteBt = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBt.frame = CGRectMake(0, emojikeyboardHeight - bottomHeight,mmWidth, bottomHeight);
    [self addSubview:deleteBt];
    [deleteBt setTitle:[MQBundleUtil localizedStringForKey:@"mq_delete"] forState:UIControlStateNormal];
    [deleteBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    deleteBt.titleLabel.font = [UIFont systemFontOfSize:14];
    [deleteBt addTarget:self action:@selector(deleteHandle:) forControlEvents:UIControlEventTouchUpInside];
    
    returnBt = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBt.frame = CGRectMake(self.frame.size.width - mmWidth, emojikeyboardHeight - bottomHeight,mmWidth, bottomHeight);
    [self addSubview:returnBt];
    [returnBt setTitle:[MQBundleUtil localizedStringForKey:@"mq_send"] forState:UIControlStateNormal];
    [returnBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    returnBt.titleLabel.font = [UIFont systemFontOfSize:14];
    [returnBt addTarget:self action:@selector(returnHandle:) forControlEvents:UIControlEventTouchUpInside];
    
    for (int i = 0;i < emojiDic.allKeys.count;i ++) {

        NSString *imageStr = [self obtainImageStrWithKey:emojiDic.allKeys[i]];
        UIImage *image = [MQAssetUtil imageFromBundleWithName:imageStr];
        UIButton *bt =  [MQUIMaker xlpInitWithFrame:CGRectMake(mmWidth + (aWidth * i), emojikeyboardHeight - bottomHeight,aWidth, bottomHeight) image:image backImage:nil corner:0 superView:self touchUpInside:nil];
        bt.tag = i + 10;
        [bt addTarget:self action:@selector(btHandle:) forControlEvents:UIControlEventTouchUpInside];
        [bottomBtArr addObject:bt];
    }
    [self bottomBtSelectHandle:10];
}

- (NSString *)obtainImageStrWithKey:(NSString *)keyStr{
    NSArray *imageStrArr = [NSArray arrayWithObjects:@"AGEmojiPeople",@"AGEmojiObjects",@"AGEmojiAnimals",@"AGEmojiPlaces",@"AGEmojiSymbols", nil];

    for (NSString *str in imageStrArr) {
        
        if ([str containsString:keyStr]) {
            
            return str;
        }
    }
    return @"";
}
- (void)btHandle:(UIButton *)bt{
    
    int mmmm = [[NSNumber numberWithInteger:bt.tag] intValue];
    [self scrollToGroup:mmmm];
    [self bottomBtSelectHandle:mmmm];
}
- (void)bottomBtSelectHandle:(int)index{
    
    if (bottomBtArr.count > 0) {
        
        for (UIButton *abt in bottomBtArr) {
            if (abt.tag - index == 0) {

                abt.alpha = 1.0;
                abt.selected = true;
                abt.backgroundColor = emojiBackColor;
            }else{
                abt.alpha = 0.4;
                abt.selected = false;
                abt.backgroundColor = [UIColor whiteColor];
            }
        }
    }
    
}
- (void)scrollToGroup:(int)section{
    
    NSIndexPath *indexPath =  [NSIndexPath indexPathForItem:5 inSection:(section - 10)];
    [emojiCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSMutableArray *arr = [NSMutableArray new];
    arr = [[emojiCollectionView indexPathsForVisibleItems] mutableCopy];
    if (arr.count > 0) {

        NSIndexPath *lastIndex = arr.lastObject;
        [self bottomBtSelectHandle:(int)lastIndex.section + 10];

    }
}


- (void)returnHandle:(UIButton *)bt{
    if (self.xlpInputViewDelegate && [self.xlpInputViewDelegate respondsToSelector:@selector(XLPInputViewSendEmoji)]) {
        
        [self.xlpInputViewDelegate XLPInputViewSendEmoji];
    }
}
- (void)deleteHandle:(UIButton *)bt{
    if (self.xlpInputViewDelegate && [self.xlpInputViewDelegate respondsToSelector:@selector(XLPInputViewDeleteEmoji)]) {
        
        [self.xlpInputViewDelegate XLPInputViewDeleteEmoji];
    }
}
@end
