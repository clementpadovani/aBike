//
//  VEDataImporter.h
//  Velo'v
//
//  Created by Clément Padovani on 7/17/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

@class VEStation;

NS_ASSUME_NONNULL_BEGIN

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

+ (NSURL *) stationDataURLForStation: (VEStation *) aStation;

+ (void) importStationListDataWithStationsData: (NSData *) stationsData withCompletionHandler: (void(^)()) completionHandler;

+ (void) attemptToDownloadStationListForIdentifier: (NSString *) identifier withCompletionHandler: (void (^)(NSError * __nullable error, NSData * __nullable stationData)) completionHandler;

@end

NS_ASSUME_NONNULL_END
