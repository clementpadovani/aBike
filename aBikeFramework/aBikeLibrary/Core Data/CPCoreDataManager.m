//
//  CPCoreDataManager.m
//  Velo'v
//
//  Created by Clément Padovani on 11/8/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "CPCoreDataManager.h"

#import "VEConsul.h"

#import "NSBundle+VELibrary.h"
#import "VEManagedObjectContext.h"

static CPCoreDataManager *_sharedCoreDataManager = nil;

static NSString * kCPCoreDataManagerProjectName;

static NSString * const kCPCoreDataManagerUserFileName = @"User";

@interface CPCoreDataManager ()

@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSPersistentStoreCoordinator *userPersistentStoreCoordinator;
@property (strong, nonatomic) NSPersistentStoreCoordinator *memoryPersistentStoreCoordinator;

@property (strong, nonatomic, readwrite) VEManagedObjectContext *standardContext;
@property (strong, nonatomic, readwrite) VEManagedObjectContext *userContext;
@property (strong, nonatomic, readwrite) VEManagedObjectContext *memoryContext;

@property (strong, nonatomic, readwrite) VEManagedObjectContext *searchMemoryContext;

@property (copy, nonatomic) NSURL *documentsDirectoryURL;

@property (copy, nonatomic, readwrite) NSURL *applicationSupportDirectoryURL;

- (void) removeDataStoreFromBackups;

@end

@implementation CPCoreDataManager

+ (CPCoreDataManager *) sharedCoreDataManager
{
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
			
		_sharedCoreDataManager = [[self alloc] init];
		
		kCPCoreDataManagerProjectName = [[VEConsul sharedConsul] contractName];
		
		[_sharedCoreDataManager removeDataStoreFromBackups];

		[_sharedCoreDataManager testVersions];
	});
	
	return _sharedCoreDataManager;
}

- (void) performSaveWithCompletionBlock: (CPCoreDataManagerSaveCompletionBlock) completionBlock
{
	__block BOOL hasSavedStandard;
	
	__block BOOL hasSavedUser;
	
	__block NSError *standardSaveError;
	
	__block NSError *userSaveError;
	
	[[self standardContext] performBlockAndWait: ^{
		
		hasSavedStandard = [[self standardContext] attemptToSave: &standardSaveError];
		
	}];
	
	[[self userContext] performBlockAndWait: ^{
		
		hasSavedUser = [[self userContext] attemptToSave: &userSaveError];
		
	}];

	BOOL hasSaved = (hasSavedStandard && hasSavedUser);

	#if kEnableCrashlytics

	if (!hasSaved)
	{
		if (!hasSavedStandard)
		{
			[[Crashlytics sharedInstance] recordError: standardSaveError];
		}

		if (!hasSavedUser)
		{
			[[Crashlytics sharedInstance] recordError: userSaveError];
		}
	}

	#endif

	if (hasSaved)
		completionBlock(YES, nil);
	
	NSMutableArray *saveTempErrors = nil;
	
	if (!hasSaved)
	{
		saveTempErrors = [NSMutableArray arrayWithCapacity: 2];
		
		if (!hasSavedStandard)
			[saveTempErrors addObject: standardSaveError];
		
		if (!hasSavedUser)
			[saveTempErrors addObject: userSaveError];
	}


	NSArray *saveErrors = [saveTempErrors copy];
	
	completionBlock(hasSaved, saveErrors);
}

- (void) testVersions
{
	NSURL *mainstoreURL = [self applicationSupportDirectoryURL];

	NSString *projectName = (NSString *) kCPCoreDataManagerProjectName;

	mainstoreURL = [[mainstoreURL URLByAppendingPathComponent: projectName] URLByAppendingPathExtension: @"sqlite"];

	if (![[NSFileManager defaultManager] fileExistsAtPath: (NSString * __nonnull) [mainstoreURL path]])
		return;

	NSPersistentStoreCoordinator *tempPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self model]];

	NSError *addError = nil;

	NSDictionary *configuration = @{NSReadOnlyPersistentStoreOption : @(YES)};

	NSPersistentStore *store = [tempPersistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
																			configuration: nil
																					  URL: mainstoreURL
																				  options: configuration
																					error: &addError];

	if (addError)
		CPLog(@"error: %@", addError);

	if ([[addError domain] isEqualToString: NSCocoaErrorDomain] &&
		([addError code] == NSPersistentStoreIncompatibleSchemaError ||
		[addError code] == NSPersistentStoreIncompatibleVersionHashError))
	{

		NSError *deletionError = nil;

		if (![[NSFileManager defaultManager] removeItemAtURL: [self applicationSupportDirectoryURL]
													   error: &deletionError])
		{
			CPLog(@"failed to delete");
		}

		[self setApplicationSupportDirectoryURL: nil];

		[self applicationSupportDirectoryURL];
	}

	if (store)
	{
		NSError *removeError = nil;

		if (![tempPersistentStoreCoordinator removePersistentStore: store
															 error: &removeError])
		{
			CPLog(@"remove error: %@", removeError);
		}
	}

	tempPersistentStoreCoordinator = nil;
}

