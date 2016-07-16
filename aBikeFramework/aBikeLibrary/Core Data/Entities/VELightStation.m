//
//  VELightStation.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VELightStation.h"

@implementation VELightStation

+ (instancetype) lightStationFromStationDictionary: (NSDictionary <NSString *, id> *) stationDictionary inContext: (NSManagedObjectContext *) context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName: [self entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K == %@", NSStringFromSelector(@selector(stationID)), stationDictionary[NSStringFromSelector(@selector(stationID))]];
    
    [fetchRequest setPredicate: predicate];
    
    NSError *fetchError = nil;
    
    NSArray *fetchResults = [context executeFetchRequest: fetchRequest
                                                   error: &fetchError];
    
    if (fetchError)
    {
        CPLog(@"fetch error: %@", fetchError);
    }
    
    VELightStation *lightStation = [fetchResults firstObject];
    
    if (!lightStation)
    {
        lightStation = [self internal_lightStationFromStationDictionary: stationDictionary
                                                              inContext: context];
    }
    
    return lightStation;
}

+ (instancetype) internal_lightStationFromStationDictionary: (NSDictionary <NSString *, id> *) stationDictionary inContext: (NSManagedObjectContext *) context
{
    VELightStation *newStation = [self newEntityInManagedObjectContext: context];
    
    [newStation setStationID: [stationDictionary[NSStringFromSelector(@selector(stationID))] shortValue]];

    [newStation setLocation: stationDictionary[NSStringFromSelector(@selector(location))]];
    
    return newStation;
}

@end
