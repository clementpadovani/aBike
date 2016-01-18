//
//  LightStation.m
//  Velo'v
//
//  Created by Clément Padovani on 12/12/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "LightStation.h"

#import "Station+Additions.h"

#import "CPCoreDataManager.h"

NSString * const kLightStationLocation = @"location";

NSString * const kLightStationNumber = @"number";

@implementation LightStation

@dynamic location;
@dynamic number;

@end

@implementation LightStation (CustomMethods)

+ (LightStation *) lightStationFromStationDictionary: (NSDictionary *) stationDictionary inContext: (NSManagedObjectContext *) context
{
	LightStation *newStation = [self newEntityInManagedObjectContext: context];
	
	[newStation setNumber: stationDictionary[kLightStationNumber]];
	
	[newStation setLocation: stationDictionary[kLightStationLocation]];
	
	return newStation;
}

@end
