//
//  VEUserSettings.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEUserSettings.h"
#import "VEManagedObjectContext.h"
#import "CPCoreDataManager.h"

static const CLLocationDegrees kVEUserSettingsVECityRectLargerCityRectRatio = .1;

const VECityRect VECityRectEmpty = { 0, 0, 0, 0 };

BOOL VECityRectIsEqualToCityRect(VECityRect aCityRect, VECityRect anotherCityRect)
{
    return (((ABS(aCityRect.minLat - anotherCityRect.minLat)) < DBL_EPSILON) &&
            ((ABS(aCityRect.maxLat - anotherCityRect.maxLat)) < DBL_EPSILON) &&
            ((ABS(aCityRect.minLon - anotherCityRect.minLon)) < DBL_EPSILON) &&
            ((ABS(aCityRect.maxLon - anotherCityRect.maxLon)) < DBL_EPSILON));
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
    
    latitudeDifference *= kVEUserSettingsVECityRectLargerCityRectRatio;
    
    longitudeDifference *= kVEUserSettingsVECityRectLargerCityRectRatio;
    
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

static const NSTimeInterval kVEUserSettingsReloadDataThreshold = 10.;

#else

static const NSTimeInterval kVEUserSettingsReloadDataThreshold = 60. * 2.;

#endif

@interface NSData (CityRect)

+ (NSData *) ve_dataWithCityRect: (VECityRect) cityRect;

@property (nonatomic, readonly) VECityRect ve_cityRect;

@end

@implementation NSData (CityRect)

+ (NSData *) ve_dataWithCityRect: (VECityRect) cityRect
{
    return [NSData dataWithBytes: &cityRect length: sizeof(VECityRect)];
}

- (VECityRect) ve_cityRect
{
    VECityRect cityRect;
    
    [self getBytes: &cityRect length: sizeof(VECityRect)];
    
    return cityRect;
}

@end

@interface VEUserSettings (PrimitiveMethods)

@property (nonatomic, retain) NSData *primitiveCityRect;
@property (nonatomic, retain) NSData *primitiveLargerCityRect;
@property (nonatomic, retain) NSNumber *primitiveMapType;
@property (nonatomic, retain) NSDate *primitiveLastDataImportDate;

@end

@implementation VEUserSettings (PrimitiveMethods)

@dynamic primitiveCityRect;
@dynamic primitiveLargerCityRect;
@dynamic primitiveMapType;
@dynamic primitiveLastDataImportDate;

@end

static VEUserSettings *_sharedSettings = nil;

@implementation VEUserSettings

+ (instancetype) sharedSettings
{
    @synchronized(self)
    {
        if (!_sharedSettings)
        {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName: [self entityName]];
            
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
            
            VEUserSettings *fetchedUserSettings = [fetchedResults firstObject];
            
            if (fetchedUserSettings)
            {
                _sharedSettings = fetchedUserSettings;
            }
            else
            {
                __block VEUserSettings *sharedSettings;
                
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
    //	BOOL canTest = NO;
    //
    //	if (canTest)
    //	{
    //		NSData *data = [self makeItSecret: [self getSecret]];
    //
    //		[self setAdRemover: data];
    //	}
    //	else
    //	{
    //		//[self makeItSecret: [self getSecret]];
    //	}
    
    [self willAccessValueForKey: NSStringFromSelector(@selector(canLoadData))];
    
    BOOL canLoadData;
    
    NSDate *lastFetchDate = [self lastDataImportDate];
    
    if (lastFetchDate)
    {
        //CPLog(@"lastFetch: %@", lastFetchDate);
        
        NSTimeInterval lastFetchIntervalSinceNow = [[NSDate date] timeIntervalSinceDate: lastFetchDate];
        
        CPLog(@"lastFetch interval: %f", lastFetchIntervalSinceNow);
        
        if (lastFetchIntervalSinceNow > kVEUserSettingsReloadDataThreshold)
        {
            CPLog(@"can load data");
            
            canLoadData = YES;
        }
        else
        {
            CPLog(@"can't load data");
            
            canLoadData = NO;
        }
    }
    else
    {
        //CPLog(@"last fetch is nil");
        
        canLoadData = YES;
    }
    
    [self didAccessValueForKey: NSStringFromSelector(@selector(canLoadData))];
    
    return canLoadData;
}

- (void) setLastDataImportDate: (NSDate *) lastDataImportDate
{
    [self willChangeValueForKey: NSStringFromSelector(@selector(lastDataImportDate))];
    
    [self willChangeValueForKey: NSStringFromSelector(@selector(canLoadData))];
    
    [self setPrimitiveLastDataImportDate: lastDataImportDate];
    
    [self didChangeValueForKey: NSStringFromSelector(@selector(lastDataImportDate))];
    
    [self didChangeValueForKey: NSStringFromSelector(@selector(canLoadData))];
}

- (void) setMapType: (MKMapType) mapType
{
    [self willChangeValueForKey: NSStringFromSelector(@selector(mapType))];
    
    [self setPrimitiveMapType: @(mapType)];
    
    [self didChangeValueForKey: NSStringFromSelector(@selector(mapType))];
}

- (MKMapType) mapType
{
    [self willAccessValueForKey: NSStringFromSelector(@selector(mapType))];
    
    MKMapType mapType = [[self primitiveMapType] unsignedIntegerValue];
    
    [self didAccessValueForKey: NSStringFromSelector(@selector(mapType))];
    
    return mapType;
}

- (VECityRect) cityRect
{
    [self willAccessValueForKey: NSStringFromSelector(@selector(cityRect))];
    
    VECityRect cityRect = [[self primitiveCityRect] ve_cityRect];
    
    [self didAccessValueForKey: NSStringFromSelector(@selector(cityRect))];
    
    return cityRect;
}

- (void) setCityRect: (VECityRect) cityRect
{
    [self willChangeValueForKey: NSStringFromSelector(@selector(cityRect))];
    
    [self setPrimitiveCityRect: [NSData ve_dataWithCityRect: cityRect]];
    
    [self didChangeValueForKey: NSStringFromSelector(@selector(cityRect))];
}

- (VECityRect) largerCityRect
{
    [self willAccessValueForKey: NSStringFromSelector(@selector(largerCityRect))];
    
    VECityRect largerCityRect = [[self primitiveLargerCityRect] ve_cityRect];
    
    [self didAccessValueForKey: NSStringFromSelector(@selector(largerCityRect))];
    
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

- (void) setLargerCityRect: (VECityRect) largerCityRect withNotification: (BOOL) notifies
{
    [self willChangeValueForKey: NSStringFromSelector(@selector(largerCityRect))];
    
    [self setPrimitiveLargerCityRect: [NSData ve_dataWithCityRect: largerCityRect]];
    
    [self didChangeValueForKey: NSStringFromSelector(@selector(largerCityRect))];
    
    if (notifies)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName: kVEUserSettingsCityRectChangedValueNotification object: nil userInfo: nil];
        });
    }
}

- (BOOL) hasValidCityRect
{
    return (VECityRectIsValid([self cityRect]) && VECityRectIsValid([self largerCityRect]));
}

- (BOOL) isSetup
{
    return [self setup];
}

@end
