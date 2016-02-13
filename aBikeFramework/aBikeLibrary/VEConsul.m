//
//  VEConsul.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEConsul.h"

#import "UIColor+MainColor.h"

#import "VEConnectionManager.h"

#import "VEWindow.h"

#import "VEMapViewController.h"

#import "VEAlertManager.h"

#import "VEDataImporter.h"

#import "NSBundle+VELibrary.h"

#import "VETimeFormatter.h"

#import "UIDevice+Additions.h"

#if (SCREENSHOTS==1)

@import SimulatorStatusMagic;

#endif

static VEConsul *_sharedConsul = nil;

#if DEBUG == 1

@interface UIWindow ()

+ (UIWindow *) keyWindow;

- (id) _autolayoutTrace;

@end

#endif

@interface VEConsul ()

@property (nonatomic, weak, readwrite) VEMapViewController *mapViewController;

@property (nonatomic, copy, readwrite) NSString *contractName;

@property (nonatomic, copy, readwrite) NSString *cityName;

@property (nonatomic, copy, readwrite) NSString *cityServiceName;

@property (nonatomic, copy, readwrite) NSString *cityRegionName;

@property (nonatomic, strong, readwrite) UIColor *mainColor;

@property (nonatomic) NSUInteger loadingSpinnerCounter;

@property (nonatomic, readwrite) BOOL canUpdateStations;

@property (nonatomic, readwrite, getter = isInBackground) BOOL inBackground;

@property (nonatomic, weak) UIAlertController *reachabilityAlertController;

+ (NSDictionary *) registeredDefaults;

- (void) stationUpdateErrorNotification: (NSNotification *) notification;

- (void) loadData;

- (void) processData: (NSData *) stationsData;

- (void) saveContextWithForce: (BOOL) withForce;

- (void) increaseLoadingSpinnerCounter;

- (void) decreaseLoadingSpinnerCounter;

@end

@implementation VEConsul

+ (VEConsul *) sharedConsul
{
	if (_sharedConsul)
		return _sharedConsul;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedConsul = [[self alloc] init];
	});
	
	return _sharedConsul;
}

+ (NSDictionary *) registeredDefaults
{
	return @{kUnitSystemKey : @"default",
		    kHasShownAlertKey : @(YES),
		    kNumberOfBikeStations : @(kNumberOfBikeStationsDefault)};
}

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		_loadingSpinnerCounter = 0;
		
		_inBackground = NO;
		
		[VEConnectionManager sharedConnectionManger];
	}
	
	return self;
}

- (void) setup
{
	[[NSUserDefaults standardUserDefaults] registerDefaults: [[self class] registeredDefaults]];
	
	NSAssert([self delegate], @"ABORT. Currently have no delegate");
	
	[CPCoreDataManager sharedCoreDataManager];
	
	[UIColor ve_setupColorsCache];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(stationUpdateErrorNotification:) name: kStationUpdateErrorNotification object: nil];
	
	[VETimeFormatter startNotifications];
}

- (BOOL) applicationWillFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
	[self setCanSave: YES];

	#if (SCREENSHOTS==1)

		[[SDStatusBarManager sharedInstance] enableOverrides];

	#endif
	
	return YES;
}

- (BOOL) applicationDidFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
	#if kEnableCrashlytics
	
		[Fabric with: @[[Crashlytics class]]];
	
	#endif

#if kEnableCrashlytics

	if (launchOptions &&
	    [launchOptions allKeys] &&
	    [[launchOptions allKeys] count])
		[Answers logCustomEventWithName: @"Launch with options"
					customAttributes: launchOptions];

