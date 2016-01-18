//
//  LightStation.h
//  Velo'v
//
//  Created by Clément Padovani on 12/12/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "VEBaseModel.h"

extern NSString * const kLightStationLocation;

extern NSString * const kLightStationNumber;

@interface LightStation : VEBaseModel

@property (nonatomic, retain) CLLocation * location;
@property (nonatomic, retain) NSNumber * number;

@end

@interface LightStation (CustomMethods)

+ (LightStation *) lightStationFromStationDictionary: (NSDictionary *) stationDictionary inContext: (NSManagedObjectContext *) context;

@end
