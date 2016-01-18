//
//  Station+Additions.h
//  abike—Lyon
//
//  Created by Clément Padovani on 3/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "Station.h"

extern NSString * const kStationOpenKey;

static NSString * const kStationUpdateErrorNotification = @"kStationUpdateErrorNotification";

@interface Station (Additions) <MKAnnotation>

+ (Station *) stationFromStationDictionary: (NSDictionary *) stationDictionary inContext: (NSManagedObjectContext *) context;

- (void) fetchContentWithUserForceReload: (BOOL) userForceReload;

- (NSString *) availableBikesString;

- (NSString *) availableBikeStationsString;

- (BOOL) isBonusStation;

@end
