//
//  VEBaseModel.h
//  abike—Lyon
//
//  Created by Clément Padovani on 4/2/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

@interface VEBaseModel : NSManagedObject

+ (NSString *) entityName;

+ (instancetype) newEntityInManagedObjectContext: (NSManagedObjectContext *) context;

@end
