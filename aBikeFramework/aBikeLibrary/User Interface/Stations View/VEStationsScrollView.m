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

#import "CPCoreDataManager.h"

#import "VESearchStationView.h"

@class Station;

@interface VEStationsScrollView () <UIScrollViewDelegate>

@property (nonatomic, weak) id <VEStationViewDelegate> stationViewDelegate;

@property (nonatomic, copy) NSArray *stationViewsArray;

@property (nonatomic, assign, getter = isSearching) BOOL searching;

@property (nonatomic, assign, readwrite) NSUInteger adStationIndex;

@property (nonatomic, assign, readwrite) NSUInteger searchStationIndex;

- (void) removeDirectionsForStationAtIndex: (NSUInteger) stationIndex;

- (void) numberOfBikeStationsHasChangedNotification: (NSNotification *) notification;

@end

@implementation VEStationsScrollView

- (instancetype) initWithStationDelegate: (id <VEStationViewDelegate>) stationViewDelegate isSearching: (BOOL) searching
{
	self = [super init];
	
	if (self)
	{
		_searching = searching;

		_stationViewDelegate = stationViewDelegate;

		_adStationIndex = NSNotFound;

		_searchStationIndex = NSNotFound;
		
		[self setTranslatesAutoresizingMaskIntoConstraints: NO];

		#if !TARGET_OS_TV
			[self setPagingEnabled: YES];
		#endif
		
		[self setShowsHorizontalScrollIndicator: NO];
		
		[self setShowsVerticalScrollIndicator: NO];
		
		[self setMinimumZoomScale: 1];
		
		[self setMaximumZoomScale: 1];
		
		[self setAccessibilityIdentifier: @"Stations Scroll View"];
		
		[self setupViewsForSearch: searching];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(numberOfBikeStationsHasChangedNotification:) name: kVETimeFormatterNumberOfBikeStationsHasChangedNotification object: nil];
	}
	
	return self;
}

- (void) setupViewsForSearch: (BOOL) searching
{
	NSUInteger numberOfStations = [VETimeFormatter numberOfBikeStations];
	
//	if (searching)
//	{
//		numberOfStations--;
//
//		if (showAdRemover)
//		{
//			numberOfStations--;
//
//			showAdRemover = NO;
//		}
//	}

//	if (showAdRemover)
//	{
//		numberOfStations--;
//
//		showAdRemover = NO;
//	}

	NSMutableArray *stationsViewArray = [NSMutableArray arrayWithCapacity: numberOfStations];
	
	VEStationView *previousStation = nil;
	
	for (NSUInteger i = 0; i < numberOfStations; i++)
	{
		BOOL isLast = NO;

		BOOL isSearch = NO;
		
//		if (!showAdRemover)
//		{
//			isLast = NO;
//
//			if (i == numberOfStations - 2)
//			{
//				isSearch = YES;
//			}
//		}
//		else
//		{
//			if (i == numberOfStations - 2)
//			{
//				isSearch = YES;
//			}
//			else if ((i + 1) == numberOfStations)
//			{
//				isLast = YES;
//			}
//		}

//		if (searching)
//		{
//			isSearch = NO;
//		}

//			if ((i + 1) == numberOfStations)
//			{
//				isLast = YES;
//			}

		VEStationView *aStationView;
		
		if (!isLast)
		{
			if (isSearch)
			{
				aStationView = (VEStationView *) [[VESearchStationView alloc] init];

				[self setSearchStationIndex: i];
			}
			else
			{
				aStationView = [[VEStationView alloc] init];
		
				[aStationView setDelegate: [self stationViewDelegate]];

				[aStationView setDirectionsEnabled: ![self isSearching]];
			}
			
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
	@catch (NSException * __unused exception) {
		
		return;
		
	}
	
	if ([stationView isKindOfClass: [VEStationView class]])
	{
	
	if (![stationView isShowingDirections])
		return;
	else
		[stationView setShowingDirections: NO];
	}
	else if ([stationView isKindOfClass: [VESearchStationView class]])
	{
		[(VESearchStationView *) stationView setVisible: NO];
	}
}

- (VEStationView  * __nullable) stationViewAtIndex: (NSUInteger) stationIndex
{
	VEStationView *stationView = nil;

	NSUInteger viewsCount = [[self stationViewsArray] count];

	if (stationIndex >= viewsCount)
		return nil;

	@try {
		stationView = (VEStationView *) [self stationViewsArray][stationIndex];
	}
	@catch (NSException * __unused exception) {

		return nil;

	}

	return stationView;
}

- (void) setCurrentStationIndex: (NSUInteger) currentStationIndex
{
	if (currentStationIndex != [self currentStationIndex])
	{
		[self removeDirectionsForStationAtIndex: [self currentStationIndex]];
	}

	VEStationView *newStationView = [self stationViewAtIndex: currentStationIndex];

	if ([newStationView isKindOfClass: [VESearchStationView class]])
	{
		[(VESearchStationView *) newStationView setVisible: YES];
	}

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
	
	[self setupViewsForSearch: [self isSearching]];
	
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

@end

