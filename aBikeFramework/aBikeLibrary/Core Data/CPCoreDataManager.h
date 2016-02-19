//
//  CPCoreDataManager.h
//  Velo'v
//
//  Created by Clément Padovani on 11/8/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "Station+Additions.h"
#import "UserSettings+Additions.h"
#import "LightStation.h"
#import "VEManagedObjectContext.h"

typedef void (^CPCoreDataManagerSaveCompletionBlock)(BOOL hasSaved, NSArray *errors);

@interface CPCoreDataManager : NSObject
{

}

@property (strong, nonatomic, readonly) VEManagedObjectContext *standardContext;
@property (strong, nonatomic, readonly) VEManagedObjectContext *userContext;
@property (strong, nonatomic, readonly) VEManagedObjectContext *memoryContext;
@property (strong, nonatomic, readonly) VEManagedObjectContext *searchMemoryContext;

+ (CPCoreDataManager *) sharedCoreDataManager;

- (void) performSaveWithCompletionBlock: (CPCoreDataManagerSaveCompletionBlock) completionBlock;

- (VEManagedObjectContext *) newImportManagedObjectContext;

@end
