//
//  VEStation.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEStation.h"
#import "VEDataImporter.h"
#import "NSNumber+Extensions.h"
#import "NSString+ProcessedStationName.h"
#import "VEConsul.h"

#if lowDataRefreshTimes

static const NSTimeInterval kVEStationReloadDataThreshold = 10.;

#else

static const NSTimeInterval kVEStationReloadDataThreshold = 60. * 2.;

#endif

@interface VEStation (PrimitiveMethods)

@property (nonatomic, retain) NSNumber *primitiveAvailableBikes;
@property (nonatomic, retain) NSNumber *primitiveAvailableBikeStations;
@property (nonatomic, retain) NSDate *primitiveDataContentAge;
@property (nonatomic, retain) MKMapItem *primitiveMapItem;

@end

@implementation VEStation (PrimitiveMethods)

@dynamic primitiveAvailableBikes;
@dynamic primitiveAvailableBikeStations;
@dynamic primitiveDataContentAge;
@dynamic primitiveMapItem;

@end

@implementation VEStation

@synthesize privateCoordinate;

+ (VEStation *) stationFromStationDictionary: (NSDictionary <NSString *, id> *) stationDictionary inContext: (NSManagedObjectContext *) context
{
    NSFetchRequest *stationFetchRequest = [NSFetchRequest fetchRequestWithEntityName: [self entityName]];
    
    [stationFetchRequest setFetchLimit: 1];
    
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat: @"%K == %@", NSStringFromSelector(@selector(stationID)), stationDictionary[NSStringFromSelector(@selector(stationID))]];
    
    [stationFetchRequest setPredicate: fetchPredicate];
    
    NSError *fetchRequestError;
    
    NSArray *result = [context executeFetchRequest: stationFetchRequest error: &fetchRequestError];
    
#if kEnableCrashlytics
    
    if (fetchRequestError)
        [[Crashlytics sharedInstance] recordError: fetchRequestError];
    
#endif
    
    
    if (fetchRequestError)
    {
        CPLog(@"fetch request error: %@", fetchRequestError);
    }
    
    VEStation *station = [result firstObject];
    
    if (!station)
    {
        //CPLog(@"don't have the station... making it");
        
        station = [self internal_stationFromStationDictionary: stationDictionary inContext: context];
    }
    else
    {
        [self internal_updateStation: &station withUpdatedDictionary: stationDictionary];
    }
    
    return station;
}

+ (instancetype) internal_stationFromStationDictionary: (NSDictionary <NSString *, id> *) stationDictionary inContext: (NSManagedObjectContext *) context
{
    VEStation *newStation = [self newEntityInManagedObjectContext: context];
    
    NSString *stationName = stationDictionary[kStationName];
    
    NSNumber *stationNumber = stationDictionary[kStationNumber];
    
    [newStation setStationID: [stationNumber shortValue]];
    
    [newStation setAddress: stationDictionary[kStationAddress]];
    
    [newStation setContractIdentifier: stationDictionary[kStationContractIdentifier]];
    
    [newStation setBankingAvailable: [stationDictionary[kStationBanking] boolValue]];
    
    [newStation setBonusStation: [stationDictionary[kStationBonus] boolValue]];
    
    [newStation setAvailable: [stationDictionary[kStationStatus] isEqualToString: kStationStatusOpen] ? YES : NO];
    
    [newStation setAvailableBikes: [stationDictionary[kStationAvailableBikes] shortValue]];
    
    [newStation setAvailableBikeStations: [stationDictionary[kStationAvailableStands] shortValue]];
    
    CLLocationDegrees latitude, longitude;
    
    latitude = [stationDictionary[kStationCoords][kStationCoordsLatitude] ve_locationDegrees];
    
    longitude = [stationDictionary[kStationCoords][kStationCoordsLongitude] ve_locationDegrees];
    
    CLLocation *stationLocation = [[CLLocation alloc] initWithLatitude: latitude longitude: longitude];
    
    [newStation setLocation: stationLocation];
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate: [stationLocation coordinate] addressDictionary: nil];
    
    [newStation setMapItemPlacemark: placemark];
    
    NSNumber *dataContentAgeNumber = stationDictionary[kStationContentAge];
    
    if ([dataContentAgeNumber isKindOfClass: [NSNumber class]])
    {
        NSTimeInterval dataContentAge = [dataContentAgeNumber ve_dataContentAgeTimeInterval];
        
        [newStation setDataContentAge: [NSDate dateWithTimeIntervalSince1970: dataContentAge]];
    }
    else
    {
        [newStation setDataContentAge: [NSDate date]];
    }
    
    stationName = [stationName ve_sanitizedStationNameWithNumber: stationNumber];
    
    [newStation setStationName: stationName];
    
    [newStation setProcessedStationName: [stationName ve_processedStationName]];
    
    return newStation;
}

