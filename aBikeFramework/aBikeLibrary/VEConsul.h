//
//  VEConsul.h
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#if kEnableWatchSupport == 1

@import WatchConnectivity;

#endif

#import "VEGeometry.h"

@class VEConsul;

@class VEWindow;

@class VEMapViewController;

@class VEStation;

NS_ASSUME_NONNULL_BEGIN

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

#if kEnableWatchSupport == 1

@interface VEConsul : NSObject <VEAppDelegate, WCSessionDelegate>

#else

@interface VEConsul : NSObject <VEAppDelegate>

#endif

@property (nonatomic, weak) id <VEConsulDelegate> delegate;

@property (nonatomic, strong) VEWindow *window;

@property (nonatomic, weak, readonly) VEMapViewController *mapViewController;

@property (nonatomic, copy, readonly) NSString *contractName;

@property (nonatomic, copy, readonly) NSString *cityName;

@property (nonatomic, copy, readonly) NSString *cityServiceName;

@property (nonatomic, copy, readonly) NSString *cityRegionName;

@property (nonatomic, copy, readonly) UIColor *mainColor;

@property (nonatomic, assign, readonly, getter = isReachable) BOOL reachable;

@property (atomic, assign) BOOL canSave;

@property (nonatomic, assign, readonly) VECityRect currentCityRect;

@property (nonatomic, assign, readonly) VECityRect largerCurrentCityRect;

@property (nonatomic, assign, readonly) BOOL canUpdateStations;

@property (nonatomic, assign, readonly, getter = isInBackground) BOOL inBackground;

@property (nonatomic, assign, readonly) MKCoordinateRegion initialMapRegion;

@property (nonatomic, assign, readonly) CGFloat statusBarHeight;

#if (SCREENSHOTS==1)
- (CLLocation *) screenshotsLocation;
#endif

+ (VEConsul *) sharedConsul;

#if kEnableWatchSupport == 1

- (void) updateWatchStationsWithStations: (NSArray <VEStation *> *) stations;

#endif

- (void) setup;

- (void) reachable;

- (void) unReachable;

- (void) saveContext;

- (void) forceSaveContext;

- (void) startLoadingSpinner;

- (void) stopLoadingSpinner;

@end

NS_ASSUME_NONNULL_END
