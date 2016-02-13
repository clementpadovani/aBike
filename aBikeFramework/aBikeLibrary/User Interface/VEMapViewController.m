//
//  VEMapViewController.m
//  Velo'v
//
//  Created by Clément Padovani on 7/17/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "VEMapViewController.h"

#import "VEConsul.h"

#import "VEStationAnnotationView.h"

#import "UIColor+MainColor.h"

#import "VEAlertManager.h"

#import "VEStationsView.h"

#import "VEStationView.h"

#import "VERouteRenderer.h"

#import "CLLocation+Additions.h"

#import "VETimeFormatter.h"

#import "VEAdStationView.h"

#import "VEStationAnnotationDirectionsAccessoryView.h"

#import "VEStationAnnotationShareAccessoryView.h"

#if !TARGET_OS_TV
@import iAd;
#endif

@import StoreKit;

static NSString * const kVEMapViewControllerStationAnnotationViewReuseIdentifier = @"kVEMapViewControllerStationAnnotationViewReuseIdentifier";

static const NSUInteger kVEMapViewControllerMemoryStoreBatchSize = 50;

//static const CGFloat kVEMapViewControllerDirectionsLineWidth = 5;

static const UIEdgeInsets kVEMapViewControllerMapViewOverlayPortraitInsets = { 30 + 25, 25, 152.5 + 25, 25 };

//static const UIEdgeInsets kVEMapViewControllerMapViewOverlayLandscapeInsets = { 30, 25, 152.5, 25 };

typedef NS_ENUM(NSUInteger, VEMapViewControllerMapAction) {
	VEMapViewControllerMapActionShowAnnotations,
	VEMapViewControllerMapActionShowOverlay
};

@interface VEMapViewController () <VEStationsViewDelegate, VEStationViewDelegate>

@property (weak, nonatomic) VEMapContainerView *mapContainerView;

@property (weak, nonatomic) VEStationsView *stationsView;

@property (copy, nonatomic) NSArray *stations;

@property (weak, nonatomic) Station *currentStation;

@property (weak, nonatomic) Station *directionsStation;

@property (strong, nonatomic) MKDirections *directions;

@property (strong, nonatomic) MKRoute *directionsRoute;

@property (nonatomic, getter = isShowingDirections) BOOL showingDirections;

@property (nonatomic, getter = isFullyLoaded) BOOL fullyLoaded;

@property (nonatomic) BOOL canShowUserLocationInCohort;

@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, strong) MKMapSnapshotter *mapSnapshotter;

@property (nonatomic, copy) NSArray *currentConstraints;

- (void) setupUserSettings;

- (void) setupMemoryStore;

- (void) sortStationsByClosestToUserLocation: (CLLocation *) location;

- (void) userHasMovedToNewLocation: (CLLocation *) newLocation forceDisableUpdateStations: (BOOL) disableStationUpdate;

- (void) performMapViewAction: (VEMapViewControllerMapAction) mapAction;

- (void) showAnnotations;

@end

@implementation VEMapViewController

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		//[self setupUserSettings];
	}
	
	return self;
}

#if TARGET_OS_TV

- (UIView *) originalContentView
{
	return [self view];
}

#endif

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	//[self setAutomaticallyAdjustsScrollViewInsets: NO];
	
	[self setCanDisplayBannerAds: YES];
	
	[self setCanShowUserLocationInCohort: YES];
	
	[self setupUserSettings];
	
	VEMapContainerView *mapContainerView = [[VEMapContainerView alloc] initWithMapViewDelegate: self];
	
	VEStationsView *stationsView = [[VEStationsView alloc] initWithStationDelegate: self];
	
	[stationsView setDelegate: self];
		
	[[self originalContentView] addSubview: mapContainerView];
	
	[[self originalContentView] addSubview: stationsView];
	
	[[self originalContentView] setBackgroundColor: [UIColor ve_mapViewControllerBackgroundColor]];
	
	[[self originalContentView] setOpaque: YES];
	
	[self setMapContainerView: mapContainerView];
	
	[self setStationsView: stationsView];
	
	[self setupConstraints];
}

- (void) viewDidAppear: (BOOL) animated
{
	[super viewDidAppear: animated];
	
	//CPLog(@"view did appear");
	
	MKCoordinateRegion region = [[VEConsul sharedConsul] initialMapRegion];
	
	[[[self mapContainerView] mapView] setRegion: region];
}

//- (BOOL) shouldAutorotate
//{
//	return YES;
//}
//
//- (NSUInteger) supportedInterfaceOrientations
//{
//	return UIInterfaceOrientationMaskAll;
//}
//
//- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
//{
//	CPLog(@"did rotate");
//	
//	if ([self stations])
//		[self performMapViewAction: [self isShowingDirections] ? VEMapViewControllerMapActionShowOverlay : VEMapViewControllerMapActionShowAnnotations];
//	
//	[super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
//}

- (void) viewDidLayoutSubviews
{
	if ([self stations])
		[self performMapViewAction: [self isShowingDirections] ? VEMapViewControllerMapActionShowOverlay : VEMapViewControllerMapActionShowAnnotations];

	#if TARGET_OS_TV

	[super viewDidLayoutSubviews];

	return;

	#endif

	NSArray *subviews = [[[self mapContainerView] mapView] subviews];
	
	//CPLog(@"subviews: %@", subviews);
	
	CGRect stationsFrame = [[self stationsView] frame];
	
	//CPLog(@"stationsFrame: %@", NSStringFromCGRect(stationsFrame));
	
	CGRect currentFrame = CGRectZero;
	
	CGRect newFrame = CGRectZero;
	
	BOOL abort = YES;
	
	for (UIView *aView in subviews)
	{
		if ([NSStringFromClass([aView class]) isEqualToString: @"MKAttributionLabel"])
		{
			currentFrame = [aView frame];
			
			abort = NO;
		}
	}
	
	newFrame = currentFrame;
	
	if (abort)
		CPLog(@"abort");
	
	if (abort)
	{
		[super viewDidLayoutSubviews];
		
		return;
	}
	
	newFrame.origin.y = stationsFrame.origin.y;
	
	newFrame.origin.y -= newFrame.size.height;
	
	newFrame.origin.y -= 9;
	
	if (CGRectEqualToRect(currentFrame, newFrame))
	{
		//CPLog(@"rects equal");
		
		[super viewDidLayoutSubviews];
		
		return;
	}
	
	for (UIView *aView in subviews)
	{
		if ([NSStringFromClass([aView class]) isEqualToString: @"MKAttributionLabel"])
		{
			[aView setFrame: newFrame];
			
			break;
		}
	}
	
	[super viewDidLayoutSubviews];
}

