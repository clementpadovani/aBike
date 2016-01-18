//
//  UserSettings.h
//  abike—Lyon
//
//  Created by Clément Padovani on 3/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEBaseModel.h"

struct VECityRect
{
	CLLocationDegrees minLat;
	CLLocationDegrees minLon;
	CLLocationDegrees maxLat;
	CLLocationDegrees maxLon;
};

typedef struct VECityRect VECityRect;

@interface UserSettings : VEBaseModel

@property (nonatomic, retain) NSData *adRemover;
@property (nonatomic, readonly) BOOL canLoadData;
@property (nonatomic) MKMapType mapType;
@property (nonatomic) BOOL setup;
@property (nonatomic) VECityRect cityRect;
@property (nonatomic) VECityRect largerCityRect;
@property (nonatomic, retain) NSString * contractIdentifier;
@property (nonatomic, retain) NSDate * lastDataImportDate;

@end
