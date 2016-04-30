//
//  VELocationManager.m
//  Velo'v
//
//  Created by Clément Padovani on 10/10/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "VELocationManager.h"

#import "VEConsul.h"

#import "VEAlertManager.h"

#import "VEMapViewController.h"

@import StoreKit;

#if (SCREENSHOTS==1)

#import "CLSimulationManager.h"

#endif

/**
 *
 *	LYON GPS COORDINATES (FOR USE IN SIMULATOR)
 *
 *	LAT: 45.741024	LON: 4.816045
 *
 */

static const CLLocationDistance kVELocationManagerDistanceFilter = 32;

//static const CLLocationDistance kVELocationManagerDistanceFilter = 0;

static const NSTimeInterval kVELocationManagerLastLocationAgeFilter = 60.;

static NSString * const kCrashlyticsAuthorizationStateKey = @"Authorization State";

static NSString * const kCrashlyticsCurrentLocationKey = @"Current Location";

@interface VELocationManager () <SKStoreProductViewControllerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic) BOOL hasShownNotInCityAlert;

@property (nonatomic, readwrite, getter = userIsInCity) BOOL userInCity;

@property (nonatomic) CLAuthorizationStatus lastAuthorizationStatus;

@property (nonatomic, weak) UIAlertController *disabledLocationServicesAlertController;

#if (SCREENSHOTS==1)

@property (nonatomic, strong) CLSimulationManager *simulator;

#endif

+ (BOOL) cityRect: (VECityRect) cityRect containsLocation: (CLLocation *) location withAbort: (BOOL *) abort;

+ (BOOL) canShowNotInLocationAlert;

+ (void) setCanShowNotInLocationAlert: (BOOL) canShowAlert;

+ (BOOL) locationIsFreshEnough: (CLLocation *) aLocation;

- (void) userInCityCheckForLocation: (CLLocation *) location withAbort: (BOOL *) abort;

- (void) userCityRectDidChangeNotification: (NSNotification *) notification;

- (void) showUserNotInCityAlertForLocation: (CLLocation *) aLocation;

- (void) showAppForCity: (NSDictionary *) cityDictionary;

@end

static VELocationManager *_sharedLocationManager = nil;

@implementation VELocationManager

+ (BOOL) canShowNotInLocationAlert
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: kHasShownAlertKey];
}

+ (void) setCanShowNotInLocationAlert: (BOOL) canShowAlert
{
	BOOL canShowAlertSaved = [[NSUserDefaults standardUserDefaults] boolForKey: kHasShownAlertKey];
	
	if (canShowAlert == canShowAlertSaved)
		return;
	
	[[NSUserDefaults standardUserDefaults] setBool: canShowAlert forKey: kHasShownAlertKey];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	//CPLog(@"hasShownAlert: %@", [[NSUserDefaults standardUserDefaults] boolForKey: kHasShownAlertKey] ? @"YES" : @"NO");
}

#if (SCREENSHOTS==1)
- (CLLocation *) currentLocation
{
	[self setUserInCity: YES];
	
	return [[VEConsul sharedConsul] screenshotsLocation];
}
#else
- (CLLocation *) currentLocation
{
	return (CLLocation * __nonnull) [[self locationManager] location];
}
#endif

+ (VELocationManager *) sharedLocationManager
{
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		_sharedLocationManager = [[self alloc] init];
	});
	
	return _sharedLocationManager;
}

+ (void) tearSharedLocationManagerDown
{
	_sharedLocationManager = nil;
}

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		CLLocationManager *locationManager = [[CLLocationManager alloc] init];
		
		[locationManager setDelegate: self];
		
		[locationManager requestWhenInUseAuthorization];

		[locationManager setDesiredAccuracy: kCLLocationAccuracyBest];

		#if !TARGET_OS_TV

		[locationManager setActivityType: CLActivityTypeFitness];

		[locationManager setPausesLocationUpdatesAutomatically: YES];
		
		[locationManager startUpdatingLocation];

		#else

		[locationManager requestLocation];

		#endif

		[locationManager setDistanceFilter: kVELocationManagerDistanceFilter];

		_locationManager = locationManager;