- (MKMapItem *) mapItem
{
    [self willAccessValueForKey: NSStringFromSelector(@selector(mapItem))];
    
    MKMapItem *mapItem = [self primitiveMapItem];
    
    [self didAccessValueForKey: NSStringFromSelector(@selector(mapItem))];
    
    if (!mapItem)
    {
        mapItem = [[MKMapItem alloc] initWithPlacemark: (MKPlacemark * __nonnull) [self mapItemPlacemark]];
        
        [self setPrimitiveMapItem: mapItem];
    }
    
    return mapItem;
}

- (NSString *) availableBikesString
{
    NSString *availableBikesString;
    
    int16_t availableBikes = [self availableBikes];
    
    availableBikesString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Bikes", @"VEStationView_available_bikes"), availableBikes];
    
    return availableBikesString;
}

- (NSString *) availableBikeStationsString
{
    NSString *availableStandsString;
    
    int16_t availableStands = [self availableBikeStations];
    
    availableStandsString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Stands", @"VEStationView_available_stands"), availableStands];
    
    return availableStandsString;
}

- (NSString *) title
{
    return [self processedStationName];
}

- (NSString *) subtitle
{
    //	NSString *availableBikesString;
    //
    //	NSString *availableStandsString;
    //
    //	NSUInteger availableBikes = [self availableBikes];
    //
    //	NSUInteger availableStands = [self availableBikeStations];
    //
    //	if (availableBikes == 1)
    //	{
    //		availableBikesString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Bike", @"VEStationView_available_bike"), availableBikes];
    //	}
    //	else
    //	{
    //		availableBikesString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Bikes", @"VEStationView_available_bikes"), availableBikes];
    //	}
    //
    //	if (availableStands == 1)
    //	{
    //		availableStandsString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Stand", @"VEStationView_available_stands"), availableStands];
    //	}
    //	else
    //	{
    //		availableStandsString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Stands", @"VEStationView_available_stands"), availableStands];
    //	}
    
    return [NSString stringWithFormat: @"%@ | %@", [self availableBikesString], [self availableBikeStationsString]];
}

- (BOOL) canLoadData
{
    [self willAccessValueForKey: NSStringFromSelector(@selector(canLoadData))];
    
    NSDate *lastDataUpdate = [self dataContentAge];
    
    BOOL canLoadData;
    
    if (lastDataUpdate)
    {
        NSTimeInterval lastFetchInterval = [[NSDate date] timeIntervalSinceDate: lastDataUpdate];
        
        if (lastFetchInterval > kVEStationReloadDataThreshold)
        {
            canLoadData = YES;
        }
        else
        {
            canLoadData = NO;
        }
    }
    else
    {
        canLoadData = YES;
    }
    
    [self didAccessValueForKey: NSStringFromSelector(@selector(canLoadData))];
    
    return canLoadData;
}

- (void) setDataContentAge: (NSDate *) dataContentAge
{
    [self willChangeValueForKey: NSStringFromSelector(@selector(dataContentAge))];
    
    [self willChangeValueForKey: NSStringFromSelector(@selector(canLoadData))];
    
    [self setPrimitiveDataContentAge: dataContentAge];
    
    [self didChangeValueForKey: NSStringFromSelector(@selector(canLoadData))];
    
    [self didChangeValueForKey: NSStringFromSelector(@selector(dataContentAge))];
}

- (BOOL) isAvailable
{
    return [self available];
}

- (BOOL) isBonusStation
{
    return [self bonusStation];
}

- (BOOL) isBankingAvailable
{
    return [self bankingAvailable];
}

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    
    [self setPrivateCoordinate: kCLLocationCoordinate2DInvalid];
}

