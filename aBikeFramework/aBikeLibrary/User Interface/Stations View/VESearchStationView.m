//
//  VESearchStationView.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 2/19/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

#import "VESearchStationView.h"

@interface VESearchStationView ()

@property (nonatomic, assign) BOOL hasSetupConstraints;

@end

@implementation VESearchStationView

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		[self setBackgroundColor: [UIColor clearColor]];
		
		[self setOpaque: NO];
		
		[self setTranslatesAutoresizingMaskIntoConstraints: NO];
		
		[self setupViews];
	}
	
	return self;
}

- (void) setupViews
{
	
}

- (void) setupConstraints
{
	NSDictionary *viewsDictionary = <#views dictionary#>;
	
	NSDictionary *metricsDictionary = nil;
}

- (void) updateConstraints
{
	if (![self hasSetupConstraints])
	{
		[self setupConstraints];
		
		[self setHasSetupConstraints: YES];
	}
	
	[super updateConstraints];
}

+ (BOOL) requiresConstraintBasedLayout
{
	return YES;
}

@end
