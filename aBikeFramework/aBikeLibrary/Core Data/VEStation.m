//
//  VEStation.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEStation.h"

@implementation VEStation

- (BOOL) isAvailable
{
    return [self available];
}

- (BOOL) isBonusStation
{
    return [self bonusStation];
}

- (BOOL) isBankingAvailable
{
    return [self bankingAvailable];
}

@end
