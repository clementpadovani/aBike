//
//  NSNumber+Extensions.m
//  abike—Lyon
//
//  Created by Clément Padovani on 3/5/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "NSNumber+Extensions.h"

static const NSTimeInterval kNSNumberMillisecondsToSeconds = .001;

@implementation NSNumber (Extensions)

- (CLLocationDegrees) ve_locationDegrees
{
	return [self doubleValue];
}

- (NSTimeInterval) ve_dataContentAgeTimeInterval
{
	return (kNSNumberMillisecondsToSeconds * [self doubleValue]);
}

@end
