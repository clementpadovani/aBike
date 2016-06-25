//
//  VETimerStationView.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 6/25/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

#import "VETimerStationView.h"

@interface VETimerStationView ()

@property (nonatomic, assign) BOOL hasSetupConstraints;

@end

@implementation VETimerStationView

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
