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
	else
		downloaderAPIToken = [[NSProcessInfo processInfo] environment][@"JCDECAUXAPITOKEN"];

	XCTAssertNotNil(downloaderAPIToken);

	XCTAssertNotEqual([downloaderAPIToken length], 0ul);

	NSString *contractName = [[VEConsul sharedConsul] contractName];

	NSString *correctStationListDownloadURLString = [NSString stringWithFormat: @"https://api.jcdecaux.com/vls/v1/stations?contract=%@&apiKey=%@", contractName, downloaderAPIToken];

	NSURL *correctStationListDownloadURL = [NSURL URLWithString: correctStationListDownloadURLString];

	XCTAssertEqualObjects(correctStationListDownloadURL, stationsDownloadURL);

	NSNumber *stationNumber = @(941);

	Station *fakeStation = [Station newEntityInManagedObjectContext: [[CPCoreDataManager sharedCoreDataManager] standardContext]];

	[fakeStation setNumber: stationNumber];

	[fakeStation setContractIdentifier: contractName];

	NSURL *individualStationDownloadURL = [VEDataImporter stationDataURLForStation: fakeStation];

	NSString *correctIndividualStationDownloadURLString = [NSString stringWithFormat: @"https://api.jcdecaux.com/vls/v1/stations/%@?contract=%@&apiKey=%@", stationNumber, contractName, downloaderAPIToken];

	NSURL *correctIndividualStationDownloadURL = [NSURL URLWithString: correctIndividualStationDownloadURLString];

	XCTAssertEqualObjects(correctIndividualStationDownloadURL, individualStationDownloadURL);
}

- (void) testStationCreation
{
	NSString *stationJSONString = @"{\"number\":2005,\"name\":\"2005 - CONFLUENCE H\\u00d4TEL DE R\\u00c9GION\",\"address\":\"101 cours Charlemagne Lyon 2 direction centre ville. Devant l'h\\u00f4tel de R\\u00e9gion\",\"position\":{\"lat\":45.740675,\"lng\":4.819284},\"banking\":true,\"bonus\":false,\"status\":\"OPEN\",\"contract_name\":\"Lyon\",\"bike_stands\":32,\"available_bike_stands\":3,\"available_bikes\":28,\"last_update\":1457893783000}";

	NSData *stationJSONData = [stationJSONString dataUsingEncoding: NSUTF8StringEncoding];

	NSError *serializationError = nil;

	NSDictionary *serializedStationDictionary = [NSJSONSerialization JSONObjectWithData: stationJSONData
																 options: 0
																   error: &serializationError];

	XCTAssertNil(serializationError);

	BOOL serializedDataIsADictionary = [serializedStationDictionary isKindOfClass: [NSDictionary class]];

	XCTAssertTrue(serializedDataIsADictionary, @"Serialized data isn't a dictionary; is of class: %@", NSStringFromClass([serializedStationDictionary class]));

	Station *fakeStation = [Station stationFromStationDictionary: serializedStationDictionary
											 inContext: [[CPCoreDataManager sharedCoreDataManager] standardContext]];

	XCTAssertNotNil(fakeStation);

	XCTAssertEqualObjects([fakeStation number], @(2005));

	NSString *stationName = @"CONFLUENCE HÔTEL DE RÉGION";

	XCTAssertEqualObjects([fakeStation name], stationName);

	NSString *processedStationName = @"Confluence Hôtel De Région";

	XCTAssertEqualObjects([fakeStation processedStationName], processedStationName);

	XCTAssertEqualObjects([fakeStation address], @"101 cours Charlemagne Lyon 2 direction centre ville. Devant l'hôtel de Région");

	CLLocationCoordinate2D correctStationCoordinates = CLLocationCoordinate2DMake(45.740675, 4.819284);

	CLLocationCoordinate2D stationCoordinates = [[fakeStation location] coordinate];

	BOOL areStationCoordinatesEqual = ((fabs(stationCoordinates.latitude - correctStationCoordinates.latitude) < DBL_EPSILON) &&
								(fabs(stationCoordinates.longitude - correctStationCoordinates.longitude) < DBL_EPSILON));

	XCTAssertTrue(areStationCoordinatesEqual, @"Coordinates differ; station: { %f : %f } correct: { %f : %f }", stationCoordinates.latitude, stationCoordinates.longitude, correctStationCoordinates.latitude, correctStationCoordinates.longitude);

	XCTAssertEqual([fakeStation banking], YES);

	XCTAssertEqual([fakeStation bonusStation], NO);

	XCTAssertEqual([fakeStation available], YES);

	XCTAssertEqualObjects([fakeStation contractIdentifier], @"Lyon");

	XCTAssertEqual([fakeStation availableBikes], 28lu);

	XCTAssertEqual([fakeStation availableBikeStations], 3lu);

	NSNumber *updateTimeNumber = @(1457893783000);

	NSTimeInterval updateTimeInterval = [updateTimeNumber ve_dataContentAgeTimeInterval];

	NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970: updateTimeInterval];

	XCTAssertEqualObjects([fakeStation dataContentAge], updateDate);
}

@end
