//
//  CPCoreDataManager.h
//  Velo'v
//
//  Created by Clément Padovani on 11/8/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

@import CoreData;

@class VEManagedObjectContext;

NS_ASSUME_NONNULL_BEGIN

typedef void (^CPCoreDataManagerSaveCompletionBlock)(BOOL hasSaved, NSArray <NSError *> *__nullable errors);

@interface CPCoreDataManager : NSObject

@property (strong, nonatomic, readonly) VEManagedObjectContext *standardContext;
@property (strong, nonatomic, readonly) VEManagedObjectContext *userContext;
@property (strong, nonatomic, readonly) VEManagedObjectContext *memoryContext;
@property (strong, nonatomic, readonly) VEManagedObjectContext *searchMemoryContext;

@property (copy, nonatomic, readonly) NSURL *applicationSupportDirectoryURL;

+ (CPCoreDataManager *) sharedCoreDataManager;

- (void) performSaveWithCompletionBlock: (CPCoreDataManagerSaveCompletionBlock) completionBlock;

- (VEManagedObjectContext *) newImportManagedObjectContext;

- (instancetype) init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