- (void) loadMapData
{
	[[VEConsul sharedConsul] startLoadingSpinner];
	
	[self setupMemoryStore];
	
	[[VELocationManager sharedLocationManager] setDelegate: self];
	
	[[VEConsul sharedConsul] stopLoadingSpinner];
	
	[self setFullyLoaded: YES];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(numberOfBikeStationsHasChangedNotification:) name: kVETimeFormatterNumberOfBikeStationsHasChangedNotification object: nil];
	
//	if ([VETimeFormatter includesAdRemover])
//		[[VEAdStationView sharedAdStationView] canLoad];
}

- (void) updateAds
{
	[self setupUserSettings];
}

- (void) setupUserSettings
{
	[self setCanDisplayBannerAds: YES];
	
	__weak VEMapViewController *weakSelf = self;
	
	[[[CPCoreDataManager sharedCoreDataManager] userContext] performBlock: ^{
		
		__strong VEMapViewController *strongSelf = weakSelf;
		
		if (!strongSelf)
			CPLog(@"nil strong self");
		
		BOOL canShowAds = [[UserSettings sharedSettings] canShowAds];
		
		CPLog(@"can show ads: %@", canShowAds ? @"YES" : @"NO");
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[strongSelf setCanDisplayBannerAds: canShowAds];
			
			#if kEnableCrashlytics
			
				NSDictionary *attributes = @{@"Can Show Ads" : canShowAds ? @"YES" : @"NO"};
			
				[Answers logCustomEventWithName: @"Can Show Ads"
							customAttributes: attributes];
			
			#endif
			
		});
		
	}];

	//CPLog(@"can show ads: %@", canShowAds ? @"YES" : @"NO");

	//[self setCanDisplayBannerAds: canShowAds];
	
	
}

- (void) setCanDisplayBannerAds:(BOOL)canDisplayBannerAds
{
	if (![NSThread isMainThread])
		NSAssert(NO, @"Not main thread");
	
	//CPLog(@"can show ads: %@", canDisplayBannerAds ? @"YES" : @"NO");

	#if !TARGET_OS_TV
	[super setCanDisplayBannerAds: canDisplayBannerAds];
	#endif
}

- (void) setupMemoryStore
{
	if (![NSThread isMainThread])
		CPLog(@"NOT MAIN THREAD");
	
	NSArray *stationPropertiesToFetchArray = @[kLightStationNumber, kLightStationLocation];
	
	NSFetchRequest *stationsFetchRequest = [NSFetchRequest fetchRequestWithEntityName: @"Station"];

	NSPredicate *openPredicate = [NSPredicate predicateWithFormat: @"%K == YES", kStationOpenKey];
	
	[stationsFetchRequest setPredicate: openPredicate];
	
	[stationsFetchRequest setFetchBatchSize: kVEMapViewControllerMemoryStoreBatchSize];
	
	[stationsFetchRequest setPropertiesToFetch: stationPropertiesToFetchArray];
	
	[stationsFetchRequest setResultType: NSDictionaryResultType];
	
	/*__block */NSArray *fetchResults;
	
	/*__block */NSError *fetchError;
	
	VEManagedObjectContext *standardContext = [[CPCoreDataManager sharedCoreDataManager] standardContext];
	
	VEManagedObjectContext *temporaryContext = [[CPCoreDataManager sharedCoreDataManager] memoryContext];
	
	//[standardContext performBlockAndWait: ^{
		
		fetchResults = [standardContext executeFetchRequest: stationsFetchRequest error: &fetchError];
		
	//}];

	#if kEnableCrashlytics

		if (fetchError)
			[[Crashlytics sharedInstance] recordError: fetchError];

	#endif


	NSAssert(!fetchError, @"Error while fetching on-disk stations: %@", fetchError);
	
	[temporaryContext performBlockAndWait: ^{
	
		for (NSDictionary *aStationDictionary in fetchResults)
		{
			@autoreleasepool
			{
				[LightStation lightStationFromStationDictionary: aStationDictionary inContext: temporaryContext];
			}
		}
		
	}];
}

#pragma mark -

- (void) numberOfBikeStationsHasChangedNotification: (NSNotification *) notification
{
	//[[VELocationManager sharedLocationManager] forceLocationUpdate];
	
	if (![[VELocationManager sharedLocationManager] currentLocation])
		return;
	
	[self userHasMovedToNewLocation: [[VELocationManager sharedLocationManager] currentLocation] withForce: YES];
}

//- (void) traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
//{
//	[super traitCollectionDidChange: previousTraitCollection];
//
//	if ([self currentConstraints])
//		[[self originalContentView] removeConstraints: [self currentConstraints]];
//
//	[[self originalContentView] traitCollectionDidChange: previousTraitCollection];
//
//	[self setupConstraintsWithTraitCollection: [self traitCollection]];
//
//	[[self originalContentView] layoutIfNeeded];
//}

