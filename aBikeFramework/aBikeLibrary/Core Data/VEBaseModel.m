//
//  VEBaseModel.m
//  abike—Lyon
//
//  Created by Clément Padovani on 4/2/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEBaseModel.h"

@implementation VEBaseModel

+ (NSString *) entityName
{
	return NSStringFromClass(self);
}

+ (instancetype) newEntityInManagedObjectContext: (NSManagedObjectContext *) context
{
    return [NSEntityDescription insertNewObjectForEntityForName: [self entityName] inManagedObjectContext: context];
}


@end
