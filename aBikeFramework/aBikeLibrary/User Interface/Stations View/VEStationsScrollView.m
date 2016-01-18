//
//  VEStationsScrollView.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEStationsScrollView.h"

#import "VEMapViewController.h"

#import "VEStationView.h"

#import "VETimeFormatter.h"

#import "VEAdStationView.h"

#import "CPCoreDataManager.h"

@class Station;

@interface VEStationsScrollView () <UIScrollViewDelegate>

@property (nonatomic, weak) id <VEStationViewDelegate> stationViewDelegate;

@property (nonatomic, copy) NSArray *stationViewsArray;

- (void) setupViews;

- (void) removeDirectionsForStationAtIndex: (NSUInteger) stationIndex;

- (void) numberOfBikeStationsHasChangedNotification: (NSNotification *) notification;

@end

@implementation VEStationsScrollView

- (instancetype) initWithStationDelegate: (id <VEStationViewDelegate>) stationViewDelegate
{
	self = [super init];
	
	if (self)
	{
		_stationViewDelegate = stationViewDelegate;
		
		[self setTranslatesAutoresizingMaskIntoConstraints: NO];

		#if !TARGET_OS_TV
			[self setPagingEnabled: YES];
		#endif
		
		[self setShowsHorizontalScrollIndicator: NO];
		
		[self setShowsVerticalScrollIndicator: NO];
		
		[self setMinimumZoomScale: 1];
		
		[self setMaximumZoomScale: 1];
		
		[self setAccessibilityIdentifier: @"Stations Scroll View"];
		
		[self setupViews];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(numberOfBikeStationsHasChangedNotification:) name: kVETimeFormatterNumberOfBikeStationsHasChangedNotification object: nil];
	}
	
	return self;
}

- (BOOL)canBecomeFocused
{
	return YES;
}

- (void) setupViews
{
	NSUInteger numberOfStations = [VETimeFormatter numberOfBikeStations];
	
	BOOL showAdRemover = [VETimeFormatter includesAdRemover];
	
	NSMutableArray *stationsViewArray = [NSMutableArray arrayWithCapacity: numberOfStations];
	
	VEStationView *previousStation = nil;
	
	for (NSUInteger i = 0; i < numberOfStations; i++)
	{
		BOOL isLast = NO;
		
		if (!showAdRemover)
		{
			isLast = NO;
		}
		else
		{
			if ((i + 1) == numberOfStations)
			{
				isLast = YES;
			}
		}
		
		VEStationView *aStationView;
		
		if (!isLast)
		{
			aStationView = [[VEStationView alloc] init];
		
			[aStationView setDelegate: [self stationViewDelegate]];
		}
		else
		{
			aStationView = (VEStationView *) [VEAdStationView sharedAdStationView];
		}
		
		[self addSubview: aStationView];
		
		[stationsViewArray addObject: aStationView];
		
		NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[aStationView]|"
																 options: 0
																 metrics: nil
																   views: @{@"aStationView" : aStationView}];
		
		[self addConstraints: verticalConstraints];
		
		NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem: aStationView
															  attribute: NSLayoutAttributeWidth
															  relatedBy: NSLayoutRelationEqual
																toItem: self
															  attribute: NSLayoutAttributeWidth
															 multiplier: 1
															   constant: 0];
		
		[self addConstraint: widthConstraint];
		
		NSLayoutConstraint *horizontalConstraint;
		
		if (!previousStation)
		{
			horizontalConstraint = [NSLayoutConstraint constraintWithItem: aStationView
													  attribute: NSLayoutAttributeLeading
													  relatedBy: NSLayoutRelationEqual
														toItem: self
													  attribute: NSLayoutAttributeLeading
													 multiplier: 1
													   constant: 0];
		}
		else if (i != (numberOfStations - 1))
		{
			horizontalConstraint = [NSLayoutConstraint constraintWithItem: aStationView
													  attribute: NSLayoutAttributeLeading
													  relatedBy: NSLayoutRelationEqual
														toItem: previousStation
													  attribute: NSLayoutAttributeTrailing
													 multiplier: 1
													   constant: 0];
		}
		else
		{
			horizontalConstraint = [NSLayoutConstraint constraintWithItem: aStationView
													  attribute: NSLayoutAttributeLeading
													  relatedBy: NSLayoutRelationEqual
														toItem: previousStation
													  attribute: NSLayoutAttributeTrailing
													 multiplier: 1
													   constant: 0];
			
			NSLayoutConstraint *lastHorizontalConstraint = [NSLayoutConstraint constraintWithItem: aStationView
																		 attribute: NSLayoutAttributeTrailing
																		 relatedBy: NSLayoutRelationEqual
																		    toItem: self
																		 attribute: NSLayoutAttributeTrailing
																		multiplier: 1
																		  constant: 0];
			
			[self addConstraint: lastHorizontalConstraint];
		}
		
		
		
		[self addConstraint: horizontalConstraint];
		
		previousStation = aStationView;
	}

	[self setStationViewsArray: [stationsViewArray copy]];
}