#endif

	[VELocationManager sharedLocationManager];

	#if !TARGET_OS_TV
	[[UIApplication sharedApplication] setStatusBarHidden: NO];
	#endif
	
	VEWindow *window = [[VEWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

	#if !TARGET_OS_TV
	[window setWindowLevel: UIWindowLevelStatusBar];
	#endif
	
	[window setBackgroundColor: [UIColor ve_mainBackgroundColor]];
	
	[window setTintColor: [UIColor ve_mainColor]];
	
	VEMapViewController *mapViewController = [[VEMapViewController alloc] init];
	
	[window setRootViewController: mapViewController];
	
	[self setMapViewController: mapViewController];
	
	[window showLaunchImage];
	
	[window makeKeyAndVisible];
	
	[window hideLaunchImage];
	
	[self setWindow: window];
	
	[[VEConnectionManager sharedConnectionManger] setCanCallBack: YES];
		
	return YES;
}

- (BOOL) applicationOpenURL: (NSURL *) url sourceApplication: (NSString *) sourceApplication annotation: (id) annotation
{
#if kEnableCrashlytics
	
	NSMutableDictionary *attributes = [@{} mutableCopy];
	
	if (url &&
	    [url path] &&
	    [[url path] length])
		attributes[@"url"] = [url path];
	
	if (sourceApplication &&
	    [sourceApplication length])
		attributes[@"source_application"] = sourceApplication;
	
	if (annotation &&
	    [annotation description])
		attributes[@"annotation"] = [annotation description];
	
	[Answers logCustomEventWithName: @"Remote Launch"
				customAttributes: attributes];
	
#endif
	
	return YES;
}

- (void) reachable
{
	dispatch_async(dispatch_get_main_queue(), ^{
		
		if ([self reachabilityAlertController])
		{
			[[self reachabilityAlertController] dismissViewControllerAnimated: YES completion: NULL];
		}
		
//		static dispatch_once_t onceToken;
//		dispatch_once(&onceToken, ^{

			//CPLog(@"load data");
			
			[self loadData];
//		});
		
	});
}

- (void) unReachable
{
	//CPLog(@"unreachable");
	
	if ([self reachabilityAlertController])
		return;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		__weak VEConsul *weakSelf = self;
		
		VEAlertManagerConfigurationBlock configurationBlock = ^NSString *(VEAlertStringType stringType) {
			
			__strong VEConsul *strongSelf = weakSelf;
			
			if (!strongSelf)
			{
				CPLog(@"NIL STRONG SELF");
			}
			
			switch (stringType)
			{
				case VEAlertStringTypeTitle:
				{
					NSString *serviceName = [strongSelf cityServiceName];

#pragma clang diagnostic push

#pragma clang diagnostic ignored "-Wformat-nonliteral"


					return [NSString localizedStringWithFormat: CPLocalizedString(@"Cannot connect to %@", @"nointernet_error_desc_key"), serviceName];

					#pragma clang diagnostic pop
				}
				case VEAlertStringTypeMessage:
					return CPLocalizedString(@"Please check your internet connection.", @"nointernet_error_failure_reason_key");
				case VEAlertStringTypeCancelButtonTitle:
					return nil;
					
				case VEAlertStringTypeActionButtonTitle:
					return nil;
			}
			
		};
		
		VEAlertManagerHasSetupBlock hasSetupBlock = ^(id alertView) {
		
			__strong VEConsul *strongSelf = weakSelf;
			
			if (!strongSelf)
			{
				CPLog(@"NIL STRONG SELF");
			}
			
				[strongSelf setReachabilityAlertController: alertView];

		};
		
		[VEAlertManager showAlertOfType: VEAlertTypeNoButtons
							withConfigurationBlock: configurationBlock
								withHasSetupBlock: hasSetupBlock
				  withCompletionBlock: NULL];
	});
}

