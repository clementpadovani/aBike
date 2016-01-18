//
//  VEManagedObjectContext.m
//  abike—Lyon
//
//  Created by Clément Padovani on 3/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEManagedObjectContext.h"

@implementation VEManagedObjectContext

- (BOOL) attemptToSave: (NSError *__autoreleasing *) error
{
	if (![self hasChanges])
		return YES;
	
	NSError *saveError = nil;
	
	BOOL hasSaved = [self save: &saveError];
	
	if (error)
		*error = saveError;
	
	return hasSaved;
}

@end
