//
//  VEStation.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kVEStationUpdateErrorNotification = @"kVEStationUpdateErrorNotification";

@interface VEStation : VEBaseModel <MKAnnotation>

+ (instancetype) stationFromStationDictionary: (NSDictionary <NSString *, id> *) stationDictionary inContext: (NSManagedObjectContext *) context;

@property (nonatomic) CLLocationCoordinate2D privateCoordinate;

- (void) fetchContentWithUserForceReload: (BOOL) userForceReload;

- (NSString *) availableBikesString;

- (NSString *) availableBikeStationsString;

- (BOOL) isAvailable;

- (BOOL) isBonusStation;

- (BOOL) isBankingAvailable;

@end

NS_ASSUME_NONNULL_END

#import "VEStation+CoreDataProperties.h"