- (void) loadData
{
	__weak VEConsul *weakSelf = self;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		__strong VEConsul *strongSelf = weakSelf;
		
		[strongSelf startLoadingSpinner];
		
	});
	
	void (^completionHandler)(NSError *downloadError, NSData *downloadedData) = ^(NSError *downloadError, NSData *downloadedData) {
		
		__strong VEConsul *strongSelf = weakSelf;
		
		if (downloadError)
		{
			#if kEnableCrashlytics

				[[Crashlytics sharedInstance] recordError: downloadError];

			#endif
			
			dispatch_sync(dispatch_get_main_queue(), ^{
				
				VEAlertManagerConfigurationBlock configurationBlock = ^NSString *(VEAlertStringType alertStringType) {
					
					switch (alertStringType)
					{
						case VEAlertStringTypeTitle:
							return [downloadError localizedDescription];
						case VEAlertStringTypeMessage:
							return [downloadError localizedFailureReason];
						case VEAlertStringTypeCancelButtonTitle:
							return nil;
						case VEAlertStringTypeActionButtonTitle:
							return nil;
					}
					
				};
				
				
				
				[VEAlertManager showAlertOfType: VEAlertTypeNoButtons
									withConfigurationBlock: configurationBlock
										withHasSetupBlock: NULL
						  withCompletionBlock: NULL];
				
			});
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				[strongSelf stopLoadingSpinner];
				
			});
			
			return;
		}
		
		[strongSelf processData: downloadedData];
	};
	
	[VEDataImporter attemptToDownloadStationListForIdentifier: [self contractName] withCompletionHandler: completionHandler];
}

- (void) processData: (NSData *) stationsData
{
	__weak VEConsul *weakSelf = self;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		[VEDataImporter importStationListDataWithStationsData: stationsData];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			__strong VEConsul *strongSelf = weakSelf;
			
			[[strongSelf mapViewController] loadMapData];
			
			[strongSelf stopLoadingSpinner];
		});
		
	});
}

- (MKCoordinateRegion) initialMapRegion
{
	return [[self delegate] mapRegionForConsul: self];
}

- (VECityRect) currentCityRect
{
	__block VECityRect cityRect;
	
	[[[CPCoreDataManager sharedCoreDataManager] userContext] performBlockAndWait: ^{
		
		cityRect = [[UserSettings sharedSettings] cityRect];
		
	}];
	
	return cityRect;
}

- (VECityRect) largerCurrentCityRect
{
	__block VECityRect largerCurrentCityRect;
	
	[[[CPCoreDataManager sharedCoreDataManager] userContext] performBlockAndWait: ^{
		
		largerCurrentCityRect = [[UserSettings sharedSettings] largerCityRect];
		
	}];
	
	return largerCurrentCityRect;
}

- (NSString *) contractName
{
	if (!_contractName)
	{
		[self setContractName: [[self delegate] contractNameForConsul: self]];
	}
	
	return _contractName;
}

- (NSString *) cityName
{
	if (!_cityName)
	{
		[self setCityName: [[self delegate] cityNameForConsul: self]];
	}
	
	return _cityName;
}

- (NSString *) cityServiceName
{
	if (!_cityServiceName)
	{
		[self setCityServiceName: [[self delegate] cityServiceNameForConsul: self]];
	}
	
	return _cityServiceName;
}

- (NSString *) cityRegionName
{
	if (!_cityRegionName)
	{
		[self setCityRegionName: [[self delegate] cityRegionNameForConsul: self]];
	}
	
	return _cityRegionName;
}

- (UIColor *) mainColor
{
	if (!_mainColor)
	{
		[self setMainColor: [[self delegate] mainColorForConsul: self]];
	}
	
	return _mainColor;
}

#if (SCREENSHOTS==1)
- (CLLocation *) screenshotsLocation
{
	return [[self delegate] locationForScreenshots];
}
#endif

- (BOOL) isReachable
{
	return [[VEConnectionManager sharedConnectionManger] isReachable];
}

- (void) stationUpdateErrorNotification:(NSNotification *)notification
{
	CPLog(@"station update error");
	
	CPLog(@"main thread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
	
	
	
	[self setCanUpdateStations: NO];
}

- (void) increaseLoadingSpinnerCounter
{
	[self setLoadingSpinnerCounter: ([self loadingSpinnerCounter] + 1)];
}

- (void) decreaseLoadingSpinnerCounter
{
	if ([self loadingSpinnerCounter] > 1)
		[self setLoadingSpinnerCounter: ([self loadingSpinnerCounter] - 1)];
	else
		[self setLoadingSpinnerCounter: 0];
}

- (void) startLoadingSpinner
{
	#if !TARGET_OS_TV
	if ([self loadingSpinnerCounter] == 0)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
			
		});
	}
	
	[self increaseLoadingSpinnerCounter];
	#endif
}

