//
//  AGEmojiKeyboardView.m
//  AGEmojiKeyboard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "MQAGEmojiKeyBoardView.h"
#import "MQAGEmojiPageView.h"
#import "UIImage+MQGenerate.h"
#import "MQAssetUtil.h"

static const CGFloat ButtonWidth = 45;
static const CGFloat ButtonHeight = 37;

static const NSUInteger DefaultRecentEmojisMaintainedCount = 50;

static NSString *const segmentRecentName = @"Recent";
NSString *const MQRecentUsedEmojiCharactersKey = @"RecentUsedEmojiCharactersKey";


@interface MQAGEmojiKeyboardView () <UIScrollViewDelegate, MQAGEmojiPageViewDelegate>

@property (nonatomic) UISegmentedControl *segmentsBar;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) UIScrollView *emojiPagesScrollView;
@property (nonatomic) NSDictionary *emojis;
@property (nonatomic) NSMutableArray *pageViews;
@property (nonatomic) NSString *category;

@end

@implementation MQAGEmojiKeyboardView

- (NSDictionary *)emojis {
  if (!_emojis) {
    NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
      NSString * fileRootPath = [[selfBundle bundlePath] stringByAppendingString:@"/MQChatViewAsset.bundle"];
      NSString * filePath = [fileRootPath stringByAppendingString:@"/MQEmojisList.plist"];
    _emojis = [[NSDictionary dictionaryWithContentsOfFile:filePath] copy];
  }
  return _emojis;
}

- (NSString *)categoryNameAtIndex:(NSUInteger)index {
//  NSArray *categoryList = @[segmentRecentName, @"People", @"Objects", @"Nature", @"Places", @"Symbols"];
    NSArray *categoryList = @[@"People", @"Objects", @"Nature", @"Places", @"Symbols"];
  return categoryList[index];
}

- (MQAGEmojiKeyboardViewCategoryImage)defaultSelectedCategory {
  if ([self.dataSource respondsToSelector:@selector(defaultCategoryForEmojiKeyboardView:)]) {
    return [self.dataSource defaultCategoryForEmojiKeyboardView:self];
  }
  return MQAGEmojiKeyboardViewCategoryImageFace;
}

- (NSUInteger)recentEmojisMaintainedCount {
  if ([self.dataSource respondsToSelector:@selector(recentEmojisMaintainedCountForEmojiKeyboardView:)]) {
    return [self.dataSource recentEmojisMaintainedCountForEmojiKeyboardView:self];
  }
  return DefaultRecentEmojisMaintainedCount;
}

- (NSArray *)imagesForSelectedSegments {
  static NSMutableArray *array;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    array = [NSMutableArray array];
    for (MQAGEmojiKeyboardViewCategoryImage i = MQAGEmojiKeyboardViewCategoryImageFace;
         i <= MQAGEmojiKeyboardViewCategoryImageCharacters;
         ++i) {
      [array addObject:[self segImageWithCategory:i]];
    }
  });
  return array;
}

- (NSArray *)imagesForNonSelectedSegments {
  static NSMutableArray *array;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    array = [NSMutableArray array];
    for (MQAGEmojiKeyboardViewCategoryImage i = MQAGEmojiKeyboardViewCategoryImageFace;
         i <= MQAGEmojiKeyboardViewCategoryImageCharacters;
         ++i) {
        [array addObject:[self segImageUnselectedWithCategory:i]];
    }
  });
  return array;
}

// recent emojis are backed in NSUserDefaults to save them across app restarts.
- (NSMutableArray *)recentEmojis {
  NSArray *emojis = [[NSUserDefaults standardUserDefaults] arrayForKey:MQRecentUsedEmojiCharactersKey];
  NSMutableArray *recentEmojis = [emojis mutableCopy];
  if (recentEmojis == nil) {
    recentEmojis = [NSMutableArray array];
  }
  return recentEmojis;
}

