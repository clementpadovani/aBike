//
//  VEWatchBikeStation.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 3/27/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEWatchBikeStation.h"
#import "NSCoder+VEAdditions.h"

#if !TARGET_OS_WATCH
#import "Station.h"
#endif

@implementation VEWatchBikeStation

#if !TARGET_OS_WATCH
+ (instancetype) watchBikeStationForStation: (Station *) station
{
    VEWatchBikeStation *newStation = [[VEWatchBikeStation alloc] init];

    [newStation setStationName: [station processedStationName]];

    [newStation setStationLocation: [station location]];

    [newStation setAvailableBikes: [station availableBikes]];

    [newStation setAvailableStands: [station availableBikeStations]];

    return newStation;
}
#endif

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

- (NSString *) description
{
    NSString *superDescription = [super description];

    superDescription = [superDescription stringByAppendingFormat: @" %@ %@ b: %lu s: %lu", [self stationName], [self stationLocation], (unsigned long) [self availableBikes], (unsigned long) [self availableStands]];

    return superDescription;
}

@end
