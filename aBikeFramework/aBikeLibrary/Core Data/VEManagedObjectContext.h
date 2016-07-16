//
//  VEManagedObjectContext.h
//  abike—Lyon
//
//  Created by Clément Padovani on 3/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

@import CoreData;

NS_ASSUME_NONNULL_BEGIN

@interface VEManagedObjectContext : NSManagedObjectContext

- (BOOL) attemptToSave: (NSError **) error;

@end

NS_ASSUME_NONNULL_END
