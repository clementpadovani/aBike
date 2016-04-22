//
//  VETimeFormatter.m
//  Velo'v
//
//  Created by Clément Padovani on 11/13/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "VETimeFormatter.h"

#import "CPCoreDataManager.h"

#import "VEConsul.h"

#import "VEMapViewController.h"

#define kNumberOfValidNumbers 3

static MKDistanceFormatter *_sharedFormatter;

static NSUInteger validNumbers[kNumberOfValidNumbers] = { 3, 5, 7 };

NSUInteger currentNumberOfStations = 0;

@interface VETimeFormatter ()

@end

@implementation VETimeFormatter

+ (void) startNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userSettingsHaveChangedNotification:) name: NSUserDefaultsDidChangeNotification object: nil];
}

+ (void) tearDistanceFormatterDown
{
	[[NSNotificationCenter defaultCenter] removeObserver: self name: NSUserDefaultsDidChangeNotification object: nil];
	
	_sharedFormatter = nil;
}

+ (MKDistanceFormatter *) sharedDistanceFormatter
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		_sharedFormatter = [[MKDistanceFormatter alloc] init];
		
		[_sharedFormatter setUnits: [self currentUnitSystem]];
		
		//[_sharedFormatter setUnitStyle: MKDistanceFormatterUnitStyleAbbreviated];
	});
	
	return _sharedFormatter;
}

+ (MKDistanceFormatterUnits) currentUnitSystem
{	
	NSString *unit = [[NSUserDefaults standardUserDefaults] stringForKey: kUnitSystemKey];
	
	return [self distanceFormatterUnitForUnitSystem: unit];
}

+ (MKDistanceFormatterUnits) distanceFormatterUnitForUnitSystem: (NSString *) unitSystem
{
	if ([unitSystem isEqualToString: @"default"])
		return MKDistanceFormatterUnitsDefault;
	else if ([unitSystem isEqualToString: @"metric"])
		return MKDistanceFormatterUnitsMetric;
	else if ([unitSystem isEqualToString: @"imperial"])
		return MKDistanceFormatterUnitsImperial;
	else
		return MKDistanceFormatterUnitsDefault;
}

+ (NSDateComponentsFormatter *) sharedTimeFormatter
{
	static NSDateComponentsFormatter *_sharedFormatter = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedFormatter = [[NSDateComponentsFormatter alloc] init];
		
		[_sharedFormatter setUnitsStyle: NSDateComponentsFormatterUnitsStyleFull];
		
		[_sharedFormatter setAllowedUnits: NSCalendarUnitHour | NSCalendarUnitMinute];
	});
	
	return _sharedFormatter;
}

+ (NSString *) formattedStringForDuration: (NSTimeInterval) duration
{
	NSTimeInterval goodTimeInterval = (duration / 60.);
	
	goodTimeInterval = ceil(goodTimeInterval);
	
    goodTimeInterval *= 60.;
		
    return [self ios8_formattedStringForDuration: goodTimeInterval];
}

+ (NSString *) ios8_formattedStringForDuration: (NSTimeInterval) duration
{
	NSString *formattedString = [[self sharedTimeFormatter] stringFromTimeInterval: duration];
	
	return formattedString;
}

+ (NSString *) formattedStringForETA: (NSTimeInterval) eta
{
	return [self formattedStringForDuration: eta];
}

+ (void) userSettingsHaveChangedNotification: (NSNotification *) notification
{
	//CPLog(@"settings changed: %@", notification);
	
	if ([self currentUnitSystem] != [_sharedFormatter units])
	{
		[_sharedFormatter setUnits: [self currentUnitSystem]];
		
		[[NSNotificationCenter defaultCenter] postNotificationName: kVETimeFormatterUnitsChangedNotification object: nil];
		
		//CPLog(@"units not the same");
	}
	else
	{
		//CPLog(@"same units");
	}
}

+ (NSUInteger) numberOfBikeStations
{
	if (!currentNumberOfStations)
	{
		//CPLog(@"currentNumberOfStations: %lu", currentNumberOfStations);
		
		currentNumberOfStations = [self sanitizedNumberOfBikeStations];
		
		return currentNumberOfStations;
		
		//CPLog(@"currentNumberOfStations: %lu", currentNumberOfStations);
	}
	else
	{
		//CPLog(@"else");
		
		//CPLog(@"currentNumberOfStations: %lu", currentNumberOfStations);
		
		//CPLog(@"sanitiszed: %lu", [self sanitizedNumberOfBikeStations]);
		
		//NSAssert(currentNumberOfStations == [self sanitizedNumberOfBikeStations], @"Not equal.");
		
		//CPLog(@"currentNumberOfStations: %lu", currentNumberOfStations);
		
		return currentNumberOfStations;
	}
	
	return currentNumberOfStations;
}

+ (NSUInteger) sanitizedNumberOfBikeStations
{	
	NSUInteger currentNumber = [[[NSUserDefaults standardUserDefaults] objectForKey: kNumberOfBikeStations] unsignedIntegerValue];
	
	BOOL isValid = NO;
	
	for (NSUInteger i = 0; i < kNumberOfValidNumbers; i++)
	{
		if (currentNumber == validNumbers[i])
		{
			isValid = YES;
			
			//CPLog(@"VALID current number is equal: %lu i: %lu", currentNumber, i);
			break;
		}
	}
	
	if (isValid)
	{
		return currentNumber;
	}
	else
	{
		CPLog(@"invalid");
		
		[[NSUserDefaults standardUserDefaults] setObject: @((NSUInteger) kNumberOfBikeStationsDefault) forKey: kNumberOfBikeStations];
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		return kNumberOfBikeStationsDefault;
	}
}

//+ (NSString *) formattedDurationForLastUpdate: (NSDate *) lastUpdate
//{
//	NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate: lastUpdate];
//	
//	NSTimeInterval goodTimeInterval = (duration / 60);
//	
//	goodTimeInterval = ceil(goodTimeInterval);
//	
//	NSString *formattedDurationString;
//	
//	if (goodTimeInterval > 1)
//		formattedDurationString = [NSString stringWithFormat: NSLocalizedString(@"%.0f minutes ago", @"VETimeFormatter_LastUpdate_FormattedDurationPlurialMinutes"), goodTimeInterval];
//	else
//		formattedDurationString = [NSString stringWithFormat: NSLocalizedString(@"%.0f minute ago", @"VETimeFormatter_LastUpdate_FormattedDurationSingularMinute"), goodTimeInterval];
//	
//	return formattedDurationString;
//}

@end
