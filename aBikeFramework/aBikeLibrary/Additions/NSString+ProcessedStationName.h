//
//  NSString+ProcessedStationName.h
//  Velo'v
//
//  Created by Clément Padovani on 1/7/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ProcessedStationName)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *ve_processedStationName;

- (NSString *) ve_sanitizedStationNameWithNumber: (NSNumber *) number;

@end

NS_ASSUME_NONNULL_END