- (void)setRecentEmojis:(NSMutableArray *)recentEmojis {
  // remove emojis if they cross the cache maintained limit
  if ([recentEmojis count] > self.recentEmojisMaintainedCount) {
    NSRange indexRange = NSMakeRange(self.recentEmojisMaintainedCount,
                                     [recentEmojis count] - self.recentEmojisMaintainedCount);
    NSIndexSet *indexesToBeRemoved = [NSIndexSet indexSetWithIndexesInRange:indexRange];
    [recentEmojis removeObjectsAtIndexes:indexesToBeRemoved];
  }
  [[NSUserDefaults standardUserDefaults] setObject:recentEmojis forKey:MQRecentUsedEmojiCharactersKey];
}

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<MQAGEmojiKeyboardViewDataSource>)dataSource {
  self = [super initWithFrame:frame];
  if (self) {
    // initialize category

    _dataSource = dataSource;

      
      self.backgroundColor = [UIColor whiteColor];
      
    self.category = [self categoryNameAtIndex:self.defaultSelectedCategory];

    self.segmentsBar = [[UISegmentedControl alloc] initWithItems:self.imagesForSelectedSegments];
    self.segmentsBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      self.segmentsBar.tintColor = [UIColor lightGrayColor];
      [self.segmentsBar setDividerImage:[UIImage new] forLeftSegmentState:(UIControlStateNormal) rightSegmentState:(UIControlStateNormal) barMetrics:(UIBarMetricsDefault)];
      [self.segmentsBar setBackgroundImage:[UIImage EllipseImageWithColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:247/255.0 alpha:1] andSize:CGSizeMake(1, 1)] forState:UIControlStateNormal barMetrics:(UIBarMetricsDefault)];
      [self.segmentsBar setBackgroundImage:[UIImage EllipseImageWithColor:[UIColor whiteColor] andSize:CGSizeMake(1, 1)] forState:UIControlStateSelected barMetrics:(UIBarMetricsDefault)];
      [self.segmentsBar setContentMode:(UIViewContentModeScaleAspectFit)];
    [self.segmentsBar addTarget:self
                         action:@selector(categoryChangedViaSegmentsBar:)
               forControlEvents:UIControlEventValueChanged];
    [self setSelectedCategoryImageInSegmentControl:self.segmentsBar
                                           atIndex:self.defaultSelectedCategory];
    self.segmentsBar.selectedSegmentIndex = self.defaultSelectedCategory;
      self.segmentsBar.frame = CGRectMake(0,
                                          0,
                                          CGRectGetWidth(self.bounds),
                                          30);
      [self addSubview:self.segmentsBar];

    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.currentPage = 0;
      self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
      self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.backgroundColor = [UIColor clearColor];
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
    CGSize frameSize = CGSizeMake(CGRectGetWidth(self.bounds),
                                  CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height);
    NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                  inFrameSize:frameSize];
    self.pageControl.numberOfPages = numberOfPages;
    pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
    CGRect pageControlFrame = CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                         CGRectGetHeight(self.bounds) - self.segmentsBar.bounds.size.height - pageControlSize.height,
                                         pageControlSize.width,
                                         pageControlSize.height);
    self.pageControl.frame = CGRectIntegral(pageControlFrame);
    [self.pageControl addTarget:self
                         action:@selector(pageControlTouched:)
               forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];
      
      CGRect scrollViewFrame = CGRectMake(0,
                                          0,
                                          CGRectGetWidth(self.bounds),
                                          CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height);
      self.emojiPagesScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
      self.emojiPagesScrollView.pagingEnabled = YES;
      self.emojiPagesScrollView.showsHorizontalScrollIndicator = NO;
      self.emojiPagesScrollView.showsVerticalScrollIndicator = NO;
      self.emojiPagesScrollView.delegate = self;
      self.emojiPagesScrollView.backgroundColor = [UIColor whiteColor];
      
      [self addSubview:self.emojiPagesScrollView];
      
      self.segmentsBar.frame = CGRectMake(0,
                                          CGRectGetMaxY(pageControlFrame),
                                          CGRectGetWidth(self.bounds),
                                          CGRectGetHeight(self.segmentsBar.bounds));

  }
  return self;
}

