//
//  VEStation.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEStation.h"

@implementation VEStation

- (NSString *) availableBikesString
{
    NSString *availableBikesString;
    
    int16_t availableBikes = [self availableBikes];
    
    if (availableBikes == 1)
    {
        availableBikesString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Bike", @"VEStationView_available_bike"), availableBikes];
    }
    else
    {
        availableBikesString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Bikes", @"VEStationView_available_bikes"), availableBikes];
    }
    
    return availableBikesString;
}

- (NSString *) availableBikeStationsString
{
    NSString *availableStandsString;
    
    int16_t availableStands = [self availableBikeStations];
    
    if (availableStands == 1)
    {
        availableStandsString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Stand", @"VEStationView_available_stands"), availableStands];
    }
    else
    {
        availableStandsString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Stands", @"VEStationView_available_stands"), availableStands];
    }
    
    return availableStandsString;
}

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