#if (SCREENSHOTS==1)

		_userInCity = YES;


		CLSimulationManager *simulator = [[CLSimulationManager alloc] init];

		CLLocation *fakeLocation = [[VEConsul sharedConsul] screenshotsLocation];

		[simulator appendSimulatedLocation: fakeLocation];

		[simulator startLocationSimulation];

		[self setSimulator: simulator];

		#endif

		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userCityRectDidChangeNotification:) name: kUserSettingsCityRectChangedValueNotification object: nil];
	}
	
	return self;
}

- (void) userCityRectDidChangeNotification: (NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self userInCityCheckForLocation: [[self locationManager] location] withAbort: NULL];
    });
}

- (void) userInCityCheckForLocation: (CLLocation *) location withAbort: (BOOL *) abort
{
	VECityRect currentCityRect = [[VEConsul sharedConsul] largerCurrentCityRect];
	
	BOOL _internalAbort = NO;
	
	BOOL inCity = [VELocationManager cityRect: currentCityRect containsLocation: location withAbort: &_internalAbort];
	
	if (abort)
		*abort = _internalAbort;
	
	if (_internalAbort)
	{
		//CPLog(@"");
	}
	
	BOOL originalValue = [self userIsInCity];
	
	[self setUserInCity: inCity];
	
	if (!_internalAbort)
		[self showUserNotInCityAlertForLocation: location];
	
	if (originalValue == inCity)
	{
		return;
	}
	else
	{
		if ([self disabledLocationServicesAlertController])
		{
			[[self disabledLocationServicesAlertController] dismissViewControllerAnimated: YES completion: NULL];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName: kVELocationManagerUserInCityRectDidChangeNotification object: nil userInfo: nil];
	}
}

