//
//  VEStationAnnotationDirectionsAccessoryView.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 9/20/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEStationAnnotationDirectionsAccessoryView.h"

#import "VELocationManager.h"

#import "VEStationView.h"

//static const UIEdgeInsets kContentInsets = {0, 5, 0, 7};

static const UIEdgeInsets kContentInsets = {0, 0, 0, 0};

@interface VEStationAnnotationDirectionsAccessoryView ()

- (void) userInCityRectDidChange: (NSNotification *) notification;

- (void) willLoadDirections: (NSNotification *) notification;

- (void) didLoadDirections: (NSNotification *) notification;

@end

@implementation VEStationAnnotationDirectionsAccessoryView

+ (instancetype) accessoryView
{
	VEStationAnnotationDirectionsAccessoryView *accessoryView = [super accessoryView];
	
	if (accessoryView)
	{
		UIImage *walkingIcon = [UIImage imageNamed: @"walking_icon"
								    inBundle: [NSBundle ve_libraryResources] compatibleWithTraitCollection: nil];

		[accessoryView setImage: [walkingIcon imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate] forState: UIControlStateNormal];
		
		[accessoryView setImage: [walkingIcon imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] forState: UIControlStateSelected];
		
		[accessoryView setContentEdgeInsets: kContentInsets];
		
		[accessoryView sizeToFit];
		
		//[accessoryView setEnabled: [[VELocationManager sharedLocationManager] userIsInCity]];
		
		[accessoryView setEnabled: NO];
		
		[[NSNotificationCenter defaultCenter] addObserver: accessoryView selector: @selector(userInCityRectDidChange:) name: kVELocationManagerUserInCityRectDidChangeNotification object: nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: accessoryView selector: @selector(willLoadDirections:) name: kVEStationViewDidStartLoadingDirectionsNotification object: nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: accessoryView selector: @selector(didLoadDirections:) name: kVEStationViewDidLoadDirectionsNotification object: nil];
	}
	
	return accessoryView;
}

- (void) userInCityRectDidChange: (NSNotification *) notification
{
	if ([[VELocationManager sharedLocationManager] userIsInCity] && [[self stationView] loadedDirections])
	{
		[self setEnabled: YES];
	}
	else
	{
		[self setEnabled: NO];
	}
}

- (void) willLoadDirections: (NSNotification *) notification
{	
	if ([[notification object] isEqual: [self stationView]])
	{
		[self setEnabled: NO];
	}
}

- (void) didLoadDirections: (NSNotification *) notification
{
	if ([[notification object] isEqual: [self stationView]])
	{
		[self setEnabled: YES];
	}
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self name: kVELocationManagerUserInCityRectDidChangeNotification object: nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self name: kVEStationViewDidStartLoadingDirectionsNotification object: nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self name: kVEStationViewDidLoadDirectionsNotification object: nil];
}

@end
