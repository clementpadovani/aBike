//
//  Station+Additions.m
//  abike—Lyon
//
//  Created by Clément Padovani on 3/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "Station+Additions.h"

#import "NSNumber+Extensions.h"

#import "NSString+ProcessedStationName.h"

#import "VEDataImporter.h"

#import "VEManagedObjectContext.h"

#import "VEConsul.h"

NSString * const kStationOpenKey = @"available";

#if lowDataRefreshTimes

static const NSTimeInterval kStationReloadDataThreshold = 10;

#else

static const NSTimeInterval kStationReloadDataThreshold = 60. * 2.;

#endif

@interface Station (PrimitiveMethods)

@property (nonatomic, retain) NSNumber *primitiveAvailableBikes;
@property (nonatomic, retain) NSNumber *primitiveAvailableBikeStations;
@property (nonatomic, retain) NSDate *primitiveDataContentAge;
@property (nonatomic, retain) MKMapItem *primitiveMapItem;

@end

@implementation Station (PrimitiveMethods)

@dynamic primitiveAvailableBikes;
@dynamic primitiveAvailableBikeStations;
@dynamic primitiveDataContentAge;
@dynamic primitiveMapItem;

- (NSUInteger) availableBikes
{
	[self willAccessValueForKey: NSStringFromSelector(@selector(availableBikes))];
	
	NSUInteger availableBikes = [[self primitiveAvailableBikes] unsignedIntegerValue];
	
	[self didAccessValueForKey: NSStringFromSelector(@selector(availableBikes))];
	
	return availableBikes;
}

- (void) setAvailableBikes: (NSUInteger) availableBikes
{
	[self willChangeValueForKey: NSStringFromSelector(@selector(availableBikes))];
	
	[self setPrimitiveAvailableBikes: @(availableBikes)];
	
	[self didChangeValueForKey: NSStringFromSelector(@selector(availableBikes))];
}

- (NSUInteger) availableBikeStations
{
	[self willAccessValueForKey: NSStringFromSelector(@selector(availableBikeStations))];
	
	NSUInteger availableBikeStations = [[self primitiveAvailableBikeStations] unsignedIntegerValue];
	
	[self didAccessValueForKey: NSStringFromSelector(@selector(availableBikeStations))];
	
	return availableBikeStations;
}

- (void) setAvailableBikeStations: (NSUInteger) availableBikeStations
{
	[self willChangeValueForKey: NSStringFromSelector(@selector(availableBikeStations))];
	
	[self setPrimitiveAvailableBikeStations: @(availableBikeStations)];
	
	[self didChangeValueForKey: NSStringFromSelector(@selector(availableBikeStations))];
}

- (MKMapItem *) mapItem
{
	[self willAccessValueForKey: NSStringFromSelector(@selector(mapItem))];
	
	MKMapItem *mapItem = [self primitiveMapItem];
	
	[self didAccessValueForKey: NSStringFromSelector(@selector(mapItem))];
	
	if (!mapItem)
	{
		mapItem = [[MKMapItem alloc] initWithPlacemark: [self mapItemPlacemark]];
		
		[self setPrimitiveMapItem: mapItem];
	}
	
	return mapItem;
}

