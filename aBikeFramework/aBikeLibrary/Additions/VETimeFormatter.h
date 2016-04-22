//
//  VETimeFormatter.h
//  Velo'v
//
//  Created by Clément Padovani on 11/13/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

@import MapKit.MKDistanceFormatter;

NS_ASSUME_NONNULL_BEGIN

static NSString * const kVETimeFormatterUnitsChangedNotification = @"kVETimeFormatterUnitsChangedNotification";

static NSString * const kVETimeFormatterNumberOfBikeStationsHasChangedNotification = @"kVETimeFormatterNumberOfBikeStationsHasChangedNotification";

@interface VETimeFormatter : NSObject

+ (void) startNotifications;

+ (void) tearDistanceFormatterDown;

+ (MKDistanceFormatter *) sharedDistanceFormatter;

+ (NSString *) formattedStringForDuration: (NSTimeInterval) duration;

+ (NSString *) formattedStringForETA: (NSTimeInterval) eta;

+ (NSUInteger) numberOfBikeStations;

//+ (NSString *) formattedDurationForLastUpdate: (NSDate *) lastUpdate;

@end

NS_ASSUME_NONNULL_END
