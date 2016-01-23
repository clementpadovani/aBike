//
//  VEDataImporter.h
//  Velo'v
//
//  Created by Clément Padovani on 7/17/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

@class Station;

extern NSString * const kStationNumber;

extern NSString * const kStationContractIdentifier;

extern NSString * const kStationName;

extern NSString * const kStationAddress;

extern NSString * const kStationCoords;

extern NSString * const kStationCoordsLatitude;

extern NSString * const kStationCoordsLongitude;

extern NSString * const kStationBanking;

extern NSString * const kStationBonus;

extern NSString * const kStationStatus;

extern NSString * const kStationStatusOpen;

extern NSString * const kStationTotalStands;

extern NSString * const kStationAvailableStands;

extern NSString * const kStationAvailableBikes;

extern NSString * const kStationContentAge;

@interface VEDataImporter : NSObject

+ (BOOL) isImportingData;

+ (NSURLSession *) aBikeSession;

+ (void) tearDownSession;

+ (NSURL *) dataURLForIdentifier: (NSString *) identifier;

+ (NSURL *) stationDataURLForStation: (Station *) aStation;

+ (void) importStationListDataWithStationsData: (NSData *) stationsData;

+ (void) attemptToDownloadStationListForIdentifier: (NSString *) identifier withCompletionHandler: (void (^)(NSError *error, NSData *stationData)) completionHandler;

@end
