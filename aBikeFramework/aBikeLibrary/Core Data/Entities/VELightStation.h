//
//  VELightStation.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELightStation : VEBaseModel

+ (instancetype) lightStationFromStationDictionary: (NSDictionary <NSString *, id> *) stationDictionary inContext: (NSManagedObjectContext *) context;

@end

NS_ASSUME_NONNULL_END

#import "VELightStation+CoreDataProperties.h"