- (UIImage *)segImageWithCategory:(MQAGEmojiKeyboardViewCategoryImage)category {
    NSString *imageName = @"";
    switch (category) {
//        case MQAGEmojiKeyboardViewCategoryImageRecent:
//            imageName = @"AGEmojiFlags";
//            break;
        case MQAGEmojiKeyboardViewCategoryImageFace:
            imageName = @"AGEmojiPeople";
            break;
        case MQAGEmojiKeyboardViewCategoryImageBell:
            imageName = @"AGEmojiObjects";
            break;
        case MQAGEmojiKeyboardViewCategoryImageFlower:
            imageName = @"AGEmojiAnimals";
            break;
        case MQAGEmojiKeyboardViewCategoryImageCar:
            imageName = @"AGEmojiPlaces";
            break;
        case MQAGEmojiKeyboardViewCategoryImageCharacters:
            imageName = @"AGEmojiSymbols";
            break;
    }
    UIImage *img = [[MQAssetUtil imageFromBundleWithName:imageName] addContentInsect:UIEdgeInsetsMake(7, 7, 7, 7)];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (UIImage *)segImageUnselectedWithCategory:(MQAGEmojiKeyboardViewCategoryImage)category {
    NSString *imageName = @"";
    switch (category) {
//        case MQAGEmojiKeyboardViewCategoryImageRecent:
//            imageName = @"AGEmojiFlags";
//            break;
        case MQAGEmojiKeyboardViewCategoryImageFace:
            imageName = @"AGEmojiPeople";
            break;
        case MQAGEmojiKeyboardViewCategoryImageBell:
            imageName = @"AGEmojiObjects";
            break;
        case MQAGEmojiKeyboardViewCategoryImageFlower:
            imageName = @"AGEmojiAnimals";
            break;
        case MQAGEmojiKeyboardViewCategoryImageCar:
            imageName = @"AGEmojiPlaces";
            break;
        case MQAGEmojiKeyboardViewCategoryImageCharacters:
            imageName = @"AGEmojiSymbols";
            break;
    }
    UIImage *img = [[MQAssetUtil imageFromBundleWithName:imageName] addContentInsect:UIEdgeInsetsMake(7, 7, 7, 7)];
    return img;
}

- (void)layoutSubviews {
  CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
  NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height)];

  NSInteger currentPage = (self.pageControl.currentPage > numberOfPages) ? numberOfPages : self.pageControl.currentPage;

  // if (currentPage > numberOfPages) it is set implicitly to max pageNumber available
  self.pageControl.numberOfPages = numberOfPages;
  pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
  CGRect pageControlFrame = CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                       CGRectGetHeight(self.bounds) - self.segmentsBar.bounds.size.height - pageControlSize.height,
                                       pageControlSize.width,
                                       pageControlSize.height);
  self.pageControl.frame = CGRectIntegral(pageControlFrame);

  self.emojiPagesScrollView.frame = CGRectMake(0,
                                               0,
                                               CGRectGetWidth(self.bounds),
                                               CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height);
  [self.emojiPagesScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  self.emojiPagesScrollView.contentOffset = CGPointMake(CGRectGetWidth(self.emojiPagesScrollView.bounds) * currentPage, 0);
  self.emojiPagesScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.emojiPagesScrollView.bounds) * numberOfPages,
                                                     CGRectGetHeight(self.emojiPagesScrollView.bounds));
    
    
  [self purgePageViews];
  self.pageViews = [NSMutableArray array];
  [self setPage:currentPage];
}

#pragma mark event handlers

