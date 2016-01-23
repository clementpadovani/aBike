//
//  UserSettings+Additions.m
//  abike—Lyon
//
//  Created by Clément Padovani on 3/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "UserSettings+Additions.h"

#import "CPCoreDataManager.h"

#import "VEConsul.h"

#import "VETimeFormatter.h"

static const CLLocationDegrees kUserSettingsVECityRectLargerCityRectRatio = .1;

const VECityRect VECityRectEmpty = { 0, 0, 0, 0 };

BOOL VECityRectIsEqualToCityRect(VECityRect aCityRect, VECityRect anotherCityRect)
{
	return ((aCityRect.minLat == anotherCityRect.minLat) &&
		   (aCityRect.maxLat == anotherCityRect.maxLat) &&
		   (aCityRect.minLon == anotherCityRect.minLon) &&
		   (aCityRect.maxLon == anotherCityRect.maxLon));
}

BOOL VECityRectIsValid(VECityRect aCityRect)
{
	return !VECityRectIsEmpty(aCityRect);
}

BOOL VECityRectIsEmpty(VECityRect aCityRect)
{
	return VECityRectIsEqualToCityRect(aCityRect, VECityRectEmpty);
}

BOOL VECityRectContainsLocationCoordinates(VECityRect aCityRect, CLLocationCoordinate2D locationCoordinates)
{
	return ((aCityRect.maxLat >= locationCoordinates.latitude) &&
		   (aCityRect.minLat <= locationCoordinates.latitude) &&
		   (aCityRect.maxLon >= locationCoordinates.longitude) &&
		   (aCityRect.minLon <= locationCoordinates.longitude));
}

VECityRect VECityRectMakeLarger(VECityRect aCityRect)
{
	VECityRect largerCityRect;
	
	CLLocationDegrees minLat, maxLat, minLon, maxLon;
	
	CLLocationDegrees newMinLat, newMaxLat, newMinLon, newMaxLon;
	
	minLat = aCityRect.minLat;
	
	maxLat = aCityRect.maxLat;
	
	minLon = aCityRect.minLon;
	
	maxLon = aCityRect.maxLon;
	
	CLLocationDegrees latitudeDifference = maxLat - minLat;
	
	CLLocationDegrees longitudeDifference = maxLon - minLon;
	
	latitudeDifference *= kUserSettingsVECityRectLargerCityRectRatio;
	
	longitudeDifference *= kUserSettingsVECityRectLargerCityRectRatio;
	
	newMinLat = minLat;
	
	newMaxLat = maxLat;
	
	newMinLon = minLon;
	
	newMaxLon = maxLon;
	
	//
	
	newMinLat -= latitudeDifference;
	
	newMaxLat += latitudeDifference;
	
	newMinLon -= longitudeDifference;
	
	newMaxLon += longitudeDifference;
	
	largerCityRect.minLat = newMinLat;
	
	largerCityRect.minLon = newMinLon;
	
	largerCityRect.maxLat = newMaxLat;
	
	largerCityRect.maxLon = newMaxLon;
	
	return largerCityRect;
}

#if lowDataRefreshTimes

static const NSTimeInterval kUserSettingsReloadDataThreshold = 10;

#else

static const NSTimeInterval kUserSettingsReloadDataThreshold = 300;

#endif

@interface NSData (CityRect)

+ (NSData *) dataWithCityRect: (VECityRect) cityRect;

@property (NS_NONATOMIC_IOSONLY, readonly) VECityRect cityRect;

@end

@implementation NSData (CityRect)

+ (NSData *) dataWithCityRect: (VECityRect) cityRect
{
	return [NSData dataWithBytes: &cityRect length: sizeof(VECityRect)];
}

- (VECityRect) cityRect
{
	VECityRect cityRect;
	
	[self getBytes: &cityRect length: sizeof(VECityRect)];
	
	return cityRect;
}

@end

@interface UserSettings (PrimitiveMethods)

@property (nonatomic, retain) NSData *primitiveCityRect;
@property (nonatomic, retain) NSData *primitiveLargerCityRect;
@property (nonatomic, retain) NSNumber *primitiveMapType;
@property (nonatomic, retain) NSDate *primitiveLastDataImportDate;

@end

@implementation UserSettings (PrimitiveMethods)

@dynamic primitiveCityRect;
@dynamic primitiveLargerCityRect;
@dynamic primitiveMapType;
@dynamic primitiveLastDataImportDate;

@end

@interface UserSettings (PrivateAdditions)

- (void) setLargerCityRect: (VECityRect) largerCityRect withNotification: (BOOL) notifies;

- (NSString *) getSecret;

- (NSData *) makeItSecret: (NSString *) aSecret;

@end

@implementation UserSettings (PrivateAdditions)

