//
//  VEBaseModel.h
//  abike—Lyon
//
//  Created by Clément Padovani on 4/2/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface VEBaseModel : NSManagedObject

+ (NSString *) entityName;

+ (instancetype) newEntityInManagedObjectContext: (NSManagedObjectContext *) context;

@end

NS_ASSUME_NONNULL_END
