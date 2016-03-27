//
//  VEWatchBikeStation.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 3/27/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

@import Foundation;

@import CoreLocation.CLLocation;

@interface VEWatchBikeStation : NSObject <NSCoding>

@property (nonatomic, copy) NSString *stationName;

@property (nonatomic, copy) CLLocation *stationLocation;

@property (nonatomic, assign) NSUInteger availableBikes;

@property (nonatomic, assign) NSUInteger availableStands;

@end