- (void) stopLoadingSpinner
{
	#if !TARGET_OS_TV
	[self decreaseLoadingSpinnerCounter];
	
	if ([self loadingSpinnerCounter] == 0)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
			
		});
	}
	#endif
}

- (void) saveContextWithForce: (BOOL) withForce
{
	if (![self canSave] && !withForce)
	{
		CPLog(@"cant save");
		
		return;
	}
	
	[[CPCoreDataManager sharedCoreDataManager] performSaveWithCompletionBlock: ^(BOOL hasSaved, NSArray *saveErrors) {
		
		//CPLog(@"has saved: %@", hasSaved ? @"YES" : @"NO");
		
		NSAssert(hasSaved, @"Save errors: %@", saveErrors);
		
	}];
}

- (void) saveContext
{
	//CPLog(@"save w/ out force");
	
	[self saveContextWithForce: NO];
}

- (void) forceSaveContext
{
	//CPLog(@"save w/ force");
	
	[self saveContextWithForce: YES];
}

- (void) applicationWillResignActive
{
	//CPLog(@"will resign active");
	
	[[self window] setTintAdjustmentMode: UIViewTintAdjustmentModeDimmed];
	
	[self saveContext];
}

- (void) applicationDidBecomeActive
{
	//CPLog(@"did become active");
	
	//[[self window] setTintAdjustmentMode: UIViewTintAdjustmentModeAutomatic];
	
	[[self window] setTintAdjustmentMode: UIViewTintAdjustmentModeNormal];
	
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void) applicationDidEnterBackground
{
	//CPLog(@"background");
	
	[self setInBackground: YES];
	
	[[VELocationManager sharedLocationManager] appDidGoToBackground];
}

- (void) applicationWillReturnToForeground
{
	//CPLog(@"foreground");
	
	[self setInBackground: NO];
	
	[[VELocationManager sharedLocationManager] appWillGoToForeground];
	
	[[self window] setTintAdjustmentMode: UIViewTintAdjustmentModeNormal];
}

- (void) applicationWillTerminate
{
	CPLog(@"will terminate");

	[[VEDataImporter aBikeSession] invalidateAndCancel];
	
	//CPLog(@"will terminate");
	
	//CPLog(@"will save");
	
	[self forceSaveContext];
	
	//CPLog(@"has saved");
	
	[[NSNotificationCenter defaultCenter] removeObserver: self
										   name: kStationUpdateErrorNotification
										 object: nil];
	
	[UIColor ve_stripColorsCache];
	
	[VEDataImporter tearDownSession];
	
	[VELocationManager tearSharedLocationManagerDown];
	
	[VEConnectionManager tearDownConnectionManager];
}

- (void) applicationDidReceiveMemoryWarning
{
	CPLog(@"received low memory warning");
	
	[self saveContext];
	
	CPLog(@"free mem: %@", [UIDevice ve_freeMemory]);
	
	#if kEnableCrashlytics
	
		[Answers logCustomEventWithName: @"low memory event"
					customAttributes: @{@"memory" : [UIDevice ve_freeMemory]}];
	
	#endif
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (CGFloat) statusBarHeight
{
	CGFloat height = [[[[self window] rootViewController] topLayoutGuide] length];

	#if !TARGET_OS_TV
	if (height <= 0)
		height = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
	#endif
	
	return height;
}

#if DEBUG == 1

- (void) motionShake
{
	CPLog(@"shake");
	
	CPLog(@"%@", [[UIWindow keyWindow] _autolayoutTrace]);
	
//	[[UIWindow keyWindow] exerciseAmbiguityInLayout];

//	CPLog(@"%@", [[UIWindow keyWindow] _autolayoutTra/ce]);

	//[self applicationWillResignActive];
}

#endif

@end
