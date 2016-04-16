//
//  NSString+NumberOfLines.m
//  Velo'v
//
//  Created by Clément Padovani on 12/14/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "NSString+NumberOfLines.h"

@implementation NSString (NumberOfLines)

- (NSUInteger) ve_numberOfLines
{
	return [[self componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] count];
}

- (NSString * __nullable) ve_substringAtLine: (NSUInteger) lineNumber
{
	NSString *substring = nil;
	
	NSUInteger numberOfLines = [self ve_numberOfLines];
	
	if ((numberOfLines - 1) < lineNumber)
	{
        [NSException raise: @"Trying to access a line past the number of lines of the string.\nString: %@ number of lines: %lu requested line number: %lu" format: self, (unsigned long) numberOfLines, (unsigned long) lineNumber];

        return nil;
	}
	else
	{
		substring = [self componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]][lineNumber];		
	}
	
	return substring;
}

- (NSRange) ve_rangeOfSubstringAtLine: (NSUInteger) lineNumber
{
	NSRange subStringRange;
	
	NSString *subString = [self ve_substringAtLine: lineNumber];
	
	if (!subString)
		return subStringRange;
	
	subStringRange = [self rangeOfString: subString];
	
	CPLog(@"original substring range: %@", NSStringFromRange(subStringRange));
	
	NSRange testSubstringRange;
	
	testSubstringRange = [subString ve_stringRange];
	
	CPLog(@"test substring range: %@", NSStringFromRange(testSubstringRange));
	
	return subStringRange;
}

- (NSRange) ve_stringRange
{
	return NSMakeRange(0, [self length]);
}

@end
