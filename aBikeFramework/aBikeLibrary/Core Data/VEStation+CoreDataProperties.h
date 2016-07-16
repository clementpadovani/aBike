//
//  VEStation+CoreDataProperties.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VEStation.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEStation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, assign) int16_t availableBikes;
@property (nonatomic, assign) int16_t availableBikeStations;
@property (nonatomic, assign) BOOL bankingAvailable;
@property (nonatomic, assign) BOOL bonusStation;
@property (nonatomic, assign) BOOL canLoadData;
@property (nullable, nonatomic, retain) NSString *contractIdentifier;
@property (nullable, nonatomic, retain) NSDate *dataContentAge;
@property (nullable, nonatomic, retain) CLLocation *location;
@property (nullable, nonatomic, retain) MKMapItem *mapItem;
@property (nullable, nonatomic, retain) MKPlacemark *mapItemPlacemark;
@property (nullable, nonatomic, retain) NSString *stationName;
@property (nonatomic, assign) int16_t stationID;
@property (nullable, nonatomic, retain) NSString *processedStationName;

@end

NS_ASSUME_NONNULL_END
