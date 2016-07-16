//
//  VEUserSettings+CoreDataProperties.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VEUserSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEUserSettings (CoreDataProperties)

@property (nonatomic, assign) BOOL canLoadData;
@property (nonatomic, assign) VECityRect cityRect;
@property (nullable, nonatomic, retain) NSString *contractIdentifier;
@property (nonatomic, assign) VECityRect largerCityRect;
@property (nullable, nonatomic, retain) NSDate *lastDataImportDate;
@property (nonatomic, assign) MKMapType mapType;
@property (nonatomic, assign) BOOL setup;

@end

NS_ASSUME_NONNULL_END