- (void) setLargerCityRect: (VECityRect) largerCityRect withNotification: (BOOL) notifies
{
	[self willChangeValueForKey: @"largerCityRect"];
	
	[self setPrimitiveLargerCityRect: [NSData dataWithCityRect: largerCityRect]];
	
	[self didChangeValueForKey: @"largerCityRect"];
	
	if (notifies)
		[[NSNotificationCenter defaultCenter] postNotificationName: kUserSettingsCityRectChangedValueNotification object: nil userInfo: nil];
}

- (NSString *) getSecret
{
	NSString *secret;
	
	NSUUID *aSecret = [[UIDevice currentDevice] identifierForVendor];
	
	if (!aSecret)
		CPLog(@"NIL SECRET!");
	
	secret = [aSecret UUIDString];
	
	if (!secret)
		CPLog(@"NIL SECRET");
	
	//CPLog(@"uuid: %@", secret);
	
	return secret;
}

- (NSData *) makeItSecret: (NSString *) aSecret
{
	NSData *theSecret;
	
	const char *something = [aSecret UTF8String];
	
	uint8_t anotherThing[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(something, (CC_LONG) strlen(something), anotherThing);

	NSMutableString *somethingElse = [NSMutableString stringWithCapacity: CC_MD5_DIGEST_LENGTH * 2];
	
	for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
	{
		[somethingElse appendFormat: @"%02x", anotherThing[i]];
	}
	
	//CPLog(@"something else: %@", somethingElse);
	
	theSecret = [somethingElse dataUsingEncoding: NSUTF8StringEncoding];
	
//	NSString *testString = [[NSString alloc] initWithData: theSecret encoding: NSUTF8StringEncoding];
//	
//	CPLog(@"test: %@", testString);
//	
//	CPLog(@"equal: %@", [testString isEqualToString: somethingElse] ? @"YES" : @"NO");
//	
//	CPLog(@"lenght: %d", CC_MD5_DIGEST_LENGTH);
//	
//	CPLog(@"data length: %lu", [theSecret length]);
	
	return theSecret;
}

@end

static UserSettings *_sharedSettings = nil;

@implementation UserSettings (Additions)

+ (UserSettings *) sharedSettings
{	
	if (!_sharedSettings)
	{
		NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName: @"UserSettings"];
		
		[fetchRequest setReturnsObjectsAsFaults: NO];
		
		[fetchRequest setFetchLimit: 1];
		
		__block NSArray *fetchedResults;
		
		__block NSError *fetchError;
		
		VEManagedObjectContext *userContext = [[CPCoreDataManager sharedCoreDataManager] userContext];
		
		[userContext performBlockAndWait: ^{
			
			fetchedResults = [userContext executeFetchRequest: fetchRequest error: &fetchError];
			
		}];

		#if kEnableCrashlytics

			if (fetchError)
				[[Crashlytics sharedInstance] recordError: fetchError];

		#endif


		NSAssert(!fetchError, @"Fetch error: %@", fetchError);
		
		UserSettings *fetchedUserSettings = [fetchedResults firstObject];
		
		if (fetchedUserSettings)
		{
			_sharedSettings = fetchedUserSettings;
		}
		else
		{
			__block UserSettings *sharedSettings;
			
			[userContext performBlockAndWait: ^{
				
				sharedSettings = [self newEntityInManagedObjectContext: userContext];
				
				[sharedSettings firstTimeSetup];
				
			}];
			
			_sharedSettings = sharedSettings;
		}
		
//		[[NSNotificationCenter defaultCenter] addObserver: _sharedSettings selector: @selector(userSettingsHaveChanged:) name: NSUserDefaultsDidChangeNotification object: nil];
	}
	
	return _sharedSettings;
}

- (BOOL) hasValidCityRect
{
	return (VECityRectIsValid([self cityRect]) && VECityRectIsValid([self largerCityRect]));
}

#pragma clang diagnostic push

#pragma clang diagnostic ignored "-Wunreachable-code"

- (BOOL) canShowAds
{
	#if !kShowAdRemover
	
		return NO;
	
	#endif
	
	BOOL disableAds = [[NSUserDefaults standardUserDefaults] boolForKey: kDisableAds];
	
	if (!disableAds)
		return YES;
	
	NSData *savedData = [self adRemover];
	
	if (!savedData || [savedData length] == 0)
		return YES;
	
	NSUInteger length = [savedData length];
	
	if (length != (CC_MD5_DIGEST_LENGTH * 2))
	{
		[self userIsntANiceOne];
		
		return YES;
	}
	
	NSData *someData = [self makeItSecret: [self getSecret]];
	
	BOOL dataEqual = [someData isEqualToData: savedData];
	
//	CPLog(@"data equal: %@", dataEqual ? @"YES" : @"NO");
//	
//	NSString *savedString = [[NSString alloc] initWithData: savedData encoding: NSUTF8StringEncoding];
//	
//	NSString *someString = [[NSString alloc] initWithData: someData encoding: NSUTF8StringEncoding];
//	
//	CPLog(@"saved: %@", savedString);
//	
//	CPLog(@"some: %@", someString);
//	
//	BOOL stringsEqual = [someString isEqualToString: savedString];
//	
//	CPLog(@"strings equal: %@", stringsEqual ? @"YES" : @"NO");
	
	if (!dataEqual)
		[self userIsntANiceOne];
	
	return !dataEqual;
}

