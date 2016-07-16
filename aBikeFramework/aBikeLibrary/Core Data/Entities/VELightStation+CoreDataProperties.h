//
//  VELightStation+CoreDataProperties.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VELightStation.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELightStation (CoreDataProperties)

@property (nullable, nonatomic, retain) CLLocation *location;
@property (nonatomic, assign) int16_t stationID;

@end

NS_ASSUME_NONNULL_END