- (void) setupConstraints
{	
	NSDictionary *viewsDictionary = @{@"_mapContainerView" : [self mapContainerView],
							    @"_stationsView" : [self stationsView]};
	
	NSDictionary *metricsDictionary = nil;

		NSMutableArray *newConstraints = [@[] mutableCopy];

	NSArray *mapViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[_mapContainerView]|"
																	options: 0
																	metrics: metricsDictionary
																	  views: viewsDictionary];
	

		[newConstraints addObjectsFromArray: mapViewHorizontalConstraints];

	NSArray *mapViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[_mapContainerView]|"
																   options: 0
																   metrics: metricsDictionary
																	views: viewsDictionary];
	
	[newConstraints addObjectsFromArray: mapViewVerticalConstraints];
	
	NSArray *stationViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[_stationsView]|"
																	    options: 0
																	    metrics: metricsDictionary
																		 views: viewsDictionary];
	
	[newConstraints addObjectsFromArray: stationViewHorizontalConstraints];
	
	NSArray *stationViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[_stationsView(152.5)]|"
																	  options: 0
																	  metrics: metricsDictionary
																	    views: viewsDictionary];
	
	[newConstraints addObjectsFromArray: stationViewVerticalConstraints];

	[[self originalContentView] addConstraints: newConstraints];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

//- (MKPolyline *) processedPolylineForRoute: (MKRoute *) route withOrigin: (CLLocationCoordinate2D) origin
//{
//	MKPolyline *polyline;
//
//	MKPolyline *routePolyline = [route polyline];
//	
//	NSUInteger pointCount = [routePolyline pointCount];
//
//	CLLocationCoordinate2D coords[pointCount];
//	
//	[routePolyline getCoordinates: coords range: NSMakeRange(0, pointCount)];
//
//	CPLog(@"old coords");
//	
//	for (NSUInteger i = 0; i < pointCount; i++)
//		CPLog(@"%lu: %f:%f", i, coords[i].latitude, coords[i].longitude);
//	
//	CLLocationCoordinate2D newCoords[pointCount + 1];
//	
//	newCoords[0] = origin;
//	
//	for (NSUInteger i = 1; i <= pointCount; i++)
//	{
//		newCoords[i] = coords[i - 1];
//	}
//	
//	CPLog(@"new coords");
//	
//	for (NSUInteger i = 0; i < pointCount + 1; i++)
//		CPLog(@"%lu: %f:%f", i, newCoords[i].latitude, newCoords[i].longitude);
//
//	
//	polyline = [MKPolyline polylineWithCoordinates: newCoords count: pointCount + 1];
//	
//	return polyline;
//}

- (void) loadDirectionsInfoWithRoute: (MKRoute *) directionsRoute forStation: (Station *) aStation
{	
	MKMapView *mapView = [[self mapContainerView] mapView];
	
	if (directionsRoute)
	{
		[self setDirectionsRoute: directionsRoute];
		
//		CLLocationCoordinate2D coords = [[[VELocationManager sharedLocationManager] currentLocation] coordinate];
//		
//		MKPolyline *polyline = [self processedPolylineForRoute: directionsRoute withOrigin: coords];
//		
//		[mapView addOverlay: polyline level: MKOverlayLevelAboveRoads];
		
		[mapView addOverlay: [directionsRoute polyline] level: MKOverlayLevelAboveRoads];
		
		[self setShowingDirections: YES];
		
		[self performMapViewAction: VEMapViewControllerMapActionShowOverlay];
		
		VEStationAnnotationView *annotationView = (VEStationAnnotationView *) [[[self mapContainerView] mapView] viewForAnnotation: aStation];
		
		[[annotationView directionsAccessoryView] setSelected: YES];
	}
	else
	{		
		[mapView removeOverlay: [[self directionsRoute] polyline]];
		
		[self setDirectionsRoute: nil];
		
		[self performMapViewAction: VEMapViewControllerMapActionShowAnnotations];
		
		[self setShowingDirections: NO];
		
		VEStationAnnotationView *annotationView = (VEStationAnnotationView *) [[[self mapContainerView] mapView] viewForAnnotation: aStation];
		
		[[annotationView directionsAccessoryView] setSelected: NO];
	}
}

- (void) performMapViewAction: (VEMapViewControllerMapAction) mapAction
{
	//MKMapView *mapView = [[self mapContainerView] mapView];
	
	switch (mapAction)
	{
		case VEMapViewControllerMapActionShowAnnotations:
		{
			[self showAnnotations];
			
			//[mapView showAnnotations: [mapView annotations] animated: YES];
			
			break;
		}
		case VEMapViewControllerMapActionShowOverlay:
		{
			
			[self showDirections];
			
//			MKMapRect overlayMapRect = [[[self directionsRoute] polyline] boundingMapRect];
//			
//			MKMapPoint userLocationPoint = MKMapPointForCoordinate([[mapView userLocation] coordinate]);
//			
//			MKMapSize userLocationSize = MKMapSizeMake(1, 1);
//			
//			MKMapRect userLocationRect;
//			
//			userLocationRect.origin = userLocationPoint;
//			
//			userLocationRect.size = userLocationSize;
//			
//			MKMapRect finalRect = MKMapRectUnion(overlayMapRect, userLocationRect);
//			
//			UIEdgeInsets mapInsets = kVEMapViewControllerMapViewOverlayPortraitInsets;
//			
//			//BOOL isLandscape = UIInterfaceOrientationIsLandscape([self interfaceOrientation]);
//			
//			//mapInsets = isLandscape ? kVEMapViewControllerMapViewOverlayLandscapeInsets : kVEMapViewControllerMapViewOverlayPortraitInsets;
//			
//			finalRect = [mapView mapRectThatFits: finalRect edgePadding: mapInsets];
//			
//			[mapView setVisibleMapRect: finalRect animated: YES];
			
			break;
		}
			
			
	}
}

