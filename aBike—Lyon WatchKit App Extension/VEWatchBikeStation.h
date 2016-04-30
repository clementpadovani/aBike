//
//  VEWatchBikeStation.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 3/27/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

@import Foundation;

@import CoreLocation.CLLocation;

@class Station;

NS_ASSUME_NONNULL_BEGIN

@interface VEWatchBikeStation : NSObject <NSSecureCoding>

#if !TARGET_OS_WATCH
+ (instancetype) watchBikeStationForStation: (Station *) station;
#endif

@property (nonatomic, copy) NSString *stationName;

@property (nonatomic, copy) CLLocation *stationLocation;

@property (nonatomic, assign) NSUInteger availableBikes;

@property (nonatomic, assign) NSUInteger availableStands;

@end

NS_ASSUME_NONNULL_END
