//
//  NSString+ProcessedStationName.m
//  Velo'v
//
//  Created by Clément Padovani on 1/7/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "NSString+ProcessedStationName.h"

#import "NSString+NumberOfLines.h"

@implementation NSString (ProcessedStationName)

- (NSString *) ve_processedStationName
{
	return [self capitalizedStringWithLocale: [NSLocale currentLocale]];
}

- (NSString *) ve_sanitizedStationNameWithNumber: (NSNumber *) number
{
	__block NSUInteger index = NSNotFound;
	
	[self enumerateSubstringsInRange: [self ve_stringRange]
						options: NSStringEnumerationByWords
					  usingBlock: ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
						  
						  if ([number compare: @([substring integerValue])] == NSOrderedSame)
						  {
							  return;
						  }
						  
						  index = substringRange.location;
						  
						  *stop = YES;
						  
					  }];
	
	return [self substringFromIndex: index];
}

@end