- (MKMapRect) mapRectForAnnotations
{
	MKMapView *mapView = [[self mapContainerView] mapView];
	
	NSArray *mapViewAnnotations = [mapView annotations];
	
	//CPLog(@"annotations: %@", mapViewAnnotations);
	
	if (![self canShowUserLocationInCohort])
	{
		MKUserLocation *userLocation = [mapView userLocation];
		
		NSMutableArray *tempArray = [NSMutableArray arrayWithArray: mapViewAnnotations];
		
		//CPLog(@"temp array: %@", tempArray);
		
		[tempArray removeObject: userLocation];
		
		//CPLog(@"temp array: %@", tempArray);
		
		mapViewAnnotations = [tempArray copy];
	}
	
	MKMapRect zoomRect = MKMapRectNull;
	
	for (id <MKAnnotation> annotation in mapViewAnnotations)
	{
		MKMapPoint annotationPoint = MKMapPointForCoordinate([annotation coordinate]);
		
		MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
		
		if (MKMapRectIsNull(zoomRect))
		{
			zoomRect = pointRect;
		}
		else
		{
			zoomRect = MKMapRectUnion(zoomRect, pointRect);
		}
	}
	
	//[mapView setVisibleMapRect: zoomRect edgePadding: kVEMapViewControllerMapViewOverlayInsets animated: YES];
	
#if !(enableNumberOfStations)
	
	MKCoordinateRegion region = MKCoordinateRegionForMapRect(zoomRect);
	
	CPLog(@"region: center: %f:%f", region.center.latitude, region.center.longitude);
	
	CPLog(@"span: %f:%f", region.span.latitudeDelta, region.span.latitudeDelta);
	
#endif
	
	UIEdgeInsets mapInsets = kVEMapViewControllerMapViewOverlayPortraitInsets;
	
	//BOOL isLandscape = UIInterfaceOrientationIsLandscape([self interfaceOrientation]);
	
	//mapInsets = isLandscape ? kVEMapViewControllerMapViewOverlayLandscapeInsets : kVEMapViewControllerMapViewOverlayPortraitInsets;
	
	zoomRect = [mapView mapRectThatFits: zoomRect edgePadding: mapInsets];

	return zoomRect;
}

- (MKMapRect) mapRectForDirections
{
	MKMapView *mapView = [[self mapContainerView] mapView];
	
	MKMapRect overlayMapRect = [[[self directionsRoute] polyline] boundingMapRect];
	
	MKMapPoint userLocationPoint = MKMapPointForCoordinate([[mapView userLocation] coordinate]);
	
	MKMapSize userLocationSize = MKMapSizeMake(1, 1);
	
	MKMapRect userLocationRect;
	
	userLocationRect.origin = userLocationPoint;
	
	userLocationRect.size = userLocationSize;
	
	MKMapRect finalRect = MKMapRectUnion(overlayMapRect, userLocationRect);
	
	UIEdgeInsets mapInsets = kVEMapViewControllerMapViewOverlayPortraitInsets;
	
	//BOOL isLandscape = UIInterfaceOrientationIsLandscape([self interfaceOrientation]);
	
	//mapInsets = isLandscape ? kVEMapViewControllerMapViewOverlayLandscapeInsets : kVEMapViewControllerMapViewOverlayPortraitInsets;
	
	finalRect = [mapView mapRectThatFits: finalRect edgePadding: mapInsets];
	
	//[mapView setVisibleMapRect: finalRect animated: YES];
	
	return finalRect;
}

- (void) showAnnotations
{
	if (![NSThread isMainThread])
		CPLog(@"NOT MAIN THREAD");
	
	MKMapRect zoomRect = [self mapRectForAnnotations];
	
	BOOL animateMapChange = [[VEConsul sharedConsul] isInBackground] ? NO : YES;
	
	//CPLog(@"animateMapChange: %@", animateMapChange ? @"YES" : @"NO");
	
	[[[self mapContainerView] mapView] setVisibleMapRect: zoomRect animated: animateMapChange];
}

- (void) showDirections
{
	if (![NSThread isMainThread])
		CPLog(@"not main thread");
	
	MKMapRect mapRect = [self mapRectForDirections];
	
	BOOL animateMapChange = [[VEConsul sharedConsul] isInBackground] ? NO : YES;
	
	[[[self mapContainerView] mapView] setVisibleMapRect: mapRect animated: animateMapChange];
}

- (void) userDidScrollToNewStationForIndex: (NSUInteger) index
{
	Station *oldStation = [self currentStation];
	
	MKMapView *mapView = [[self mapContainerView] mapView];
	
	if (index == [[self stations] count])
	{
		//CPLog(@"station is ad view");
		
		VEStationAnnotationView *oldAnnotationView = (VEStationAnnotationView *) [mapView viewForAnnotation: oldStation];
		
		[oldAnnotationView setTableViewSelected: NO animated: YES];
		
		[mapView deselectAnnotation: oldStation animated: YES];
		
		[self setCurrentStation: nil];
		
		[[VEAdStationView sharedAdStationView] canLoad];
		
		return;
	}
	
	Station *newStation = [self stations][index];
	
	if ([newStation isEqual: [self currentStation]])
		return;
	
	VEStationAnnotationView *oldAnnotationView = (VEStationAnnotationView *) [mapView viewForAnnotation: oldStation];

	[oldAnnotationView setTableViewSelected: NO animated: YES];
	
	[mapView deselectAnnotation: oldStation animated: YES];
	
	VEStationAnnotationView *annotationView = (VEStationAnnotationView *) [mapView viewForAnnotation: newStation];
	
	[annotationView setTableViewSelected: YES animated: YES];
	
	[self setCurrentStation: newStation];
}

#pragma mark VELocationManager Delegate methods

//- (void) locationDebuggingHasStarted
//{
//	[[self mapContainerView] reloadLocationDebuggingColor];
//}
//
//- (void) locationDebuggingHasEnded
//{
//	[[self mapContainerView] reloadLocationDebuggingColor];
//}