- (void) showUserNotInCityAlertForLocation: (CLLocation *) aLocation
{
	if (![self userIsInCity] && ![self hasShownNotInCityAlert] && [[self class] canShowNotInLocationAlert])
	{
		NSURL *plistURL = [NSBundle ve_fileURLForCities];
		
		//CPLog(@"url: %@", plistURL);
		
		NSArray *citiesArray = [NSArray arrayWithContentsOfURL: plistURL];
		
		NSDictionary *goodCityDict;
		
		if (citiesArray)
		{
		
		//CPLog(@"array: %@", citiesArray);
		
		
		
		for (NSDictionary *aDict in citiesArray)
		{
			NSData *coordsData = aDict[@"coords"];
			
			CLLocationCoordinate2D cityCoords;
			
			[coordsData getBytes: &cityCoords length: sizeof(cityCoords)];
			
			CLLocation *theLocation = [[CLLocation alloc] initWithLatitude: cityCoords.latitude longitude: cityCoords.longitude];
			
			CLLocationDistance distance = [aLocation distanceFromLocation: theLocation];
			
			//CPLog(@"distance: %f", distance);
			
			CLLocationDistance allowedDistance = [aDict[@"distance"] doubleValue];
			
			if (distance <= allowedDistance)
			{
				goodCityDict = aDict;
			}
			
		}
		}
		
		//CPLog(@"good city: %@", goodCityDict);
		
		CPLog(@"not in city");
		
//		if (goodCityDict)
//			[self showAppForCity: goodCityDict];
		
		CLGeocoder *geocoder = [[CLGeocoder alloc] init];
		
		[geocoder reverseGeocodeLocation: aLocation completionHandler: ^(NSArray *placemarks, NSError *error) {
			
			NSString *alertMessage;
			
			if (error)
			{
				//CPLog(@"geocoder error: %@", error);
				
				NSInteger errorCode = [error code];
				
				if (errorCode == kCLErrorGeocodeFoundNoResult)
				{
					//CPLog(@"found no result");
				}
				
				#if kEnableCrashlytics

				[[Crashlytics sharedInstance] recordError: error];

				#endif
				
				NSString *cityName = [[VEConsul sharedConsul] cityName];
				
				NSString *regionName = [[VEConsul sharedConsul] cityRegionName];
				
				alertMessage = [NSString stringWithFormat: CPLocalizedString(@"aBike—%@ is designed for the %@ area but feel free to roam around.\nIt’s a long way, good luck!", @"VELocationManager_not_userincity_can_not_geodecode"), cityName, regionName];
			}
			else
			{
				CLPlacemark *placemark = [placemarks firstObject];
				
				NSString *localityString = [placemark locality];
				
				#if kEnableCrashlytics
				
				if (localityString)
				{
					[Answers logCustomEventWithName: @"Not in city rect"
								customAttributes: @{@"City" : localityString}];
				}
				else
				{
					[Answers logCustomEventWithName: @"Not in city rect (nil placemark"
								customAttributes: nil];
				}
				
				#endif
				
				NSString *cityName = [[VEConsul sharedConsul] cityName];
				
				NSString *regionName = [[VEConsul sharedConsul] cityRegionName];
				
				if (localityString)
				{
					alertMessage = [NSString stringWithFormat: CPLocalizedString(@"aBike—%@ is designed for the %@ area but feel free to roam around.\nIt’s a long way from %@, good luck!", @"VELocationManager_not_userincity_can_geodecode"), cityName, regionName, localityString];
				}
				else
				{
					alertMessage = [NSString stringWithFormat: CPLocalizedString(@"aBike—%@ is designed for the %@ area but feel free to roam around.\nIt’s a long way, good luck!", @"VELocationManager_not_userincity_can_not_geodecode"), cityName, regionName];
				}
			}
			
			
			//dispatch_async(dispatch_get_main_queue(), ^{
			
			
			
				VEAlertManagerConfigurationBlock configurationBlock = ^NSString *(VEAlertStringType alertStringType) {
					
					switch (alertStringType)
					{
						case VEAlertStringTypeTitle:
							return nil;
						case VEAlertStringTypeMessage:
							return alertMessage;
						case VEAlertStringTypeCancelButtonTitle:
							return nil;
						case VEAlertStringTypeActionButtonTitle:
							return [NSString stringWithFormat: CPLocalizedString(@"Show aBike—%@", @"VELocationManager user not in city, show app"), goodCityDict[@"name"]];
					}
					
				};
			
			VEAlertManagerCompletionBlock completionBlock;
			
			if (goodCityDict)
			{
				__weak VELocationManager *weakSelf = self;
				
				completionBlock = ^(VEAlertButtonType buttonType) {
					
					__strong VELocationManager *strongSelf = weakSelf;
					
					if (!strongSelf)
					{
						CPLog(@"NIL STRONG SELF");
					}
					
					BOOL isCancelButton = buttonType == VEAlertButtonTypeCancel;
					
					//CPLog(@"is cancel button: %@", isCancelButton ? @"YES" : @"NO");
					
					if (!isCancelButton)
					{
						[strongSelf showAppForCity: goodCityDict];
					}
					
				};
			}
			
			VEAlertType alertType = goodCityDict ? VEAlertTypeWithAction : VEAlertTypeWithButtons;
			
			[VEAlertManager showAlertOfType: alertType
				    withConfigurationBlock: configurationBlock
					    withHasSetupBlock: NULL
					  withCompletionBlock: completionBlock];
			//});
			
		}];
		
		
		[self setHasShownNotInCityAlert: YES];
		
		[[self class] setCanShowNotInLocationAlert: NO];
	}
	else if (![self hasShownNotInCityAlert] && [self userIsInCity])
	{
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			
			#if kEnableCrashlytics
			[Answers logCustomEventWithName: @"In city rect"
						customAttributes: nil];
			
			#endif
			
		});
		
		[[self class] setCanShowNotInLocationAlert: YES];
	}
	
	[[self class] setCanShowNotInLocationAlert: [self userIsInCity]];

}

