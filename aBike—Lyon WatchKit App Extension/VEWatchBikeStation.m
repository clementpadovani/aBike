//
//  VEWatchBikeStation.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 3/27/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEWatchBikeStation.h"

@implementation VEWatchBikeStation

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];

    if (self)
    {
        [self setStationName: [aDecoder decodeObjectForKey: NSStringFromSelector(@selector(stationName))]];

        [self setStationLocation: [aDecoder decodeObjectForKey: NSStringFromSelector(@selector(stationLocation))]];

        [self setAvailableBikes: (NSUInteger) [aDecoder decodeIntegerForKey: NSStringFromSelector(@selector(availableBikes))]];

        [self setAvailableStands: (NSUInteger) [aDecoder decodeIntegerForKey: NSStringFromSelector(@selector(availableStands))]];

    }

    return self;
}

- (void) encodeWithCoder: (NSCoder *) aCoder
{
    [aCoder encodeObject: [self stationName] forKey: NSStringFromSelector(@selector(stationName))];

    [aCoder encodeObject: [self stationLocation] forKey: NSStringFromSelector(@selector(stationLocation))];

    [aCoder encodeInteger: (NSInteger) [self availableBikes] forKey: NSStringFromSelector(@selector(availableBikes))];

    [aCoder encodeInteger: (NSInteger) [self availableStands] forKey: NSStringFromSelector(@selector(availableStands))];
}

@end