- (BOOL) canLoadData
{
	[self willAccessValueForKey: NSStringFromSelector(@selector(canLoadData))];
	
	NSDate *lastDataUpdate = [self dataContentAge];
	
	BOOL canLoadData;
	
	if (lastDataUpdate)
	{
		NSTimeInterval lastFetchInterval = [[NSDate date] timeIntervalSinceDate: lastDataUpdate];
		
		if (lastFetchInterval > kStationReloadDataThreshold)
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
	
	[self didChangeValueForKey: NSStringFromSelector(@selector(dataContentAge))];
	
	[self didChangeValueForKey: NSStringFromSelector(@selector(canLoadData))];
}

@end

@interface Station (PrivateAdditions)

+ (void) internal_updateStation: (Station *__autoreleasing *) stationToUpdate withUpdatedDictionary: (NSDictionary *) updatedDictionary;

@end

@implementation Station (Additions)

+ (Station *) stationFromStationDictionary: (NSDictionary *) stationDictionary inContext: (NSManagedObjectContext *) context
{
	NSFetchRequest *stationFetchRequest = [NSFetchRequest fetchRequestWithEntityName: [self entityName]];
	
	[stationFetchRequest setFetchLimit: 1];
	
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat: @"%K == %@", NSStringFromSelector(@selector(number)), stationDictionary[kStationNumber]];
	
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
	
	Station *station = [result firstObject];
	
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

+ (Station *) internal_stationFromStationDictionary: (NSDictionary *) stationDictionary inContext: (NSManagedObjectContext *) context
{
	Station *newStation = [self newEntityInManagedObjectContext: context];
	
	NSString *stationName = stationDictionary[kStationName];
	
	NSNumber *stationNumber = stationDictionary[kStationNumber];
	
	[newStation setNumber: stationNumber];
	
	[newStation setAddress: stationDictionary[kStationAddress]];
	
	[newStation setContractIdentifier: stationDictionary[kStationContractIdentifier]];
	
	[newStation setBanking: [stationDictionary[kStationBanking] boolValue]];
	
	[newStation setBonusStation: [stationDictionary[kStationBonus] boolValue]];
	
	[newStation setAvailable: [stationDictionary[kStationStatus] isEqualToString: kStationStatusOpen] ? YES : NO];
	
	[newStation setAvailableBikes: [stationDictionary[kStationAvailableBikes] unsignedIntegerValue]];
	
	[newStation setAvailableBikeStations: [stationDictionary[kStationAvailableStands] unsignedIntegerValue]];
	
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
	
	
	[newStation setName: stationName];
	
	[newStation setProcessedStationName: [stationName ve_processedStationName]];
	
	return newStation;
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

- (NSString *) availableBikesString
{
	NSString *availableBikesString;
	
	NSUInteger availableBikes = [self availableBikes];
	
	if (availableBikes == 1)
	{
		availableBikesString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Bike", @"VEStationView_available_bike"), availableBikes];
	}
	else
	{
		availableBikesString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Bikes", @"VEStationView_available_bikes"), availableBikes];
	}
	
	return availableBikesString;
}

- (NSString *) availableBikeStationsString
{
	NSString *availableStandsString;
	
	NSUInteger availableStands = [self availableBikeStations];
	
	if (availableStands == 1)
	{
		availableStandsString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Stand", @"VEStationView_available_stands"), availableStands];
	}
	else
	{
		availableStandsString = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Stands", @"VEStationView_available_stands"), availableStands];
	}
	
	return availableStandsString;
}

- (BOOL) isBonusStation
{
	return [self bonusStation];
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
	
	__weak Station *weakSelf = self;
	
	NSURLSessionDataTask *dataTask = [dataSession dataTaskWithURL: stationDataURL
									    completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
										  
										    __strong __block Station *strongSelf = weakSelf;
										    
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
												    [[NSNotificationCenter defaultCenter] postNotificationName: kStationUpdateErrorNotification object: nil];
												    
												    return;
											    }
											    else
											    {
												    return;
											    }
										    }
										    
										    NSError *serializationError;
										    
										    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: data options: kNilOptions error: &serializationError];
										    
										    if (serializationError)
										    {
											    #if kEnableCrashlytics

											    [[Crashlytics sharedInstance] recordError: serializationError];
											    
											    #endif
											    
										    }
										    
										    NSAssert(!serializationError, @"Serialization error: %@", serializationError);
										    
										    [strongManagedObjectContext performBlockAndWait: ^{
										    
											    [Station internal_updateStation: &strongSelf withUpdatedDictionary: serializedData];
											    
										    }];
										    
									    }];
	
	[dataTask resume];
}

//- (NSString *) description
//{
//	return [NSString stringWithFormat: @"[%@] %@", [self number], [self name]];
//}

@end

@implementation Station (PrivateAdditions)

+ (void) internal_updateStation: (Station *__autoreleasing *) stationToUpdate withUpdatedDictionary: (NSDictionary *) updatedDictionary
{
	[*stationToUpdate setBanking: [updatedDictionary[kStationBanking] boolValue]];
	
	[*stationToUpdate setAvailable: [updatedDictionary[kStationStatus] isEqualToString: kStationStatusOpen] ? YES : NO];
	
	[*stationToUpdate setAvailableBikes: [updatedDictionary[kStationAvailableBikes] unsignedIntegerValue]];
	
	[*stationToUpdate setAvailableBikeStations: [updatedDictionary[kStationAvailableStands] unsignedIntegerValue]];

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
