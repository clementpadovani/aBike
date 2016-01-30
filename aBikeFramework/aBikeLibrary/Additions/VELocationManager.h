//
//  VELocationManager.h
//  Velo'v
//
//  Created by Clément Padovani on 10/10/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

static NSString * const kVELocationManagerUserInCityRectDidChangeNotification = @"kVELocationManagerUserInCityRectDidChangeNotification";

@class VELocationManager;

@protocol VELocationManagerDelegate <NSObject>

- (void) userHasMovedToNewLocation: (CLLocation *) newLocation;

- (void) locationUpdatesHavePaused;

- (void) locationUpdatesHaveResumed;

- (void) didEnterBackground;

- (void) willReturnToForeground;

@end

@interface VELocationManager : NSObject

@property (nonatomic, weak) id <VELocationManagerDelegate> delegate;
@property (nonatomic, readonly, getter = userIsInCity) BOOL userInCity;
@property (nonatomic, readonly) CLLocation *currentLocation;

+ (VELocationManager *) sharedLocationManager;

+ (void) tearSharedLocationManagerDown;

- (void) appDidGoToBackground;

- (void) appWillGoToForeground;

@end

NS_ASSUME_NONNULL_END