- (void) locationUpdatesHaveResumed
{
	CPLog(@"resume");
}

- (void) locationUpdatesHavePaused
{
	CPLog(@"pause");
}

- (void) didEnterBackground
{
	//CPLog(@"background");
	
	[[NSNotificationCenter defaultCenter] postNotificationName: kVEMapViewControllerViewGoToBackgroundNotification object: nil];
}

- (void) willReturnToForeground
{
	//CPLog(@"foreground");
}

- (void) userHasMovedToNewLocation: (CLLocation *) newLocation forceDisableUpdateStations: (BOOL) disableStationUpdate
{
	if ([self stations])
	{
		//VEManagedObjectContext *standardContext = [[CPCoreDataManager sharedCoreDataManager] standardContext];
		
		//[standardContext performBlockAndWait: ^{
			
		for (Station *aStation in [self stations])
		{
			[aStation fetchContentWithUserForceReload: NO];
		}
		
		[[[self mapContainerView] mapView] addAnnotations: [self stations]];
		
		//CPLog(@"added: %@", [self stations]);
		
		[self performMapViewAction: VEMapViewControllerMapActionShowAnnotations];
	}
}

- (void) sortStationsByClosestToUserLocation: (CLLocation *) location
{
	VEManagedObjectContext *standardContext = [[CPCoreDataManager sharedCoreDataManager] standardContext];
	
	//[standardContext performBlockAndWait: ^{
	
	[[[self mapContainerView] mapView] removeAnnotations: [self stations]];
	
	[[[self mapContainerView] mapView] removeOverlay: [[self directionsRoute] polyline]];
	
	if ([[self directions] isCalculating])
		[[self directions] cancel];
	
	[self setDirections: nil];
	
	[self setDirectionsRoute: nil];
	
	//[[[self mapContainerView] mapView] removeAnnotations: [[[self mapContainerView] mapView] annotations]];
	
	[self setStations: nil];
			
	//}];
	
	[[VEConsul sharedConsul] saveContext];
	
	NSUInteger numberOfStations = [VETimeFormatter numberOfBikeStations];
	
	if ([VETimeFormatter includesAdRemover])
		numberOfStations -= 1;
	
	NSFetchRequest *sortFetchRequest = [NSFetchRequest fetchRequestWithEntityName: [LightStation entityName]];
	
	#if enableNumberOfStations
		
		[sortFetchRequest setFetchLimit: numberOfStations];
	
	#endif
	
	NSSortDescriptor *lightSortDescriptor = [NSSortDescriptor sortDescriptorWithKey: NSStringFromSelector(@selector(location))
															ascending: YES
														    comparator: ^NSComparisonResult(CLLocation *aStation, CLLocation *anotherStation) {
															    
															    if ([location distanceFromLocation: aStation] > [location distanceFromLocation: anotherStation])
																    return NSOrderedDescending;
															    
															    if ([location distanceFromLocation: aStation] < [location distanceFromLocation: anotherStation])
																    return NSOrderedAscending;
															    
															    return NSOrderedSame;
															    
														    }];
	
	[sortFetchRequest setSortDescriptors: @[lightSortDescriptor]];
	
	__block NSArray *resultsArray;
	
	__block NSError *resultsError;
	
	VEManagedObjectContext *memoryContext = [[CPCoreDataManager sharedCoreDataManager] memoryContext];
	
	[memoryContext performBlockAndWait: ^{
		
		resultsArray = [memoryContext executeFetchRequest: sortFetchRequest error: &resultsError];
		
	}];

	if ([resultsArray count] != numberOfStations)
	{
		if ([resultsArray count] > numberOfStations)
		{
			resultsArray = [resultsArray subarrayWithRange: NSMakeRange(0, numberOfStations)];
		}
		else
		{
			CPLog(@"count differs: %lu", (unsigned long) numberOfStations);

			CPLog(@"results: %lu", (unsigned long) [resultsArray count]);
		}
	}

	#if kEnableCrashlytics

		if (resultsError)
			[[Crashlytics sharedInstance] recordError: resultsError];

	#endif

	
	NSAssert(!resultsError, @"Fetch error: %@", resultsError);
	
	NSMutableArray *tempNumbersToFetch = [NSMutableArray arrayWithCapacity: numberOfStations];
	
	[memoryContext performBlockAndWait: ^{
		
		for (LightStation *aLightStation in resultsArray)
		{
			[tempNumbersToFetch addObject: [aLightStation number]];
		}
		
	}];

	NSArray *sortedNumbersToFetch = [tempNumbersToFetch sortedArrayUsingSelector: @selector(compare:)];
	
	NSAssert(!resultsError, @"Fetch error: %@", resultsError);
	
	
	NSFetchRequest *stationFetchRequest = [NSFetchRequest fetchRequestWithEntityName: [Station entityName]];
	
	[stationFetchRequest setReturnsObjectsAsFaults: NO];
	
	#if enableNumberOfStations
	
		[stationFetchRequest setFetchLimit: numberOfStations];
	
	#endif
	
	NSPredicate *stationFetchRequestPredicate = [NSPredicate predicateWithFormat: @"%K in %@", NSStringFromSelector(@selector(number)), sortedNumbersToFetch];
	
	[stationFetchRequest setPredicate: stationFetchRequestPredicate];
	
	/*__block */NSArray *fetchedStations;
	
	/*__block */NSError *stationFetchRequestError;
	
	//VEManagedObjectContext *standardContext = [[CPCoreDataManager sharedCoreDataManager] standardContext];
	
	//[standardContext performBlockAndWait: ^{
		
		fetchedStations = [standardContext executeFetchRequest: stationFetchRequest error: &stationFetchRequestError];
	//}];

	if ([fetchedStations count] != numberOfStations)
	{
		if ([fetchedStations count] > numberOfStations)
		{
			fetchedStations = [fetchedStations subarrayWithRange: NSMakeRange(0, numberOfStations)];
		}
		else
		{
			CPLog(@"numbers to fetch: %lu", (unsigned long) numberOfStations);

			CPLog(@"fetched stations: %lu", (unsigned long) [fetchedStations count]);
		}
	}

	#if kEnableCrashlytics

		if (stationFetchRequestError)
			[[Crashlytics sharedInstance] recordError: stationFetchRequestError];

	#endif


	NSAssert(!stationFetchRequestError, @"Station fetch request error: %@", stationFetchRequestError);
		
	NSMutableArray *sortedFetchedStations = [NSMutableArray arrayWithCapacity: numberOfStations];

	for (NSNumber *aStationNumber in tempNumbersToFetch)
	{
		NSUInteger unsortedIndex = [sortedNumbersToFetch indexOfObject: aStationNumber];
		
		[sortedFetchedStations addObject: fetchedStations[unsortedIndex]];
	}
	
	[self setStations: sortedFetchedStations];	
}