//- (void) updateConstraints
//{
//	[self setupConstraints];
//	
//	[super updateConstraints];
//}

- (void) setStations: (NSArray *) stations
{
	[stations enumerateObjectsUsingBlock: ^(Station *aStation, NSUInteger index, BOOL *stop) {
		
		#if !(enableNumberOfStations)
		
		NSUInteger stationViewsCount = [[self stationViewsArray] count];
		
		if (index >= stationViewsCount)
		{
			*stop = YES;
			
			return;
		}
		
		#endif
		
		VEStationView *aStationView = [self stationViewsArray][index];
		
		if ([aStationView isKindOfClass: [VEStationView class]])
			[aStationView setCurrentStation: aStation];
		
	}];
}

- (void) removeDirectionsForStationAtIndex: (NSUInteger) stationIndex
{
	VEStationView *stationView;
	
	if (![self stationViewsArray])
		return;
	
	NSUInteger viewsCount = [[self stationViewsArray] count];
	
	if (stationIndex >= viewsCount)
		return;
	
	@try {
		stationView = (VEStationView *) [self stationViewsArray][stationIndex];
	}
	@catch (NSException *exception) {
		
		return;
		
	}
	
	if ([stationView isKindOfClass: [VEAdStationView class]])
		return;
	
	if (![stationView isShowingDirections])
		return;
	else
		[stationView setShowingDirections: NO];
}

- (void) setCurrentStationIndex: (NSUInteger) currentStationIndex
{
	if (currentStationIndex != [self currentStationIndex])
		[self removeDirectionsForStationAtIndex: [self currentStationIndex]];
	
	_currentStationIndex = currentStationIndex;
}

- (void) numberOfBikeStationsHasChangedNotification: (NSNotification *) notification
{	
	NSMutableArray *copiedStationsViewsArray = [NSMutableArray arrayWithCapacity: [[self stationViewsArray] count]];
	
	[copiedStationsViewsArray addObjectsFromArray: [self stationViewsArray]];
	
	[self setStationViewsArray: nil];
	
	for (VEStationView *aStationView in copiedStationsViewsArray)
	{
		if ([aStationView isKindOfClass: [VEStationView class]])
			[aStationView setDelegate: nil];
		
		[aStationView removeFromSuperview];
	}
	
	[self setupViews];
	
	[self updateConstraints];
	
	[self layoutIfNeeded];
}

- (VEStationView *) stationViewForStation: (Station *) aStation
{
	for (VEStationView *aStationView in [self stationViewsArray])
	{
		if ([aStationView isKindOfClass: [VEStationView class]])
		{
			if ([[aStationView currentStation] isEqual: aStation])
				return aStationView;
		}
	}
	
	return nil;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

+ (BOOL) requiresConstraintBasedLayout
{
	return YES;
}

@end