- (NSManagedObjectModel *) model
{
	if (!_model)
	{		
		NSURL *modelURL = [[NSBundle ve_libraryResources] URLForResource: @"aBike" withExtension: @"momd"];

		NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
		
		_model = model;
	}
	
	return _model;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
	if (!_persistentStoreCoordinator)
	{
		NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self model]];
		
		NSError *storeError = nil;
		
		NSPersistentStore *newStore = nil;
		
		NSURL *storeURL = [self applicationSupportDirectoryURL];
		
		NSString *projectName = (NSString *) kCPCoreDataManagerProjectName;
		
		storeURL = [[storeURL URLByAppendingPathComponent: projectName] URLByAppendingPathExtension: @"sqlite"];
		
		NSDictionary *pragmaDictionary = @{ @"journal_mode" : @"DELETE" };
		
		NSDictionary *storeOptions = @{NSInferMappingModelAutomaticallyOption : @(YES),
								 NSMigratePersistentStoresAutomaticallyOption : @(YES),
								 NSSQLitePragmasOption : pragmaDictionary};
		
		newStore = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
												  configuration: @"Stations"
														  URL: storeURL
													   options: storeOptions
														error: &storeError];

		#if kEnableCrashlytics

		if (storeError || !newStore)
			[[Crashlytics sharedInstance] recordError: storeError];

		#endif

		if (storeError)
			CPLog(@"store error: %@", storeError);

		NSAssert(newStore, @"Failed to create new store. Error: %@", storeError);
		
		[persistentStoreCoordinator setName: @"Main Persistent Store Coordinator"];
		
		_persistentStoreCoordinator = persistentStoreCoordinator;
	}
	
	return _persistentStoreCoordinator;
}

