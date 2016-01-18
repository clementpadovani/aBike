//
//  CLLocation+Additions.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 7/12/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "CLLocation+Additions.h"

static const CLLocationDistance kVECLLocationCircaDifference = 32;

@implementation CLLocation (Additions)

- (BOOL) ve_isCircaEqual: (CLLocation *) aLocation
{
	if (!aLocation)
		return NO;
	
	CLLocationDistance distance = [self distanceFromLocation: aLocation];
	
	//CPLog(@"distance: %f", distance);
	
	BOOL circaTheSame = distance <= kVECLLocationCircaDifference;
	
	//CPLog(@"circaTheSame: %@", circaTheSame ? @"YES" : @"NO");
	
	return circaTheSame;
}

@end