- (void)setSelectedCategoryImageInSegmentControl:(UISegmentedControl *)segmentsBar
                                         atIndex:(NSInteger)index {
  for (int i=0; i < self.segmentsBar.numberOfSegments; ++i) {
    [segmentsBar setImage:self.imagesForNonSelectedSegments[i] forSegmentAtIndex:i];
  }
  [segmentsBar setImage:self.imagesForSelectedSegments[index] forSegmentAtIndex:index];
}

- (void)categoryChangedViaSegmentsBar:(UISegmentedControl *)sender {
  // recalculate number of pages for new category and recreate emoji pages
  self.category = [self categoryNameAtIndex:sender.selectedSegmentIndex];
  [self setSelectedCategoryImageInSegmentControl:sender
                                         atIndex:sender.selectedSegmentIndex];
  self.pageControl.currentPage = 0;
  [self setNeedsLayout];
}

- (void)pageControlTouched:(UIPageControl *)sender {
  CGRect bounds = self.emojiPagesScrollView.bounds;
  bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
  bounds.origin.y = 0;
  // scrollViewDidScroll is called here. Page set at that time.
  [self.emojiPagesScrollView scrollRectToVisible:bounds animated:YES];
}

// Track the contentOffset of the scroll view, and when it passes the mid
// point of the current view’s width, the views are reconfigured.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
  NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  if (self.pageControl.currentPage == newPageNumber) {
    return;
  }
  self.pageControl.currentPage = newPageNumber;
  [self setPage:self.pageControl.currentPage];
}

#pragma mark change a page on scrollView

// Check if setting pageView for an index is required
- (BOOL)requireToSetPageViewForIndex:(NSUInteger)index {
  if (index >= self.pageControl.numberOfPages) {
    return NO;
  }
  for (MQAGEmojiPageView *page in self.pageViews) {
    if ((page.frame.origin.x / CGRectGetWidth(self.emojiPagesScrollView.bounds)) == index) {
      return NO;
    }
  }
  return YES;
}

// Create a pageView and add it to the scroll view.
- (MQAGEmojiPageView *)synthesizeEmojiPageView {
  NSUInteger rows = [self numberOfRowsForFrameSize:self.emojiPagesScrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:self.emojiPagesScrollView.bounds.size];
  CGRect pageViewFrame = CGRectMake(0,
                                    0,
                                    CGRectGetWidth(self.emojiPagesScrollView.bounds),
                                    CGRectGetHeight(self.emojiPagesScrollView.bounds));
  MQAGEmojiPageView *pageView = [[MQAGEmojiPageView alloc] initWithFrame: pageViewFrame
                                                backSpaceButtonImage:[MQAssetUtil imageFromBundleWithName:@"MQFileCancel"]
                                                          buttonSize:CGSizeMake(ButtonWidth, ButtonHeight)
                                                                rows:rows
                                                             columns:columns];
  pageView.delegate = self;
  [self.pageViews addObject:pageView];
  [self.emojiPagesScrollView addSubview:pageView];
  return pageView;
}

// return a pageView that can be used in the current scrollView.
// look for an available pageView in current pageView-s on scrollView.
// If all are in use i.e. are of current page or neighbours
// of current page, we create a new one

- (MQAGEmojiPageView *)usableEmojiPageView {
  MQAGEmojiPageView *pageView = nil;
  for (MQAGEmojiPageView *page in self.pageViews) {
    NSUInteger pageNumber = page.frame.origin.x / CGRectGetWidth(self.emojiPagesScrollView.bounds);
    if (abs((int)(pageNumber - self.pageControl.currentPage)) > 1) {
      pageView = page;
      break;
    }
  }
  if (!pageView) {
    pageView = [self synthesizeEmojiPageView];
  }
  return pageView;
}

