//
//  aBikeFrameworkTests.m
//  aBikeFrameworkTests
//
//  Created by Clément Padovani on 3/12/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

@import XCTest;

@import aBikeFramework;

@import CoreData;

#import "VEaBikeFrameworkTestsConsulDelegate.h"

#import "VEConstants.h"

@interface aBikeFrameworkTests : XCTestCase

@end

@implementation aBikeFrameworkTests

+ (BOOL) isRunningOnCI
{
	BOOL isRunningOnCI = [[[NSProcessInfo processInfo] environment][@"CI"] boolValue];

	BOOL isRunningOnTravis = [[[NSProcessInfo processInfo] environment][@"TRAVIS"] boolValue];

	return isRunningOnCI && isRunningOnTravis;
}

+ (void) setUp
{
	[super setUp];

	[VEaBikeFrameworkTestsConsulDelegate sharedDelegate];
}

- (void)setUp {
    [super setUp];

	CPLog(@"setup");

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) testSharedConsul
{
	XCTAssertNotNil([VEConsul sharedConsul]);

	XCTAssertNotNil([[VEConsul sharedConsul] delegate]);
}

- (void) testCoreDataManager
{
	CPCoreDataManager *manager = [CPCoreDataManager sharedCoreDataManager];

	NSArray *contexts = @[[manager standardContext],
					  [manager userContext],
					  [manager memoryContext],
					  [manager searchMemoryContext]];

	XCTAssertEqual([contexts count], 4ul);
}

- (void) testURLSession
{
	NSURL *stationsDownloadURL = [VEDataImporter dataURLForIdentifier: [[VEaBikeFrameworkTestsConsulDelegate sharedDelegate] contractNameForConsul: nil]];

	XCTAssertNotNil(stationsDownloadURL);

	NSString *downloaderAPIToken;

	if (![[self class] isRunningOnCI])
		downloaderAPIToken = kJCDecauxAPIKey;
//	else

	JCDECAUXAPITOKEN=2d93849e709748d86c10c303ba94a773f14de3a2
}

@end
