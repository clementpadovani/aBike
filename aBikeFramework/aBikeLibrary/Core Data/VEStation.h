//
//  VEStation.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEStation : VEBaseModel

- (BOOL) isAvailable;

- (BOOL) isBonusStation;

- (BOOL) isBankingAvailable;

@end

NS_ASSUME_NONNULL_END

#import "VEStation+CoreDataProperties.h"
