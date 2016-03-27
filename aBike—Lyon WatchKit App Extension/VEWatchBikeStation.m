//
//  VEWatchBikeStation.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 3/27/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEWatchBikeStation.h"
#import "NSCoder+VEAdditions.h"

@implementation VEWatchBikeStation

- (instancetype) initWithCoder: (NSCoder *) aDecoder
{
    self = [self init];

    if (self)
    {
        [self setStationName: [aDecoder decodeObjectOfClass: [NSString class] forKey: NSStringFromSelector(@selector(stationName))]];

        [self setStationLocation: [aDecoder decodeObjectOfClass: [CLLocation class] forKey: NSStringFromSelector(@selector(stationLocation))]];

        [self setAvailableBikes: [aDecoder ve_decodeUnsignedIntegerForKey: NSStringFromSelector(@selector(availableBikes))]];

        [self setAvailableStands: [aDecoder ve_decodeUnsignedIntegerForKey: NSStringFromSelector(@selector(availableStands))]];
    }

    return self;
}

- (void) encodeWithCoder: (NSCoder *) aCoder
{
    [aCoder encodeObject: [self stationName] forKey: NSStringFromSelector(@selector(stationName))];

    [aCoder encodeObject: [self stationLocation] forKey: NSStringFromSelector(@selector(stationLocation))];

    [aCoder ve_encodeUnsignedInteger: [self availableBikes] forKey: NSStringFromSelector(@selector(availableBikes))];

    [aCoder ve_encodeUnsignedInteger: [self availableStands] forKey: NSStringFromSelector(@selector(availableStands))];
}

+ (BOOL) supportsSecureCoding
{
    return YES;
}

@end