- (CLLocationCoordinate2D) coordinate
{
    if (!CLLocationCoordinate2DIsValid([self privateCoordinate]))
    {
        [self setPrivateCoordinate: [[self location] coordinate]];
    }
    
    //CPLog(@"thread: %@", [NSThread currentThread]);
    
    if (![NSThread isMainThread])
    {
        return [self privateCoordinate];
        
        //CPLog(@"not main thread");
        
        //		[[self managedObjectContext] performBlock:^{
        //			CPLog(@"self: %@", self);
        //		}];
        
        //	return kCLLocationCoordinate2DInvalid;
    }
    
    //	CPLog(@"name: %@", [self name]);
    
    return [[self location] coordinate];
}

- (void) fetchContentWithUserForceReload: (BOOL) userForceReload
{
    if (![[VEConsul sharedConsul] canUpdateStations])
        return;
    
    if (![self canLoadData])
        return;
    
    NSURL *stationDataURL = [VEDataImporter stationDataURLForStation: self];
    
    NSURLSession *dataSession = [VEDataImporter aBikeSession];
    
    __weak VEStation *weakSelf = self;
    
    NSURLSessionDataTask *dataTask = [dataSession dataTaskWithURL: stationDataURL
                                                completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    
                                                    __strong __block VEStation *strongSelf = weakSelf;
                                                    
                                                    NSManagedObjectContext *strongManagedObjectContext = [strongSelf managedObjectContext];
                                                    
                                                    if (!strongSelf || !strongManagedObjectContext)
                                                    {
                                                        CPLog(@"no strong self OR strong managedObjectContext... returning");
                                                        
                                                        CPLog(@"exists: self: %@ context: %@", strongSelf ? @"YES" : @"NO", strongManagedObjectContext ? @"YES" : @"NO");
                                                        
                                                        //											    NSAssert(NO, @"");
                                                        
                                                        return;
                                                    }
                                                    
                                                    if (error)
                                                    {
                                                        CPLog(@"error: %@", error);
                                                        
#if kEnableCrashlytics
                                                        
                                                        [[Crashlytics sharedInstance] recordError: error];
                                                        
#endif
                                                        
                                                        if (![[VEConsul sharedConsul] isReachable])
                                                            return;
                                                        
                                                        
                                                        
                                                        if ([error code] != NSURLErrorTimedOut)
                                                        {
                                                            [[NSNotificationCenter defaultCenter] postNotificationName: kVEStationUpdateErrorNotification object: nil];
                                                            
                                                            return;
                                                        }
                                                        else
                                                        {
                                                            return;
                                                        }
                                                    }
                                                    
                                                    NSError *serializationError;
                                                    
                                                    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &serializationError];
                                                    
                                                    if (serializationError)
                                                    {
#if kEnableCrashlytics
                                                        
                                                        [[Crashlytics sharedInstance] recordError: serializationError];
                                                        
#endif
                                                        
                                                    }
                                                    
                                                    NSAssert(!serializationError, @"Serialization error: %@", serializationError);
                                                    
                                                    [strongManagedObjectContext performBlockAndWait: ^{
                                                        
                                                        [VEStation internal_updateStation: &strongSelf
                                                                    withUpdatedDictionary: serializedData];
                                                        
                                                    }];
                                                    
                                                }];
    
    [dataTask resume];
}

+ (void) internal_updateStation: (VEStation *__autoreleasing *) stationToUpdate withUpdatedDictionary: (NSDictionary <NSString *, id> *) updatedDictionary
{
    [*stationToUpdate setBankingAvailable: [updatedDictionary[kStationBanking] boolValue]];
    
    [*stationToUpdate setAvailable: [updatedDictionary[kStationStatus] isEqualToString: kStationStatusOpen]];
    
    [*stationToUpdate setAvailableBikes: [updatedDictionary[kStationAvailableBikes] shortValue]];
    
    [*stationToUpdate setAvailableBikeStations: [updatedDictionary[kStationAvailableStands] shortValue]];
    
    NSNumber *dataContentAgeNumber = updatedDictionary[kStationContentAge];
    
    if ([dataContentAgeNumber isKindOfClass: [NSNumber class]])
    {
        NSTimeInterval dataContentAge = [dataContentAgeNumber ve_dataContentAgeTimeInterval];
        
        [*stationToUpdate setDataContentAge: [NSDate dateWithTimeIntervalSince1970: dataContentAge]];
    }
    else
    {
        [*stationToUpdate setDataContentAge: [NSDate date]];
    }
}

@end
