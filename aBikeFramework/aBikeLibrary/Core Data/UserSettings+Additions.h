//
//  UserSettings+Additions.h
//  abike—Lyon
//
//  Created by Clément Padovani on 3/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "UserSettings.h"


extern const VECityRect VECityRectEmpty;

extern BOOL VECityRectIsEqualToCityRect(VECityRect const aCityRect, VECityRect const anotherCityRect);

extern BOOL VECityRectIsValid(VECityRect const aCityRect);

extern BOOL VECityRectIsEmpty(VECityRect const aCityRect);

extern BOOL VECityRectContainsLocationCoordinates(VECityRect const aCityRect, CLLocationCoordinate2D const locationCoordinates);

extern VECityRect VECityRectMakeLarger(VECityRect aCityRect);

#ifndef RELEASE

static inline NSString * NSStringFromVECityRect(VECityRect const aCityRect)
{
	return [NSString stringWithFormat: @"Min: {%f:%f} Max: {%f: %f}", aCityRect.minLat, aCityRect.minLon, aCityRect.maxLat, aCityRect.maxLon];
}

#endif

static NSString * const kUserSettingsCityRectChangedValueNotification = @"kUserSettingsCityRectChangedValueNotification";

@interface UserSettings (Additions)

@property (nonatomic, readonly) BOOL hasValidCityRect;

@property (nonatomic, readonly) BOOL canShowAds;

+ (UserSettings *) sharedSettings;

- (void) userIsANiceOne;

@end