- (VEManagedObjectContext *) standardContext
{
	if (!_standardContext)
	{
		VEManagedObjectContext *context = [[VEManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
		
		[context setUndoManager: nil];
		
		[context setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
		
		[context setName: @"Standard Managed Object Context"];

		_standardContext = context;
	}
	
	return _standardContext;
}

- (NSPersistentStoreCoordinator *) userPersistentStoreCoordinator
{
	if (!_userPersistentStoreCoordinator)
	{
		NSPersistentStoreCoordinator *userPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self model]];
		
		NSError *storeError = nil;
		
		NSPersistentStore *newStore = nil;
		
		NSURL *storeURL = [self documentsDirectoryURL];
		
		storeURL = [[storeURL URLByAppendingPathComponent: kCPCoreDataManagerUserFileName] URLByAppendingPathExtension: @"sqlite"];
		
		NSDictionary *pragmaDictionary = @{ @"journal_mode" : @"DELETE" };

		NSDictionary *storeOptions = @{NSInferMappingModelAutomaticallyOption : @(YES),
								 NSMigratePersistentStoresAutomaticallyOption : @(YES),
								 NSSQLitePragmasOption : pragmaDictionary};
		
		newStore = [userPersistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
													 configuration: @"User"
															 URL: storeURL
														  options: storeOptions
														    error: &storeError];

		#if kEnableCrashlytics

		if (storeError || !newStore)
			[[Crashlytics sharedInstance] recordError: storeError];

		#endif

		if (storeError)
			CPLog(@"store error: %@", storeError);

		NSAssert(newStore, @"Failed to create new store. Error: %@", storeError);
		
		[userPersistentStoreCoordinator setName: @"User Persistent Store Coordinator"];

		_userPersistentStoreCoordinator = userPersistentStoreCoordinator;
	}
	
	return _userPersistentStoreCoordinator;
}

- (VEManagedObjectContext *) userContext
{
	if (!_userContext)
	{
		VEManagedObjectContext *userContext = [[VEManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
		
		[userContext setUndoManager: nil];
		
		[userContext setPersistentStoreCoordinator: [self userPersistentStoreCoordinator]];
		
		[userContext setName: @"User Managed Object Context"];

		_userContext = userContext;
	}
	
	return _userContext;
}

- (NSPersistentStoreCoordinator *) memoryPersistentStoreCoordinator
{
	if (!_memoryPersistentStoreCoordinator)
	{
		NSPersistentStoreCoordinator *memoryPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self model]];
		
		NSError *storeError = nil;
		
		NSPersistentStore *newStore = nil;
		
		newStore = [memoryPersistentStoreCoordinator addPersistentStoreWithType: NSInMemoryStoreType
													   configuration: @"Memory"
															   URL: nil
														    options: nil
															 error: &storeError];

		#if kEnableCrashlytics

			if (storeError || !newStore)
				[[Crashlytics sharedInstance] recordError: storeError];

		#endif



		NSAssert(newStore, @"Failed to create new store. Error: %@", storeError);
		
		[memoryPersistentStoreCoordinator setName: @"Memory Persistent Store Coordinator"];

		_memoryPersistentStoreCoordinator = memoryPersistentStoreCoordinator;
	}
	
	return _memoryPersistentStoreCoordinator;
}

- (VEManagedObjectContext *) memoryContext
{
	if (!_memoryContext)
	{
		VEManagedObjectContext *memoryContext = [[VEManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
		
		[memoryContext setUndoManager: nil];
		
		[memoryContext setPersistentStoreCoordinator: [self memoryPersistentStoreCoordinator]];
		
		[memoryContext setName: @"User Managed Object Context"];

		_memoryContext = memoryContext;
	}
	
	return _memoryContext;
}

- (VEManagedObjectContext *) searchMemoryContext
{
	if (!_searchMemoryContext)
	{
		VEManagedObjectContext *memoryContext = [[VEManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];

		[memoryContext setUndoManager: nil];

		[memoryContext setPersistentStoreCoordinator: [self memoryPersistentStoreCoordinator]];

		[memoryContext setName: @"Search Managed Object Context"];

		_searchMemoryContext = memoryContext;
	}

	return _searchMemoryContext;
}

- (VEManagedObjectContext *) newImportManagedObjectContext
{
    VEManagedObjectContext *newImportManagedObjectContext = [[VEManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];

    [newImportManagedObjectContext setUndoManager: nil];

    [newImportManagedObjectContext setName: @"newImportManagedObjectContext"];

    [newImportManagedObjectContext setParentContext: [self standardContext]];

    return newImportManagedObjectContext;
}

//- (VEManagedObjectContext *) newImportManagedObjectContext
//{	
//	NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self model]];
//	
//	NSError *storeError = nil;
//	
//	NSPersistentStore *newStore = nil;
//	
//	NSURL *storeURL = [self applicationSupportDirectoryURL];
//
//	storeURL = [[storeURL URLByAppendingPathComponent: kCPCoreDataManagerProjectName] URLByAppendingPathExtension: @"sqlite"];
//	
//	NSDictionary *pragmaDictionary = @{ @"journal_mode" : @"DELETE" };
//
//	NSDictionary *storeOptions = @{NSInferMappingModelAutomaticallyOption : @(YES),
//							 NSMigratePersistentStoresAutomaticallyOption : @(YES),
//							 NSSQLitePragmasOption : pragmaDictionary};
//	
//	newStore = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
//											  configuration: @"Stations"
//													  URL: storeURL
//												   options: storeOptions
//													error: &storeError];
//
//	#if kEnableCrashlytics
//
//		if (storeError || !newStore)
//			[[Crashlytics sharedInstance] recordError: storeError];
//
//	#endif
//
//	if (storeError)
//		CPLog(@"store error: %@", storeError);
//
//
//	NSAssert(newStore, @"Failed to create new store. Error: %@", storeError);
//	
//	[persistentStoreCoordinator setName: @"Import Persistent Store Coordinator"];
//
//	VEManagedObjectContext *importContext = [[VEManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
//	
//	[importContext setUndoManager: nil];
//	
//	[importContext setPersistentStoreCoordinator: persistentStoreCoordinator];
//	
//	[importContext setName: @"Import Managed Object Context"];
//
//	return importContext;
//}

- (void) removeDataStoreFromBackups
{
	NSURL *documentsURL = [self applicationSupportDirectoryURL];
	
	NSDictionary *resultsDictionary = [documentsURL resourceValuesForKeys: @[NSURLIsExcludedFromBackupKey]
													    error: NULL];
	
	if ([resultsDictionary[NSURLIsExcludedFromBackupKey] boolValue])
		return;
	
	NSError *error = nil;
	
	BOOL hasRemoved;
	
	hasRemoved = [documentsURL setResourceValue: @(YES)
								  forKey: NSURLIsExcludedFromBackupKey
								   error: &error];

	#if kEnableCrashlytics

		if (!hasRemoved)
			[[Crashlytics sharedInstance] recordError: error];

	#endif

	NSAssert(hasRemoved, @"Remove from backups error: %@", error);
}

- (NSURL *) documentsDirectoryURL
{
	if (_documentsDirectoryURL)
		return _documentsDirectoryURL;
	
	NSURL *documentsDirectoryURL = [self applicationSupportDirectoryURL];
	
	_documentsDirectoryURL = [documentsDirectoryURL copy];
	
	return _documentsDirectoryURL;
	
//	_documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory: NSDocumentDirectory inDomain: NSUserDomainMask appropriateForURL: nil create: NO error: NULL];
//	
//	return _documentsDirectoryURL;
}

- (NSURL *) applicationSupportDirectoryURL
{
	if (_applicationSupportDirectoryURL)
		return _applicationSupportDirectoryURL;

	#if TARGET_OS_TV

	NSURL *applicationSupportDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory: NSCachesDirectory inDomains: NSUserDomainMask] firstObject];

	#else
	NSURL *applicationSupportDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory: NSApplicationSupportDirectory inDomains: NSUserDomainMask] firstObject];

	#endif

	NSURL *parentDirectory = [applicationSupportDirectoryURL copy];

	applicationSupportDirectoryURL = [applicationSupportDirectoryURL URLByAppendingPathComponent: kCPCoreDataManagerProjectName
																					 isDirectory: YES];


	if (![[NSFileManager defaultManager] fileExistsAtPath: (NSString * __nonnull) [applicationSupportDirectoryURL path] isDirectory: NULL])
	{
		NSError *creationError = nil;
		
		BOOL hasCreated = [[NSFileManager defaultManager] createDirectoryAtURL: applicationSupportDirectoryURL
										   withIntermediateDirectories: YES
														attributes: nil
															error: &creationError];

		NSURL *storeURL = parentDirectory;

		storeURL = [[storeURL URLByAppendingPathComponent: kCPCoreDataManagerProjectName] URLByAppendingPathExtension: @"sqlite"];

		// Migrate

		if ([[NSFileManager defaultManager] fileExistsAtPath: (NSString * __nonnull) [storeURL path]])
		{
			NSError *copyError = nil;

			NSURL *newStoreURL = applicationSupportDirectoryURL;

			newStoreURL = [[newStoreURL URLByAppendingPathComponent: kCPCoreDataManagerProjectName] URLByAppendingPathExtension: @"sqlite"];

			if (![[NSFileManager defaultManager] moveItemAtURL: storeURL
														 toURL: newStoreURL
														 error: &copyError])
			{
				CPLog(@"copy error: %@", copyError);

				#if kEnableCrashlytics
					[[Crashlytics sharedInstance] recordError: copyError];
				#endif
			}
		}

		NSURL *userStoreURL = parentDirectory;

		userStoreURL = [[userStoreURL URLByAppendingPathComponent: kCPCoreDataManagerUserFileName] URLByAppendingPathExtension: @"sqlite"];

		if ([[NSFileManager defaultManager] fileExistsAtPath: (NSString * __nonnull) [userStoreURL path]])
		{
			NSError *copyError = nil;

			NSURL *newStoreURL = applicationSupportDirectoryURL;

			newStoreURL = [[newStoreURL URLByAppendingPathComponent: kCPCoreDataManagerUserFileName] URLByAppendingPathExtension: @"sqlite"];

			if (![[NSFileManager defaultManager] moveItemAtURL: userStoreURL
														 toURL: newStoreURL
														 error: &copyError])
			{
				CPLog(@"copy error: %@", copyError);

#if kEnableCrashlytics
				[[Crashlytics sharedInstance] recordError: copyError];
#endif
			}
		}

#if kEnableCrashlytics

		if (!hasCreated)
			[[Crashlytics sharedInstance] recordError: creationError];

#endif


		NSAssert(hasCreated, @"Error while creating documents directory. Error: %@.", creationError);
		
	}
#if deletePreviousData
	else
	{
		CPLog(@"WILL DELETE PREVIOUS DATA");
		
		NSError *removeError;
		
		if (![[NSFileManager defaultManager] removeItemAtURL: applicationSupportDirectoryURL error: &removeError])
			CPLog(@"removeError: %@", removeError);
		
		BOOL hasCreated;
		
		NSError *creationError;
		
		hasCreated = [[NSFileManager defaultManager] createDirectoryAtURL: applicationSupportDirectoryURL
									   withIntermediateDirectories: YES
													attributes: nil
														error: &creationError];
		
		if (!hasCreated)
			CPLog(@"creationError: %@", creationError);
	}
	
#endif
	
	_applicationSupportDirectoryURL = [applicationSupportDirectoryURL copy];
	
	return _applicationSupportDirectoryURL;
}

@end