- (void) setDelegate: (id <VELocationManagerDelegate>) delegate
{
	if (![self delegate])
	{
		_delegate = delegate;

#if (SCREENSHOTS==1)

		[self setUserInCity: YES];

		[[self delegate] userHasMovedToNewLocation: [self currentLocation]];

		return;

		#endif

		CLLocation *location = [[self locationManager] location];
		
		if (!location)
			return;
		
		[[self delegate] userHasMovedToNewLocation: location];
	}
	else
	{
		CLLocation *location = [[self locationManager] location];

		if (!location)
			return;

		[delegate userHasMovedToNewLocation: location];
	}
	
	_delegate = delegate;
}

#pragma mark CLLocationManager Delegate Methods

- (void) locationManager: (CLLocationManager *) manager didChangeAuthorizationStatus: (CLAuthorizationStatus) status
{
	//CPLog(@"did change status");
	
	[self setLastAuthorizationStatus: status];
	
	BOOL isRestricted = NO;
	
	BOOL isDenied = NO;
	
	switch (status)
	{
		case kCLAuthorizationStatusRestricted:
			
			//state = @"kCLAuthorizationStatusRestricted";
			
			isRestricted = YES;
			
			break;
			
		case kCLAuthorizationStatusDenied:
			
			//state = @"kCLAuthorizationStatusDenied";
			
			isDenied = YES;
			
			break;
		default:
			break;
	}
	
	
	if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
	{
		//CPLog(@"authorized, we're golden");

		if ([self disabledLocationServicesAlertController])
		{
			[[self disabledLocationServicesAlertController] dismissViewControllerAnimated: YES completion: NULL];
		}
		
		return;
	}
	else if (status == kCLAuthorizationStatusNotDetermined)
	{
		//CPLog(@"awaiting authorization");

		if ([self disabledLocationServicesAlertController])
		{
			CPLog(@"WTF?! HAVE A DISABLED ALERT VIEW WHILE BEING NOT DETERMINED.");

			[[self disabledLocationServicesAlertController] dismissViewControllerAnimated: YES completion: NULL];
		}
		
		return;
	}
	
	NSString *localizedAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"];
	
	NSString *alertTitle = [NSString stringWithFormat: CPLocalizedString(@"Location Services are necessary for %@", @"VELocationManager_locationdisabled_alert_title"), localizedAppName];
	
	NSString *alertMessage;
	
	NSAssert(!(isDenied == isRestricted), @"isDenied: %d isRestricted: %d. Should not be equal. Status: %d", isDenied, isRestricted, status);
	
	if (isDenied && !isRestricted)
	{
		alertMessage = [NSString stringWithFormat: CPLocalizedString(@"Please enable Location Services for %@ in your Privacy Settings.", @"VELocationManager_locationdisabled_alert_message_isDenied"), localizedAppName];
	}
	else if (!isDenied && isRestricted)
	{
		alertMessage = [NSString stringWithFormat: CPLocalizedString(@"Please remove Location Services from your Restrictions. %@ cannot operate without Location Services.", @"VELocationManager_locationdisabled_alert_message_isRestricted"), localizedAppName];
	}
	else
	{
		CPLog(@"WTF?");
	}
	
	NSString *openSettingsMessage = nil;
	
	void (^openSettingsBlock)(VEAlertButtonType buttonType);
	
	VEAlertType alertType = VEAlertTypeNoButtons;
	
		alertType = VEAlertTypeWithAction;
		
		openSettingsMessage = CPLocalizedString(@"Settings", @"VELocationManager_open_settings");
		
		openSettingsBlock = ^(VEAlertButtonType buttonType) {
		
			//CPLog(@"open settings");
			
			[[UIApplication sharedApplication] openURL: (NSURL *__nonnull) [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
			
		};

	VEAlertManagerConfigurationBlock configurationBlock = ^NSString *(VEAlertStringType alertStringType) {
		
		switch (alertStringType)
		{
			case VEAlertStringTypeTitle:
				return alertTitle;
			case VEAlertStringTypeMessage:
				return alertMessage;
			case VEAlertStringTypeCancelButtonTitle:
				return openSettingsMessage;
			case VEAlertStringTypeActionButtonTitle:
				return nil;
		}
		
	};
	
	__weak VELocationManager *weakSelf = self;
	
	VEAlertManagerHasSetupBlock setupBlock = ^(id alertView) {
	
		__strong VELocationManager *strongSelf = weakSelf;
		
		if (!strongSelf)
		{
			CPLog(@"NIL STRONG SELF");
		}
		
		[strongSelf setDisabledLocationServicesAlertController: alertView];
	};
	
	[VEAlertManager showAlertOfType: alertType
						withConfigurationBlock: configurationBlock
							withHasSetupBlock: setupBlock
			  withCompletionBlock: openSettingsBlock];
}

- (void) locationManager: (CLLocationManager *) manager didFailWithError: (NSError *) error
{
	CPLog(@"location mananger did fail with error: %@", error);

	#if kEnableCrashlytics

	BOOL isUnknownError = ([[error domain] isEqualToString: kCLErrorDomain] &&
					   [error code] == kCLErrorLocationUnknown);

	if (!isUnknownError)
		[[Crashlytics sharedInstance] recordError: error];

	#endif
}

- (void) locationManager: (CLLocationManager *) manager didUpdateLocations: (NSArray *) locations
{
	if ([[VEConsul sharedConsul] isInBackground])
		CPLog(@"in bg. aborting");
	
	if ([[VEConsul sharedConsul] isInBackground])
		return;
	
	CLLocation *lastLocation = [locations lastObject];
	
	BOOL isFresh = [VELocationManager locationIsFreshEnough: lastLocation];
	
	if (!isFresh)
	{
		CPLog(@"location isn't fresh");
		
		[[self locationManager] stopUpdatingLocation];

		#if !TARGET_OS_TV

		[[self locationManager] startUpdatingLocation];

		#else

		[[self locationManager] requestLocation];

		#endif
		
		return;
	}
	
//	BOOL isFresh = [VELocationManager locationIsFreshEnough: lastLocation];
//	
//	//CPLog(@"isFresh: %@", isFresh ? @"YES" : @"NO");
//	
//	if (!isFresh)
//	{
//		CLLocation *newLocation = [manager location];
//		
//		CPLog(@"newlocation timestamp: %@", [newLocation timestamp]);
//		
//		CPLog(@"age: %f", [[NSDate date] timeIntervalSinceDate: [newLocation timestamp]]);
//		
//		CPLog(@"isFresh: %@", [VELocationManager locationIsFreshEnough: newLocation] ? @"YES" : @"NO");
//	}
	
	
	
	#if kEnableCrashlytics
	
		[[Crashlytics sharedInstance] setObjectValue: lastLocation forKey: kCrashlyticsCurrentLocationKey];
	
	#endif

	BOOL abort = NO;
	
	[self userInCityCheckForLocation: lastLocation withAbort: &abort];
	
	if (abort)
	{
		CPLog(@"aborting...");
		
		return;
	}
	
	
	
	if ([[self delegate] respondsToSelector: @selector(userHasMovedToNewLocation:)])
		[[self delegate] userHasMovedToNewLocation: lastLocation];
}

- (void) locationManagerDidResumeLocationUpdates: (CLLocationManager *) manager
{
	CPLog(@"did resume location updates");
	
	if ([[self delegate] respondsToSelector: @selector(locationUpdatesHaveResumed)])
		[[self delegate] locationUpdatesHaveResumed];

	CLLocation *location = [manager location];

	if (location)
		if ([[self delegate] respondsToSelector: @selector(userHasMovedToNewLocation:)])
			[[self delegate] userHasMovedToNewLocation: location];
}

- (void) locationManagerDidPauseLocationUpdates: (CLLocationManager *) manager
{
	CPLog(@"did pause location updates");
	
	if ([[self delegate] respondsToSelector: @selector(locationUpdatesHavePaused)])
		[[self delegate] locationUpdatesHavePaused];
}

#pragma mark -

- (void) appDidGoToBackground
{
	//CPLog(@"app did go to background");
	
	[self setLastAuthorizationStatus: [CLLocationManager authorizationStatus]];
	
	[[self locationManager] stopUpdatingLocation];
	
	//CPLog(@"stop updating location");

	if ([self disabledLocationServicesAlertController])
	{
		[[self disabledLocationServicesAlertController] dismissViewControllerAnimated: YES completion: NULL];
	}
		
	[[self delegate] didEnterBackground];
}

- (void) appWillGoToForeground
{
	CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

	BOOL sameStatus = [self lastAuthorizationStatus] == status;
	
	//CPLog(@"same: %@", sameStatus ? @"YES" : @"NO");
	
	//CPLog(@"status: %d", status);

	if (sameStatus)
	{
		if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
		{
			[self locationManager: [self locationManager] didChangeAuthorizationStatus: status];
		}
	}
	
	//CPLog(@"will go to foreground");

	#if !TARGET_OS_TV
		[[self locationManager] startUpdatingLocation];
	#else
		[[self locationManager] requestLocation];
	#endif
	
	[[self delegate] willReturnToForeground];
	
	//CPLog(@"start updating location");
}

- (void) showAppForCity: (NSDictionary *) cityDictionary
{
	#if !TARGET_OS_TV

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		
	
	NSNumber *appId = [cityDictionary[@"appId"] copy];
	
	NSDictionary *attributes = @{SKStoreProductParameterITunesItemIdentifier : appId};
	
	//NSDictionary *attributes = @{SKStoreProductParameterITunesItemIdentifier : @(348986742)};


	SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
	
	[storeViewController setDelegate: self];
	
	[storeViewController loadProductWithParameters: attributes
							 completionBlock: ^(BOOL result, NSError *error) {
								 
								 if (result)
									 CPLog(@"OK");
								 else
									 CPLog(@"error: %@", error);

								#if kEnableCrashlytics

									 if (!result)
										 [[Crashlytics sharedInstance] recordError: error];
								 
								#endif

							 }];
	
	[[[VEConsul sharedConsul] mapViewController] presentViewController: storeViewController
												   animated: YES
												 completion: NULL];
		
	});

	#endif
}

