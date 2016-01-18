//
//  Station.h
//  abike—Lyon
//
//  Created by Clément Padovani on 4/2/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEBaseModel.h"

@interface Station : VEBaseModel

@property (nonatomic, retain) NSString * address;
@property (nonatomic) BOOL available;
@property (nonatomic) NSUInteger availableBikes;
@property (nonatomic) NSUInteger availableBikeStations;
@property (nonatomic) BOOL banking;
@property (nonatomic) BOOL bonusStation;
@property (nonatomic, readonly) BOOL canLoadData;
@property (nonatomic, retain) NSString * contractIdentifier;
@property (nonatomic, retain) NSDate * dataContentAge;
@property (nonatomic, retain) CLLocation * location;
@property (nonatomic, retain, readonly) MKMapItem * mapItem;
@property (nonatomic, retain) MKPlacemark * mapItemPlacemark;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * processedStationName;

@property (nonatomic) CLLocationCoordinate2D privateCoordinate;

@end