- (void) userHasMovedToNewLocation: (CLLocation *) newLocation
{
	[self userHasMovedToNewLocation: newLocation withForce: NO];
}

- (void) userHasMovedToNewLocation: (CLLocation *) newLocation withForce: (BOOL) withForce
{
	NSUInteger realNumberOfStations = [VETimeFormatter numberOfBikeStations];
	
	if ([VETimeFormatter includesAdRemover])
		realNumberOfStations -= 1;
	
	if ([[self stations] count] == realNumberOfStations)
	{
		//CPLog(@"counts equal");
		
		if (!withForce)
			if ([newLocation ve_isCircaEqual: [self currentLocation]])
				return;
	}
	
	[self sortStationsByClosestToUserLocation: newLocation];
	
	[self userHasMovedToNewLocation: newLocation forceDisableUpdateStations: NO];
	
	//[mapView setMapType: [mapView mapType]];
	
	[self setCurrentStation: [self stations][0]];
	
	[[self stationsView] setStations: [self stations]];
	
	[self setCurrentLocation: newLocation];
}

- (CGFloat) actualMapViewHeight
{
	CGFloat mapViewHeight = CGRectGetHeight([[[self mapContainerView] mapView] bounds]);

	CGFloat contentHeight = CGRectGetHeight([[self stationsView] bounds]);

	//CPLog(@"mapview height: %f", mapViewHeight);
	
	//CPLog(@"content height: %f", contentHeight);
	
	mapViewHeight -= contentHeight;
	
	//CPLog(@"mapview height: %f", mapViewHeight);
	
	mapViewHeight = ceilf((float) mapViewHeight);
	
	//CPLog(@"mapview height: %f", mapViewHeight);
	
	return mapViewHeight;
}