#if !TARGET_OS_TV

- (void) productViewControllerDidFinish: (SKStoreProductViewController *) viewController
{
	CPLog(@"store view finished");
	
	[viewController dismissViewControllerAnimated: YES completion: NULL];
}
#endif

- (void) dealloc
{
	CPLog(@"dealloc");
	
	[_locationManager stopUpdatingLocation];
	
	[_locationManager setDelegate: nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

+ (BOOL) cityRect: (VECityRect) cityRect containsLocation: (CLLocation *) location withAbort: (BOOL *) abort
{
	*abort = NO;
	
	if (!location || !VECityRectIsValid(cityRect))
	{
		*abort = YES;
		
		return NO;
	}
	
	return VECityRectContainsLocationCoordinates(cityRect, [location coordinate]);

}

+ (BOOL) locationIsFreshEnough: (CLLocation *) aLocation
{
	BOOL isFreshEnough = NO;
	
	NSDate *locationDate = [aLocation timestamp];
	
	NSTimeInterval locationAge = [[NSDate date] timeIntervalSinceDate: locationDate];
	
	//CPLog(@"locationage: %f", locationAge);
	
	if (locationAge <= kVELocationManagerLastLocationAgeFilter)
	{
		//CPLog(@"location is fresh enough");
		
		isFreshEnough = YES;
	}
	else
	{
		//CPLog(@"location is old");
	}
	
	return isFreshEnough;
}

@end
