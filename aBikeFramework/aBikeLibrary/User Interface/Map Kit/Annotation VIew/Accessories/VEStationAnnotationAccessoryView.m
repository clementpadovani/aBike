//
//  VEStationAnnotationAccessoryView.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 9/19/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEStationAnnotationAccessoryView.h"

@implementation VEStationAnnotationAccessoryView

+ (instancetype) accessoryView
{
	VEStationAnnotationAccessoryView *accessoryView = [self buttonWithType: UIButtonTypeCustom];
	
	[accessoryView setContentHorizontalAlignment: UIControlContentHorizontalAlignmentCenter];
	
	[accessoryView setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
	
	return accessoryView;
}

@end
