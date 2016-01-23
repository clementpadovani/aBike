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

static CPCoreDataManager *_sharedCoreDataManager = nil;

static const NSString * kCPCoreDataManagerProjectName;

static NSString * const kCPCoreDataManagerUserFileName = @"User";

@interface CPCoreDataManager ()

@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSPersistentStoreCoordinator *userPersistentStoreCoordinator;
@property (strong, nonatomic) NSPersistentStoreCoordinator *memoryPersistentStoreCoordinator;

@property (strong, nonatomic, readwrite) VEManagedObjectContext *standardContext;
@property (strong, nonatomic, readwrite) VEManagedObjectContext *userContext;
@property (strong, nonatomic, readwrite) VEManagedObjectContext *memoryContext;

@property (strong, nonatomic) NSURL *documentsDirectoryURL;

@property (strong, nonatomic) NSURL *applicationSupportDirectoryURL;

- (void) removeDataStoreFromBackups;

@end

@implementation CPCoreDataManager

+ (CPCoreDataManager *) sharedCoreDataManager
{
	if (_sharedCoreDataManager)
		return _sharedCoreDataManager;
	
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
			
		_sharedCoreDataManager = [[self alloc] init];
		
		kCPCoreDataManagerProjectName = [[VEConsul sharedConsul] contractName];
		
		[_sharedCoreDataManager removeDataStoreFromBackups];
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
		
		NSError *storeError;
		
		NSPersistentStore *newStore;
		
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
		
		NSError *storeError;
		
		NSPersistentStore *newStore;
		
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
		
		NSError *storeError;
		
		NSPersistentStore *newStore;
		
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

- (VEManagedObjectContext *) newImportManagedObjectContext
{	
	NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self model]];
	
	NSError *storeError;
	
	NSPersistentStore *newStore;
	
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



	NSAssert(newStore, @"Failed to create new store. Error: %@", storeError);
	
	[persistentStoreCoordinator setName: @"Import Persistent Store Coordinator"];

	VEManagedObjectContext *importContext = [[VEManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
	
	[importContext setUndoManager: nil];
	
	[importContext setPersistentStoreCoordinator: persistentStoreCoordinator];
	
	[importContext setName: @"Import Managed Object Context"];

	return importContext;
}

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
	
	_documentsDirectoryURL = documentsDirectoryURL;
	
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
	
	if (![[NSFileManager defaultManager] fileExistsAtPath: [applicationSupportDirectoryURL path] isDirectory: NULL])
	{
		NSError *creationError = nil;
		
		BOOL hasCreated = [[NSFileManager defaultManager] createDirectoryAtURL: applicationSupportDirectoryURL
										   withIntermediateDirectories: YES
														attributes: nil
															error: &creationError];

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
	
	_applicationSupportDirectoryURL = applicationSupportDirectoryURL;
	
	return _applicationSupportDirectoryURL;
}

@end
