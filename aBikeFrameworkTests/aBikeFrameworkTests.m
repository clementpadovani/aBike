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

@interface aBikeFrameworkTests : XCTestCase

@end

@implementation aBikeFrameworkTests

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
	XCTAssertNotNil([[CPCoreDataManager sharedCoreDataManager] standardContext]);
}

@end