#pragma clang diagnostic pop

- (void) userIsntANiceOne
{
	[self setAdRemover: nil];
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey: kDisableAds];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	#if kEnableCrashlytics

		[Answers logCustomEventWithName: @"User isn't a nice one"
					customAttributes: nil];
	
	#endif
}

- (void) userIsANiceOne
{
	NSData *someData = [self makeItSecret: [self getSecret]];
	
	//NSString *dataString = [[NSString alloc] initWithData: someData encoding: NSUTF8StringEncoding];
	
	//CPLog(@"data string: %@", dataString);
	
	[self setAdRemover: someData];
	
	[[NSUserDefaults standardUserDefaults] setBool: YES forKey: kDisableAds];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		[VETimeFormatter updateAdRemover];
		
	});
}

- (void) firstTimeSetup
{
	[self setMapType: MKMapTypeStandard];
	
	[self setCityRect: VECityRectEmpty];
	
	[self setLargerCityRect: VECityRectEmpty];
	
	[self setSetup: YES];
}

- (BOOL) canLoadData
{
	BOOL canTest = NO;
	
	if (canTest)
	{
		NSData *data = [self makeItSecret: [self getSecret]];
	
		[self setAdRemover: data];
	}
	else
	{
		//[self makeItSecret: [self getSecret]];
	}
	
	[self willAccessValueForKey: @"canLoadData"];
	
	BOOL canLoadData;
	
	NSDate *lastFetchDate = [self lastDataImportDate];
	
	if (lastFetchDate)
	{
		//CPLog(@"lastFetch: %@", lastFetchDate);
		
		NSTimeInterval lastFetchIntervalSinceNow = [[NSDate date] timeIntervalSinceDate: lastFetchDate];
		
		//CPLog(@"lastFetch interval: %f", lastFetchIntervalSinceNow);
		
		if (lastFetchIntervalSinceNow > kUserSettingsReloadDataThreshold)
		{
			//CPLog(@"can load data");
			
			canLoadData = YES;
		}
		else
		{
			//CPLog(@"can't load data");
			
			canLoadData = NO;
		}
	}
	else
	{
		//CPLog(@"last fetch is nil");
		
		canLoadData = YES;
	}
	
	[self didAccessValueForKey: @"canLoadData"];
	
	return canLoadData;
}

- (void) setLastDataImportDate: (NSDate *) lastDataImportDate
{
	[self willChangeValueForKey: @"lastDataImportDate"];
	
	[self willChangeValueForKey: @"canLoadData"];
	
	[self setPrimitiveLastDataImportDate: lastDataImportDate];
	
	[self didChangeValueForKey: @"lastDataImportDate"];
	
	[self didChangeValueForKey: @"canLoadData"];
}

- (void) setMapType: (MKMapType) mapType
{
	[self willChangeValueForKey: @"mapType"];
	
	[self setPrimitiveMapType: @(mapType)];
	
	[self didChangeValueForKey: @"mapType"];
}
- (MKMapType) mapType
{
	[self willAccessValueForKey: @"mapType"];
	
	MKMapType mapType = [[self primitiveMapType] unsignedIntegerValue];
	
	[self didAccessValueForKey: @"mapType"];
	
	return mapType;
}

- (VECityRect) cityRect
{
	[self willAccessValueForKey: @"cityRect"];
	
	VECityRect cityRect = [[self primitiveCityRect] cityRect];
	
	[self didAccessValueForKey: @"cityRect"];
	
	return cityRect;
}

- (void) setCityRect: (VECityRect) cityRect
{
	[self willChangeValueForKey: @"cityRect"];
	
	[self setPrimitiveCityRect: [NSData dataWithCityRect: cityRect]];
	
	[self didChangeValueForKey: @"cityRect"];
}

- (VECityRect) largerCityRect
{
	[self willAccessValueForKey: @"largerCityRect"];
	
	VECityRect largerCityRect = [[self primitiveLargerCityRect] cityRect];
	
	[self didAccessValueForKey: @"largerCityRect"];
	
	if (!VECityRectIsValid(largerCityRect))
	{
		largerCityRect = VECityRectMakeLarger([self cityRect]);
		
		[self setLargerCityRect: largerCityRect withNotification: NO];
	}
	
	return largerCityRect;
}

- (void) setLargerCityRect: (VECityRect) largerCityRect
{
	[self setLargerCityRect: largerCityRect withNotification: YES];
}

@end