// Set emoji page view for given index.
- (void)setEmojiPageViewInScrollView:(UIScrollView *)scrollView atIndex:(NSUInteger)index {

  if (![self requireToSetPageViewForIndex:index]) {
    return;
  }

  MQAGEmojiPageView *pageView = [self usableEmojiPageView];

  NSUInteger rows = [self numberOfRowsForFrameSize:scrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:scrollView.bounds.size];
  NSUInteger startingIndex = index * (rows * columns - 1);
  NSUInteger endingIndex = (index + 1) * (rows * columns - 1);
  NSMutableArray *buttonTexts = [self emojiTextsForCategory:self.category
                                                  fromIndex:startingIndex
                                                    toIndex:endingIndex];
  [pageView setButtonTexts:buttonTexts];
  pageView.frame = CGRectMake(index * CGRectGetWidth(scrollView.bounds),
                              0,
                              CGRectGetWidth(scrollView.bounds),
                              CGRectGetHeight(scrollView.bounds));
}

// Set the current page.
// sets neightbouring pages too, as they are viewable by part scrolling.
- (void)setPage:(NSInteger)page {
  [self setEmojiPageViewInScrollView:self.emojiPagesScrollView atIndex:page - 1];
  [self setEmojiPageViewInScrollView:self.emojiPagesScrollView atIndex:page];
  [self setEmojiPageViewInScrollView:self.emojiPagesScrollView atIndex:page + 1];
}

- (void)purgePageViews {
  for (MQAGEmojiPageView *page in self.pageViews) {
    page.delegate = nil;
  }
  self.pageViews = nil;
}

#pragma mark data methods

- (NSUInteger)numberOfColumnsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.width / ButtonWidth);
}

- (NSUInteger)numberOfRowsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.height / ButtonHeight);
}

- (NSArray *)emojiListForCategory:(NSString *)category {
  if ([category isEqualToString:segmentRecentName]) {
    return [self recentEmojis];
  }
  return [self.emojis objectForKey:category];
}

// for a given frame size of scroll view, return the number of pages
// required to show all the emojis for a category
- (NSUInteger)numberOfPagesForCategory:(NSString *)category inFrameSize:(CGSize)frameSize {

  if ([category isEqualToString:segmentRecentName]) {
    return 1;
  }

  NSUInteger emojiCount = [[self emojiListForCategory:category] count];
  NSUInteger numberOfRows = [self numberOfRowsForFrameSize:frameSize];
  NSUInteger numberOfColumns = [self numberOfColumnsForFrameSize:frameSize];
  NSUInteger numberOfEmojisOnAPage = (numberOfRows * numberOfColumns) - 1;

  NSUInteger numberOfPages = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);
  return numberOfPages;
}

// return the emojis for a category, given a staring and an ending index
- (NSMutableArray *)emojiTextsForCategory:(NSString *)category
                                fromIndex:(NSUInteger)start
                                  toIndex:(NSUInteger)end {
  NSArray *emojis = [self emojiListForCategory:category];
  end = ([emojis count] > end)? end : [emojis count];
  NSIndexSet *index = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(start, end-start)];
  return [[emojis objectsAtIndexes:index] mutableCopy];
}

#pragma mark EmojiPageViewDelegate

- (void)setInRecentsEmoji:(NSString *)emoji {
  NSAssert(emoji != nil, @"Emoji can't be nil");

  NSMutableArray *recentEmojis = [self recentEmojis];
  for (int i = 0; i < [recentEmojis count]; ++i) {
    if ([recentEmojis[i] isEqualToString:emoji]) {
      [recentEmojis removeObjectAtIndex:i];
    }
  }
  [recentEmojis insertObject:emoji atIndex:0];
  [self setRecentEmojis:recentEmojis];
}

// add the emoji to recents
- (void)emojiPageView:(MQAGEmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji {
  [self setInRecentsEmoji:emoji];
  [self.delegate emojiKeyBoardView:self didUseEmoji:emoji];
}

- (void)emojiPageViewDidPressBackSpace:(MQAGEmojiPageView *)emojiPageView {
  [self.delegate emojiKeyBoardViewDidPressBackSpace:self];
}

@end