- (void) takeScreenshot: (void (^)(UIImage *image)) completion
{
	MKMapView *mapView = [[self mapContainerView] mapView];
	
	MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
	
	MKMapRect mapRect;
	
	if ([self isShowingDirections])
	{
		mapRect = [self mapRectForDirections];
		
		MKMapSize mapSize = mapRect.size;
		
//		mapSize.height *= 1;
//		
//		mapSize.width *= 1;
		
		mapRect = MKMapRectInset(mapRect, -(mapSize.width), -(mapSize.height));
	}
	else
	{
		mapRect = [self mapRectForAnnotations];
	}
	
	[options setMapRect: mapRect];
	
	[options setMapType: [mapView mapType]];
	
	CGSize mapSize = [mapView bounds].size;
	
	//mapSize.height = [self actualMapViewHeight];
	
	[options setSize: mapSize];
	
	//[options setScale: [[UIScreen mainScreen] scale]];
	
	__weak VEMapViewController *weakSelf = self;
	
	__weak MKMapView *weakMapView = mapView;
	
	MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions: options];
	
	[self setMapSnapshotter: snapshotter];
	
	[snapshotter startWithCompletionHandler: ^(MKMapSnapshot *snapshot, NSError *error) {
		
		if (error)
		{
		#if kEnableCrashlytics

			[[Crashlytics sharedInstance] recordError: error];

		#endif


			CPLog(@"error: %@", error);
			
			return;
		}
		
		#if TARGET_IPHONE_SIMULATOR
		
			NSString *filePath = @"/Users/clementpadovani/Desktop/map/";
		
		#endif
		
		__strong VEMapViewController *strongSelf = weakSelf;
		
		__strong MKMapView *strongMapView = weakMapView;
		
		if (!strongSelf)
			CPLog(@"nil strong self");
		
		if (!strongMapView)
			CPLog(@"nil map view");
		
		UIImage *image = [snapshot image];
		
		CGRect toCropRect = CGRectZero;
		
		CGSize imageSize = [image size];
		
		CGAffineTransform scale = CGAffineTransformMakeScale([image scale], [image scale]);
		
		imageSize = CGSizeApplyAffineTransform(imageSize, scale);
		
		toCropRect.size = imageSize;
		
		CGFloat actualHeight = [strongSelf actualMapViewHeight];
		
		toCropRect.size.height = (actualHeight * [image scale]);
		
		MKAnnotationView *userLocationAnnotationView = [strongMapView viewForAnnotation: [strongMapView userLocation]];
		
		UIImage *userImage;
		
		if (!userLocationAnnotationView)
			CPLog(@"nil user location view");
		else
		{
			UIGraphicsBeginImageContextWithOptions([userLocationAnnotationView bounds].size, NO, 0);
			
			[[userLocationAnnotationView layer] renderInContext: UIGraphicsGetCurrentContext()];
			
			//BOOL hasRendered = [userLocationAnnotationView drawViewHierarchyInRect: [userLocationAnnotationView bounds] afterScreenUpdates: NO];
			
			//CPLog(@"has rendered: %@", hasRendered ? @"YES" : @"NO");
			
			userImage = UIGraphicsGetImageFromCurrentImageContext();
			
			UIGraphicsEndImageContext();
			
			if (!userImage)
				CPLog(@"nil user image");
		}
		
		UIGraphicsBeginImageContextWithOptions([image size], YES, 0);
		
		[image drawAtPoint: CGPointZero];
		
		//CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), NO);
		
		//CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), NO);
		
		if ([strongSelf isShowingDirections])
		{
			MKPolylineRenderer *directionsRenderer = (MKPolylineRenderer *) [strongMapView rendererForOverlay: [[strongSelf directionsRoute] polyline]];

			if (directionsRenderer)
			{
				//CPLog(@"has renderer");
				
				if ([directionsRenderer path])
				{
					CGContextRef context = UIGraphicsGetCurrentContext();
				
					UIColor *strokeColor = [directionsRenderer strokeColor];
					
					strokeColor = [strokeColor colorWithAlphaComponent: [directionsRenderer alpha]];
					
					CGContextSaveGState(context);
					
					CGContextSetStrokeColorWithColor(context, [strokeColor CGColor]);
					
					CGContextSetLineWidth(context, 6);
					
					CGContextSetLineJoin(context, kCGLineJoinRound);
					
					CGContextSetLineCap(context, kCGLineCapRound);
					
					CGContextSetMiterLimit(context, 10);
					
					CGContextBeginPath(context);
					
					NSUInteger pointCount = [[directionsRenderer polyline] pointCount];
					
					CLLocationCoordinate2D coordinates[pointCount];
					
					[[directionsRenderer polyline] getCoordinates: coordinates range: NSMakeRange(0, pointCount)];
					
					for (NSUInteger i = 0; i < pointCount; i++)
					{
						CGPoint point = [snapshot pointForCoordinate: coordinates[i]];
						
						//CPLog(@"point: %@", NSStringFromCGPoint(point));
						
						if (i == 0)
						{
							CGContextMoveToPoint(context, point.x, point.y);
						}
						else
						{
							CGContextAddLineToPoint(context, point.x, point.y);
						}
					}
					
					CGContextStrokePath(context);
					
					CGContextRestoreGState(context);
				}
				else
				{
					//CPLog(@"no path");
				}
			}
			else
			{
				//CPLog(@"no renderer");
			}
		}
		else
		{
			//CPLog(@"no directions");
		}
		
		CGRect imageRect = CGRectZero;
		
		imageRect.size = [image size];
		
		for (id <MKAnnotation> anAnnotation in [strongMapView annotations])
		{
			CGPoint annotationPoint = [snapshot pointForCoordinate: [anAnnotation coordinate]];
			
			
			
			MKAnnotationView *annotationView = [strongMapView viewForAnnotation: anAnnotation];
			
			if (CGRectContainsPoint(imageRect, annotationPoint))
			{
				annotationPoint.x = annotationPoint.x + [annotationView centerOffset].x - (CGRectGetWidth([annotationView bounds]) / 2);
				
				annotationPoint.y = annotationPoint.y + [annotationView centerOffset].y - (CGRectGetHeight([annotationView bounds]) / 2);
				
				annotationPoint.x = ceilf((float) annotationPoint.x);
				
				annotationPoint.y = ceilf((float) annotationPoint.y);
				
				if ([annotationView image])
				{
					[[annotationView image] drawAtPoint: annotationPoint];
				}
				else
				{
					if ([anAnnotation isEqual: [strongMapView userLocation]])
					{
						if (userImage)
						{
							[userImage drawAtPoint: annotationPoint];
						}
					}
				}
			}
			else
			{
				//CPLog(@"doesn't contain point");
			}
		}
	
		UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
		
		CGImageRef fullImageRef = CGImageCreateWithImageInRect([fullImage CGImage], toCropRect);
		
		UIImage *croppedFullImage = [UIImage imageWithCGImage: fullImageRef scale: [fullImage scale] orientation: [fullImage imageOrientation]];
		
		CGImageRelease(fullImageRef);
		
		#if TARGET_IPHONE_SIMULATOR
		
			NSData *fullImageData = UIImagePNGRepresentation(croppedFullImage);
			
			NSError *fullError = nil;
			
			NSString *fileName = [NSString stringWithFormat: @"full@%.0fx.png", [croppedFullImage scale]];
			
			BOOL fullHasSaved = [fullImageData writeToFile: [filePath stringByAppendingString: fileName] options: NSDataWritingAtomic error: &fullError];
			
			if (!fullHasSaved)
				CPLog(@"full error: %@", fullError);
			
		#endif
		
		UIGraphicsEndImageContext();
	
		completion(croppedFullImage);
		
		//CPLog(@"done");
	}];
}

//- (void) didSaveImage: (UIImage *) image withError: (NSError *) error context: (void *) context
//{
//	if (error)
//		CPLog(@"save error: %@", error);
//	else
//		CPLog(@"did save");
//
//#if kEnableCrashlytics
//
//	if (error)
//		[[Crashlytics sharedInstance] recordError: error];
//
//#endif
//
//}

#pragma mark -

#pragma mark MKMapView Delegate methods

- (void) mapView: (MKMapView *) mapView didFailToLocateUserWithError: (NSError *) error
{
	CPLog(@"did fail with error: %@", error);
}

- (void) mapView: (MKMapView *) mapView regionDidChangeAnimated: (BOOL) animated
{
	//CPLog(@"did change region");
	
	if (![self isFullyLoaded])
	{
		//CPLog(@"not loaded");
		
		return;
	}
	
	BOOL isLocationVisible = [[[self mapContainerView] mapView] isUserLocationVisible];
	
	//CPLog(@"location visible: %@", isLocationVisible ? @"YES" : @"NO");
	
	[self setCanShowUserLocationInCohort: isLocationVisible];
}

