//
//  MQSplitLineCellModel.h
//  MQEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/20.
//  Copyright © 2020 MeiQia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQCellModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQSplitLineCellModel : NSObject <MQCellModelProtocol>

@property (nonatomic, readonly, assign) CGRect labelFrame;
@property (nonatomic, readonly, assign) CGRect leftLineFrame;
@property (nonatomic, readonly, assign) CGRect rightLineFrame;

- (MQSplitLineCellModel *)initCellModelWithCellWidth:(CGFloat)cellWidth withConversionDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
