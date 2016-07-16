//
//  VEUserSettings.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEBaseModel.h"
#import "VEGeometry.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kVEUserSettingsCityRectChangedValueNotification = @"kVEUserSettingsCityRectChangedValueNotification";

@interface VEUserSettings : VEBaseModel

+ (instancetype) sharedSettings;

- (BOOL) hasValidCityRect;

- (BOOL) isSetup;

@end

NS_ASSUME_NONNULL_END

#import "VEUserSettings+CoreDataProperties.h"