- (void) mapView: (MKMapView *) mapView annotationView: (MKAnnotationView *) view calloutAccessoryControlTapped: (UIControl *) control
{
	if (![view isKindOfClass: [VEStationAnnotationView class]])
		return;
	
	if ([control isKindOfClass: [VEStationAnnotationDirectionsAccessoryView class]])
	{
		//CPLog(@"directions");
		
		VEStationAnnotationView *annotationView = (VEStationAnnotationView *) view;
		
		Station *aStation = (Station *) [annotationView annotation];
		
		VEStationView *stationView = [[self stationsView] stationViewForStation: aStation];
		
		[stationView setShowingDirections: ![stationView isShowingDirections]];
	}
	else if ([control isKindOfClass: [VEStationAnnotationShareAccessoryView class]])
	{
		#if !TARGET_OS_TV
		//CPLog(@"share");
		
		if ([self mapSnapshotter])
		{
			CPLog(@"has map snapshotter!");
			
			if ([[self mapSnapshotter] isLoading])
			{
				CPLog(@"is loading");
				
				NSAssert(NO, @"Is Loading");
			}
			else
			{
				NSAssert(NO, @"already has snapshotter");
			}
		}
		
		[control setEnabled: NO];
		
		__weak UIControl *weakControl = control;
		
		__weak VEMapViewController *weakSelf = self;
		
		[self takeScreenshot: ^(UIImage *image) {
			
			__strong UIControl *strongControl = weakControl;
			
			__strong VEMapViewController *strongSelf = weakSelf;
			
			if (!strongControl)
				CPLog(@"nil control");
			
			[strongControl setEnabled: YES];
			
			//[strongSelf setMapSnapshotter: nil];
			
			UIActivityViewController *shareViewController = [[UIActivityViewController alloc] initWithActivityItems: @[image] applicationActivities: nil];
			
			[shareViewController setExcludedActivityTypes: @[UIActivityTypeAssignToContact]];
			
			//[shareViewController setModalPresentationStyle: UIModalPresentationFullScreen];
			
			if ([shareViewController respondsToSelector: @selector(popoverPresentationController)])
			{
				UIPopoverPresentationController *popoverPresentationController = [shareViewController popoverPresentationController];
				
				[popoverPresentationController setSourceView: [strongSelf view]];
			}
			
			CPLog(@"will present");
			
			[strongSelf presentViewController: shareViewController animated: YES completion: NULL];
			
			[strongSelf setMapSnapshotter: nil];
			
			//UIImageWriteToSavedPhotosAlbum(image, self, @selector(didSaveImage:withError:context:), NULL);
		}];
	#endif
	}
	else
	{
		CPLog(@"unknown");
		
		CPLog(@"%@", control);
	}
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id <MKAnnotation>) annotation
{	
	if ([annotation isKindOfClass: [MKUserLocation class]])
	{
		#if (SCREENSHOTS==1)

		[annotation setCoordinate: [[[VELocationManager sharedLocationManager] currentLocation] coordinate]];

		#endif
		return nil;
	}
	
	VEStationAnnotationView *stationAnnotationView = (VEStationAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: kVEMapViewControllerStationAnnotationViewReuseIdentifier];
	
	VEStationView *stationView = [[self stationsView] stationViewForStation: (Station *) annotation];
	
	if (!stationAnnotationView)
	{
		stationAnnotationView = [[VEStationAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: kVEMapViewControllerStationAnnotationViewReuseIdentifier withStationView: stationView];
	}
	else
	{
		[stationAnnotationView setAnnotation: annotation withStationView: stationView];
	}
	
	BOOL tableViewSelected = [annotation isEqual: [self stations][0]];
	
	[stationAnnotationView setTableViewSelected: tableViewSelected];
	
	return stationAnnotationView;	
}

- (MKOverlayRenderer *) mapView: (MKMapView *) mapView rendererForOverlay: (id <MKOverlay>) overlay
{
	MKOverlayRenderer *renderer;
	
	if ([overlay isKindOfClass: [MKPolyline class]])
	{
		renderer = [[VERouteRenderer alloc] initWithPolyline: overlay];
	}
	else
	{
		NSAssert(NO, @"Unknown overlay (%@): %@", NSStringFromClass([overlay class]), overlay);
	}
	
//	[renderer setStrokeColor: [UIColor mapViewControllerOverlayStrokeColor]];
	
	//[renderer setLineWidth: kVEMapViewControllerDirectionsLineWidth];
	
	//[renderer setLineWidth: 0];
	
//	[renderer setAlpha: kVEMapViewControllerDirectionsRouteAlpha];
	
	return renderer;
}

- (void) mapView: (MKMapView *) mapView didSelectAnnotationView: (MKAnnotationView *) view
{	
	if ([[view annotation] isEqual: [mapView userLocation]])
		return;
	
	Station *station = [(VEStationAnnotationView *) view annotation];
	
	NSUInteger stationIndex = [[self stations] indexOfObject: station];
	
	[[self stationsView] setCurrentStationIndex: stationIndex];
}

- (void) mapView: (MKMapView *) mapView didDeselectAnnotationView: (MKAnnotationView *) view
{
	if ([[view annotation] isEqual: [mapView userLocation]])
		return;
	
	if ([[self mapSnapshotter] isLoading])
	{
		//CPLog(@"is loading, will cancel");
		
		[[self mapSnapshotter] cancel];
		
		[self setMapSnapshotter: nil];
		
		VEStationAnnotationView *stationAnnotationView = (VEStationAnnotationView *) view;
		
		[[stationAnnotationView sharingAccessoryView] setEnabled: YES];
	}
}

#pragma mark -

- (BOOL) prefersStatusBarHidden
{
	return NO;
}

#pragma mark -

@end
