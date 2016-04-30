//
//  VEConsul.h
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "CPCoreDataManager.h"

@import WatchConnectivity;

@class VEConsul;

@class VEWindow;

@class VEMapViewController;

@class Station;

@protocol VEConsulDelegate <NSObject>

- (NSString *) contractNameForConsul: (VEConsul *) consul;

- (NSString *) cityNameForConsul: (VEConsul *) consul;

- (NSString *) cityServiceNameForConsul: (VEConsul *) consul;

- (NSString *) cityRegionNameForConsul: (VEConsul *) consul;

- (UIColor *) mainColorForConsul: (VEConsul *) consul;

- (MKCoordinateRegion) mapRegionForConsul: (VEConsul *) consul;

#if (SCREENSHOTS==1)
- (CLLocation *) locationForScreenshots;
#endif

@end

@protocol VEAppDelegate <NSObject>

- (BOOL) applicationWillFinishLaunchingWithOptions: (NSDictionary *) launchOptions;

- (BOOL) applicationDidFinishLaunchingWithOptions: (NSDictionary *) launchOptions;

- (BOOL) applicationOpenURL: (NSURL *) url sourceApplication: (NSString *) sourceApplication annotation: (id) annotation;

- (void) applicationWillResignActive;

- (void) applicationDidBecomeActive;

- (void) applicationDidEnterBackground;

- (void) applicationWillReturnToForeground;

- (void) applicationWillTerminate;

- (void) applicationDidReceiveMemoryWarning;

#if DEBUG == 1

- (void) motionShake;

#endif

@end

@interface VEConsul : NSObject <VEAppDelegate, WCSessionDelegate>

@property (nonatomic, weak) id <VEConsulDelegate> delegate;

@property (nonatomic, strong) VEWindow *window;

@property (nonatomic, weak, readonly) VEMapViewController *mapViewController;

@property (nonatomic, copy, readonly) NSString *contractName;

@property (nonatomic, copy, readonly) NSString *cityName;

@property (nonatomic, copy, readonly) NSString *cityServiceName;
@property (nonatomic, copy, readonly) NSString *cityRegionName;

@property (nonatomic, strong, readonly) UIColor *mainColor;

@property (nonatomic, readonly, getter = isReachable) BOOL reachable;

@property (atomic) BOOL canSave;

@property (nonatomic, readonly) VECityRect currentCityRect;

@property (nonatomic, readonly) VECityRect largerCurrentCityRect;

@property (nonatomic, readonly) BOOL canUpdateStations;

@property (nonatomic, readonly, getter = isInBackground) BOOL inBackground;

@property (NS_NONATOMIC_IOSONLY, readonly) MKCoordinateRegion initialMapRegion;

@property (NS_NONATOMIC_IOSONLY, readonly) CGFloat statusBarHeight;

#if (SCREENSHOTS==1)
- (CLLocation *) screenshotsLocation;
#endif

+ (VEConsul *) sharedConsul;

- (void) updateWatchStationsWithStations: (NSArray <Station *> *) stations;

- (void) setup;

- (void) reachable;

- (void) unReachable;

- (void) saveContext;

- (void) forceSaveContext;

- (void) startLoadingSpinner;

- (void) stopLoadingSpinner;

@end
