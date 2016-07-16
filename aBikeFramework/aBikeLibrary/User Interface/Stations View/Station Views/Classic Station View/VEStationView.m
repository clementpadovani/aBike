//
//  VEStationView.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/29/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEStationView.h"

#import "VEConsul.h"

#import "VETimeFormatter.h"

#import "UIColor+MainColor.h"

#import "VELocationManager.h"

#import "VEStation.h"

#import "VEMapViewController.h"

static const UIEdgeInsets kDirectionsButtonInsets = {14, 16, 14, 16};

@interface VEStationView ()

@property (nonatomic, weak) UILabel *stationNameLabel;
@property (nonatomic, weak) UILabel *stationNumberLabel;
@property (nonatomic, weak) UILabel *stationBonusLabel;

@property (nonatomic, weak) NSLayoutConstraint *stationBonusLabelVerticalConstraint;

@property (nonatomic, weak) UIView *horizontalSeperatorView;

@property (nonatomic, weak) UIView *horizontalSeperatorViewSpacerView;

@property (nonatomic, weak) UILabel *stationAvailableBikesLabel;
@property (nonatomic, weak) UILabel *stationAvailableSpotsLabel;

@property (nonatomic, strong) UIFont *availableFont;
@property (nonatomic, strong) UIFontDescriptor *availableFontDescriptor;

@property (nonatomic, weak) UILabel *directionsLabel;

@property (nonatomic, strong) MKDirections *currentStationDirections;

@property (nonatomic, strong) MKRoute *currentStationRoute;

@property (nonatomic, copy) CLLocation *currentDirectionsOriginLocation;

@property (nonatomic, weak) UIButton *directionsButton;

@property (nonatomic, assign) BOOL directionsAreDisabled;

@property (nonatomic, assign, readwrite) BOOL loadedDirections;

@property (nonatomic, assign) BOOL hasSetupConstraints;

- (void) setupStationNameAndNumberLabels;

- (void) setupHorizontalSeperatorView;

- (void) setupAvailableLabels;

- (void) setupAdditionalViews;

- (void) populateLabels;

- (void) loadDirectionsAndCo;

- (void) toggleDirections;

- (void) disableDirections;

- (void) enableDirections;

- (void) userInCityRectValueChanged: (NSNotification *) notification;

- (void) contentSizeDidChange: (NSNotification *) notification;

- (void) unitSystemDidChange: (NSNotification *) notification;

- (void) appDidEnterBackgroundNotification: (NSNotification *) notification;

@end

@implementation VEStationView

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		_directionsAreDisabled = NO;

		[self setupStationNameAndNumberLabels];
		
		[self setupHorizontalSeperatorView];
		
		[self setupAvailableLabels];
		
		[self setupAdditionalViews];
		
		[self setBackgroundColor: [UIColor clearColor]];
		
		[self setOpaque: NO];
		
		[self setTranslatesAutoresizingMaskIntoConstraints: NO];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userInCityRectValueChanged:) name: kVELocationManagerUserInCityRectDidChangeNotification object: nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(contentSizeDidChange:) name: UIContentSizeCategoryDidChangeNotification object: nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(unitSystemDidChange:) name: kVETimeFormatterUnitsChangedNotification object: nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appDidEnterBackgroundNotification:) name: kVEMapViewControllerViewGoToBackgroundNotification object: nil];
	}
	
	return self;
}

- (void) setDirectionsEnabled: (BOOL) directionsEnabled
{
	_directionsEnabled = directionsEnabled;

	if (!directionsEnabled)
		[self disableDirections];
}

- (void) setupStationNameAndNumberLabels
{
	UILabel *stationNameLabel = [[UILabel alloc] init];
	
	[stationNameLabel setText: @""];
	
	//[stationNameLabel setBackgroundColor: [UIColor blackColor]];
	
	[stationNameLabel setTextColor: [UIColor ve_mainColor]];
	
	[stationNameLabel setTextAlignment: NSTextAlignmentLeft];
	
	[stationNameLabel setFont: [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline]];
	
	[stationNameLabel setAdjustsFontSizeToFitWidth: YES];
	
	[stationNameLabel setMinimumScaleFactor: .6f];
	
	//[stationNameLabel setContentCompressionResistancePriority: UILayoutPriorityFittingSizeLevel forAxis: UILayoutConstraintAxisVertical];
	
	//[stationNameLabel setContentHuggingPriority: UILayoutPriorityFittingSizeLevel forAxis: UILayoutConstraintAxisVertical];
	
	//[stationNameLabel setContentMode: UIViewContentModeRedraw];
	
	[stationNameLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	UILabel *stationNumberLabel = [[UILabel alloc] init];
	
	[stationNumberLabel setText: @""];
	
	//[stationNumberLabel setBackgroundColor: [UIColor blackColor]];
	
	[stationNumberLabel setTextColor: [UIColor ve_stationNumberTextColor]];
	
	[stationNumberLabel setTextAlignment: NSTextAlignmentLeft];
	
	[stationNumberLabel setFont: [UIFont preferredFontForTextStyle: UIFontTextStyleSubheadline]];
	
	//[stationNumberLabel setContentCompressionResistancePriority: UILayoutPriorityFittingSizeLevel forAxis: UILayoutConstraintAxisVertical];
	
	//[stationNumberLabel setContentHuggingPriority: UILayoutPriorityFittingSizeLevel forAxis: UILayoutConstraintAxisVertical];
	
	//[stationNumberLabel setContentMode: UIViewContentModeRedraw];
	
	[stationNumberLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	UILabel *stationBonusLabel = [[UILabel alloc] init];
	
	[stationBonusLabel setText: @""];
	
	[stationBonusLabel setTextColor: [UIColor ve_mainColor]];
	
	[stationBonusLabel setTextAlignment: NSTextAlignmentLeft];
	
	[stationBonusLabel setFont: [UIFont preferredFontForTextStyle: UIFontTextStyleCaption2]];
	
	[stationBonusLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	[stationBonusLabel setHidden: YES];
	
	[self addSubview: stationNameLabel];
	
	[self addSubview: stationNumberLabel];
	
	[self addSubview: stationBonusLabel];
	
	_stationNameLabel = stationNameLabel;
	
	_stationNumberLabel = stationNumberLabel;
	
	_stationBonusLabel = stationBonusLabel;
}

- (void) setupHorizontalSeperatorView
{
	UIView *horizontalSeperatorViewSpacerView = [[UIView alloc] init];
	
	[horizontalSeperatorViewSpacerView setBackgroundColor: [UIColor clearColor]];
	
	//[horizontalSeperatorViewSpacerView setBackgroundColor: [UIColor greenColor]];
	
	[horizontalSeperatorViewSpacerView setOpaque: NO];
	
	[horizontalSeperatorViewSpacerView setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	UIView *horizontalSeperatorView = [[UIView alloc] init];
	
	[horizontalSeperatorView setBackgroundColor: [UIColor ve_horizontalSeperatorColor]];
	
	[horizontalSeperatorView setOpaque: YES];
	
	[horizontalSeperatorView setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	[self addSubview: horizontalSeperatorViewSpacerView];
	
	[self addSubview: horizontalSeperatorView];

	_horizontalSeperatorViewSpacerView = horizontalSeperatorViewSpacerView;
	
	_horizontalSeperatorView = horizontalSeperatorView;
}

- (void) setupAvailableLabels
{
	UILabel *stationAvailableBikesLabel = [[UILabel alloc] init];
	
	//[stationAvailableBikesLabel setBackgroundColor: [UIColor blackColor]];
	
	[stationAvailableBikesLabel setText: @""];
		
	[stationAvailableBikesLabel setTextColor: [UIColor ve_stationNumberTextColor]];
	
	[stationAvailableBikesLabel setTextAlignment: NSTextAlignmentLeft];
	
	[stationAvailableBikesLabel setFont: [self availableFont]];
	
	[stationAvailableBikesLabel setAdjustsFontSizeToFitWidth: YES];
	
	[stationAvailableBikesLabel setMinimumScaleFactor: .5f];
	
	[stationAvailableBikesLabel setPreferredMaxLayoutWidth: 140];
	
	[stationAvailableBikesLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	UILabel *stationAvailableSpotsLabel = [[UILabel alloc] init];
	
	//[stationAvailableSpotsLabel setBackgroundColor: [UIColor blackColor]];
	
	[stationAvailableSpotsLabel setText: @""];
	
	[stationAvailableSpotsLabel setTextColor: [UIColor ve_stationNumberTextColor]];
	
	[stationAvailableSpotsLabel setTextAlignment: NSTextAlignmentRight];
	
	[stationAvailableSpotsLabel setFont: [self availableFont]];
	
	[stationAvailableSpotsLabel setAdjustsFontSizeToFitWidth: YES];
	
	[stationAvailableSpotsLabel setMinimumScaleFactor: .5f];
	
	[stationAvailableSpotsLabel setPreferredMaxLayoutWidth: 140];
	
	[stationAvailableSpotsLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	[self addSubview: stationAvailableBikesLabel];
	
	[self addSubview: stationAvailableSpotsLabel];
	
	_stationAvailableBikesLabel = stationAvailableBikesLabel;
	
	_stationAvailableSpotsLabel = stationAvailableSpotsLabel;
}

- (void) setupAdditionalViews
{
	UILabel *directionsLabel = [[UILabel alloc] init];
	
	//[directionsLabel setBackgroundColor: [UIColor blackColor]];
	
	//[directionsLabel setBackgroundColor: [UIColor purpleColor]];
	
	[directionsLabel setText: @""];
	
	[directionsLabel setNumberOfLines: 2];
	
	[directionsLabel setTextColor: [UIColor ve_stationNumberTextColor]];
	
	[directionsLabel setTextAlignment: NSTextAlignmentRight];
	
	[directionsLabel setFont: [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1]];
	
	[directionsLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	UIButton *directionsButton = [UIButton buttonWithType: UIButtonTypeCustom];

	[directionsButton setEnabled: NO];
	
	UIImage *directionsImage = [UIImage imageNamed: @"directionsIcon"
								   inBundle: [NSBundle ve_libraryResources]
				  compatibleWithTraitCollection: nil];
	
	UIImage *disabledDirectionsImage = [UIImage imageNamed: @"noDirectionsIcon"
										 inBundle: [NSBundle ve_libraryResources]
						compatibleWithTraitCollection: nil];
	
	UIImage *templateDirectionsImage = [directionsImage imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];


	#if (SCREENSHOTS==1)

	[directionsButton setAccessibilityIdentifier: @"directionsIcon"];

	#endif

	[directionsButton setImage: disabledDirectionsImage forState: UIControlStateDisabled];
	
	[directionsButton setImage: templateDirectionsImage forState: UIControlStateNormal];
	
	[directionsButton setImage: directionsImage forState: UIControlStateSelected];
	
	//[directionsButton setImageEdgeInsets: kDirectionsButtonInsets];
	
	[directionsButton setContentEdgeInsets: kDirectionsButtonInsets];
	
	//[directionsButton setBackgroundColor: [UIColor greenColor]];
	
	//[[directionsButton imageView] setBackgroundColor: [UIColor greenColor]];
	
	[directionsButton addTarget: self action: @selector(toggleDirections) forControlEvents: UIControlEventTouchUpInside];
	
	[directionsButton setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	[self addSubview: directionsLabel];
	
	[self addSubview: directionsButton];
	
	_directionsLabel = directionsLabel;
	
	_directionsButton = directionsButton;
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

- (void) setupConstraints
{
	NSDictionary *viewsDictionary = @{@"self" : self,
							    @"_stationNameLabel" : [self stationNameLabel],
							    @"_stationNumberLabel" : [self stationNumberLabel],
							    @"_stationBonusLabel" : [self stationBonusLabel],
							    @"_horizontalSeperatorView" : [self horizontalSeperatorView],
							    @"_horizontalSeperatorViewSpacerView" : [self horizontalSeperatorViewSpacerView],
							    @"_stationAvailableBikesLabel" : [self stationAvailableBikesLabel],
							    @"_stationAvailableSpotsLabel" : [self stationAvailableSpotsLabel],
							    @"_directionsLabel" : [self directionsLabel],
							    @"_directionsButton" : [self directionsButton]};

	CGFloat shadowViewHeight = 1.f / (float) [[UIScreen mainScreen] scale];

	NSDictionary *metricsDictionary = @{@"selfWidth" : @(320),
								 @"selfHeight" : @(152),
								 @"leftPadding" : @(15),
								 @"rightPadding" : @(15),
								 @"buttonTopPadding" : @(13.5),
								 @"buttonRightPadding" : @(.0),
								 @"stationNameVerticalPadding" : @(8),
								 @"stationNumberVerticalPaddingToStationName" : @(1),
								 @"horizontalSeperatorViewHeight" : @(shadowViewHeight),
								 @"horizontalVerticalPaddingFromDirections" : @(8),
								 @"availableBottomPadding" : @(-45),
								 @"availableMinimumPadding" : @(10),
								 @"stationNameDirectionsButtonMinimumPadding" : @(5)};
	
//	NSArray *selfWidthConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:[self(==selfWidth)]"
//															  options: 0
//															  metrics: metricsDictionary
//															    views: viewsDictionary];
//	
//	[self addConstraints: selfWidthConstraints];
	
	NSArray *selfHeightConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[self(==selfHeight)]"
															   options: 0
															   metrics: metricsDictionary
																views: viewsDictionary];
	
	[self addConstraints: selfHeightConstraints];
	
	NSArray *stationNameHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-leftPadding-[_stationNameLabel]"
																	    options: 0
																	    metrics: metricsDictionary
																		 views: viewsDictionary];
	
	[self addConstraints: stationNameHorizontalConstraints];
	
	NSArray *stationNumberHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-leftPadding-[_stationNumberLabel]"
																		 options: 0
																		 metrics: metricsDictionary
																		   views: viewsDictionary];
	
	[self addConstraints: stationNumberHorizontalConstraints];
	
	NSArray *stationBonusLabelHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-leftPadding-[_stationBonusLabel]"
																		 options: 0
																		 metrics: metricsDictionary
																		   views: viewsDictionary];
	
	[self addConstraints: stationBonusLabelHorizontalConstraints];
	
	NSArray *stationNameStationNumberVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-stationNameVerticalPadding-[_stationNameLabel]-stationNumberVerticalPaddingToStationName-[_stationNumberLabel]"
																				options: 0
																				metrics: metricsDictionary
																				  views: viewsDictionary];
	
	[self addConstraints: stationNameStationNumberVerticalConstraints];
	
	
	NSLayoutConstraint *stationBonusLabelVerticalConstraint = [NSLayoutConstraint constraintWithItem: [self stationBonusLabel]
																		  attribute: NSLayoutAttributeBottom
																		  relatedBy: NSLayoutRelationEqual
																			toItem: [self horizontalSeperatorView]
																		  attribute: NSLayoutAttributeTop
																		 multiplier: 1
																		   constant: -5];
	
	[self addConstraint: stationBonusLabelVerticalConstraint];
	
	[self setStationBonusLabelVerticalConstraint: stationBonusLabelVerticalConstraint];
	
	NSArray *seperatorViewHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-leftPadding-[_horizontalSeperatorView]-rightPadding-|"
																		options: 0
																		metrics: metricsDictionary
																		  views: viewsDictionary];
	
	[self addConstraints: seperatorViewHorizontalConstraint];
	
	NSArray *verticalSeperatorViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[_horizontalSeperatorView(==horizontalSeperatorViewHeight)]"
																	    options: 0
																	    metrics: metricsDictionary
																		 views: viewsDictionary];
	
	[self addConstraints: verticalSeperatorViewConstraints];
	
//	NSArray *centeredSeperatorViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[_directionsLabel]->=0-[_horizontalSeperatorView]->=0-[_stationAvailableBikesLabel]"
//																			  options: 0
//																			  metrics: metricsDictionary
//																			    views: viewsDictionary];
//	
//	[self addConstraints: centeredSeperatorViewVerticalConstraints];
	
	NSArray *spacerViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[_horizontalSeperatorViewSpacerView]|"
																	   options: 0
																	   metrics: metricsDictionary
																		views: viewsDictionary];
	
	[self addConstraints: spacerViewHorizontalConstraints];
	
	NSArray *spacerViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[_directionsLabel][_horizontalSeperatorViewSpacerView][_stationAvailableBikesLabel]"
																	 options: 0
																	 metrics: metricsDictionary
																	   views: viewsDictionary];
	
	[self addConstraints: spacerViewVerticalConstraints];
	
	NSLayoutConstraint *horizontalSeperatorViewVerticalConstraint = [NSLayoutConstraint constraintWithItem: [self horizontalSeperatorView]
																			   attribute: NSLayoutAttributeCenterY
																			   relatedBy: NSLayoutRelationEqual
																				 toItem: [self horizontalSeperatorViewSpacerView]
																			   attribute: NSLayoutAttributeCenterY
																			  multiplier: 1
																			    constant: 0];
	
	[self addConstraint: horizontalSeperatorViewVerticalConstraint];
		
	NSArray *availableLabelsHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-leftPadding-[_stationAvailableBikesLabel]->=availableMinimumPadding-[_stationAvailableSpotsLabel(==_stationAvailableBikesLabel)]-rightPadding-|"
																		   options: NSLayoutFormatAlignAllBaseline
																		   metrics: metricsDictionary
																			views: viewsDictionary];
	
	[self addConstraints: availableLabelsHorizontalConstraints];
	
	NSLayoutConstraint *availableBikesVerticalConstraint = [NSLayoutConstraint constraintWithItem: [self stationAvailableBikesLabel]
																	    attribute: NSLayoutAttributeBaseline
																	    relatedBy: NSLayoutRelationEqual
																		  toItem: self
																	    attribute: NSLayoutAttributeBottom
																	   multiplier: 1
																		constant: [metricsDictionary[@"availableBottomPadding"] floatValue]];
	
	[self addConstraint: availableBikesVerticalConstraint];

	NSArray *directionsLabelHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:[_directionsLabel]-rightPadding-|"
																		   options: 0
																		   metrics: metricsDictionary
																			views: viewsDictionary];
	
	[self addConstraints: directionsLabelHorizontalConstraints];
	
	NSLayoutConstraint *directionsLabelVerticalConstraint = [NSLayoutConstraint constraintWithItem: [self directionsLabel]
																		attribute: NSLayoutAttributeTop
																		relatedBy: NSLayoutRelationEqual
																		   toItem: [self stationNumberLabel]
																		attribute: NSLayoutAttributeBaseline
																	    multiplier: 1
																		 constant: 0];
	
	[self addConstraint: directionsLabelVerticalConstraint];
	
	NSArray *stationNameDirectionsButtonsHorizontalPaddingConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:[_stationNameLabel]->=stationNameDirectionsButtonMinimumPadding-[_directionsButton]-buttonRightPadding-|"
																						   options: 0
																						   metrics: metricsDictionary
																							views: viewsDictionary];
	
	[self addConstraints: stationNameDirectionsButtonsHorizontalPaddingConstraints];
	
	NSLayoutConstraint *directionsButtonVerticalConstraint = [NSLayoutConstraint constraintWithItem: [self directionsButton]
																		 attribute: NSLayoutAttributeTop
																		 relatedBy: NSLayoutRelationEqual
																		    toItem: [self stationNameLabel]
																		 attribute: NSLayoutAttributeTop
																		multiplier: 1
																		  constant: -14];
	
	[self addConstraint: directionsButtonVerticalConstraint];
}

- (void) layoutSubviews
{
	CGFloat selfWidth = CGRectGetWidth([self bounds]);
	
	CGFloat maxWidth = selfWidth;
	
	maxWidth -= 60;
	
	[[self stationNameLabel] setPreferredMaxLayoutWidth: maxWidth];
	
	[super layoutSubviews];
}

- (void) setCurrentStation: (VEStation *) currentStation
{
	_currentStation = currentStation;
	
	if (!_currentStation)
		return;
	
	if ([self isShowingDirections])
		[self setShowingDirections: NO];
	
	[self populateLabels];
	
	[self loadDirectionsAndCo];
}

- (void) populateLabels
{
	NSString *stationNameString = [[self currentStation] processedStationName];
	
	[[self stationNameLabel] setText: stationNameString];
	
	//[[self stationNameLabel] sizeToFit];
	
//	NSString *stationNumberString = [[[self currentStation] number] stringValue];

    NSString *stationNumberString = [NSString stringWithFormat: @"%d", [[self currentStation] stationID]];
    
	[[self stationNumberLabel] setText: stationNumberString];
	
	//[[self stationNumberLabel] sizeToFit];
	
	if ([[self currentStation] isBonusStation])
	{
		[[self stationBonusLabel] setText: CPLocalizedString(@"BONUS", @"VEStationView_bonus_station")];
	}
	else
	{
		//[[self stationBonusLabel] setText: @"not bonus"];
		
		[[self stationBonusLabel] setText: @""];
	}
	
	//NSString *availableBikes = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Bikes", @"VEStationView_available_bikes"), (unsigned long) [[self currentStation] availableBikes]];
	
	[[self stationAvailableBikesLabel] setText: [[self currentStation] availableBikesString]];
	
	//NSString *availableSpots = [NSString stringWithFormat: CPLocalizedString(@"%lu Available Stands", @"VEStationView_available_stands"), (unsigned long) [[self currentStation] availableBikeStations]];
	
	[[self stationAvailableSpotsLabel] setText: [[self currentStation] availableBikeStationsString]];
	
	[[self directionsLabel] setText: CPLocalizedString(@"Loading Directions…", @"VEStationView_loading_directions")];
}

#pragma clang diagnostic push

#pragma clang diagnostic ignored "-Wunreachable-code"

- (void) loadDirectionsAndCo
{
	#if kDisableDirections
	
		[self disableDirections];
	
		return;
	
	#endif

	if (![self areDirectionsEnabled])
	{
		[self disableDirections];
		
		return;
	}
	
	[self setLoadedDirections: NO];
	
	if ([[self currentStationDirections] isCalculating])
	{
		[[self currentStationDirections] cancel];
        
        [self setCurrentStationDirections: nil];
		
		[[VEConsul sharedConsul] stopLoadingSpinner];
		
	}
	
	[[self directionsButton] setEnabled: NO];
	
	if (![[VELocationManager sharedLocationManager] userIsInCity])
	{
		[self disableDirections];
		
		return;
	}
	else
	{
		if ([self directionsAreDisabled])
			[self enableDirections];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: kVEStationViewDidStartLoadingDirectionsNotification object: self];
	
	[[VEConsul sharedConsul] startLoadingSpinner];
	
	[self setCurrentDirectionsOriginLocation: [[VELocationManager sharedLocationManager] currentLocation]];
	
	MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
	
	//MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
	
	MKPlacemark *currentLocationPlacemark = [[MKPlacemark alloc] initWithCoordinate: [[[VELocationManager sharedLocationManager] currentLocation] coordinate] addressDictionary: nil];
	
	MKMapItem *currentLocationMapItem = [[MKMapItem alloc] initWithPlacemark: currentLocationPlacemark];
	
	[directionsRequest setSource: currentLocationMapItem];
	
	[directionsRequest setDestination: [[self currentStation] mapItem]];
	
	[directionsRequest setTransportType: MKDirectionsTransportTypeWalking];
	
	[directionsRequest setDepartureDate: [NSDate date]];
	
	MKDirections *directions = [[MKDirections alloc] initWithRequest: directionsRequest];
	
	[self setCurrentStationDirections: directions];
	
	__weak VEStationView *weakSelf = self;
	
	[directions calculateDirectionsWithCompletionHandler: ^(MKDirectionsResponse *response, NSError *error) {
		
		__strong VEStationView *strongSelf = weakSelf;
		
		NSString *directionsString;
		
		if (error)
		{
			CPLog(@"error: %@", error);

			#if kEnableCrashlytics

			BOOL isInternetOfflineError = ([[error domain] isEqualToString: NSURLErrorDomain] &&
									 [error code] == NSURLErrorNotConnectedToInternet);


				if (!isInternetOfflineError)
					[[Crashlytics sharedInstance] recordError: error];
			
			#endif
			
			directionsString = CPLocalizedString(@"An error occured.", @"VEStationView_directions_error");
		}
		else
		{
			MKRoute *route = [response routes][0];
			
			directionsString = [NSString string];
			
			directionsString = [directionsString stringByAppendingString: [[VETimeFormatter sharedDistanceFormatter] stringFromDistance: [route distance]]];
			
			directionsString = [directionsString stringByAppendingString: @"\n"];
			
			directionsString = [directionsString stringByAppendingString: [VETimeFormatter formattedStringForETA: [route expectedTravelTime]]];
			
			[strongSelf setCurrentStationRoute: route];
			
			[[strongSelf directionsButton] setEnabled: YES];
			
			[strongSelf distanceLabelContentDidLoad];
		}
		
		[[strongSelf directionsLabel] setText: directionsString];
		
		[[VEConsul sharedConsul] stopLoadingSpinner];
		
		[strongSelf setLoadedDirections: YES];
		
		[[NSNotificationCenter defaultCenter] postNotificationName: kVEStationViewDidLoadDirectionsNotification object: self];
	}];
}

#pragma clang diagnostic pop

- (void) disableDirections
{
	[[self directionsLabel] setText: @""];
	
	[[self directionsButton] setEnabled: NO];
	
	[self setCurrentDirectionsOriginLocation: nil];
	
	[self setCurrentStationDirections: nil];
	
	[self setCurrentStationRoute: nil];
	
	[self setDirectionsAreDisabled: YES];
	
	[self removeConstraint: [self stationBonusLabelVerticalConstraint]];
	
	NSLayoutConstraint *stationBonusLabelVerticalConstraint = [NSLayoutConstraint constraintWithItem: [self stationBonusLabel]
																		  attribute: NSLayoutAttributeBottom
																		  relatedBy: NSLayoutRelationEqual
																			toItem: [self horizontalSeperatorView]
																		  attribute: NSLayoutAttributeTop
																		 multiplier: 1
																		   constant: -5];
	
	[self addConstraint: stationBonusLabelVerticalConstraint];
	
	[self setStationBonusLabelVerticalConstraint: stationBonusLabelVerticalConstraint];
}

- (void) enableDirections
{
	[self setDirectionsAreDisabled: NO];
}

- (void) distanceLabelContentDidLoad
{
	[self removeConstraint: [self stationBonusLabelVerticalConstraint]];
	
	NSLayoutConstraint *stationBonusLabelVerticalConstraint = [NSLayoutConstraint constraintWithItem: [self stationBonusLabel]
																		  attribute: NSLayoutAttributeBaseline
																		  relatedBy: NSLayoutRelationEqual
																			toItem: [self directionsLabel]
																		  attribute: NSLayoutAttributeBaseline
																		 multiplier: 1
																		   constant: 0];
	
	[self addConstraint: stationBonusLabelVerticalConstraint];
	
	[self setStationBonusLabelVerticalConstraint: stationBonusLabelVerticalConstraint];
}

- (void) toggleDirections
{
	//CPLog(@"frame: %@", NSStringFromCGRect([[self directionsButton] frame]));
	
	[self setShowingDirections: ![self isShowingDirections]];
}

- (void) appDidEnterBackgroundNotification: (NSNotification *) notification
{
	//CPLog(@"station bg notif");
	
	if ([self isShowingDirections])
	{
		//CPLog(@"hide directions");
		
		[self setShowingDirections: NO];
	}
}

- (void) userInCityRectValueChanged: (NSNotification *) notification
{
	if ([self currentStation])
		[self loadDirectionsAndCo];
}

- (void) tintColorDidChange
{
	[super tintColorDidChange];
	
	[[self stationNameLabel] setTextColor: [self tintColor]];
}

- (void) contentSizeDidChange: (NSNotification *) notification
{
	//CPLog(@"content size did change");
	
	[self setAvailableFontDescriptor: [self getAvailableFontDescriptor]];
	
	[self setAvailableFont: [self getAvailableFont]];
	
	[[self stationNameLabel] setFont: [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline]];
	
	[[self stationNumberLabel] setFont: [UIFont preferredFontForTextStyle: UIFontTextStyleSubheadline]];
	
	[[self stationBonusLabel] setFont: [UIFont preferredFontForTextStyle: UIFontTextStyleCaption2]];
	
	[[self directionsLabel] setFont: [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1]];
	
	[[self stationAvailableBikesLabel] setFont: [self availableFont]];
	
	[[self stationAvailableSpotsLabel] setFont: [self availableFont]];
}

- (void) unitSystemDidChange: (NSNotification *) notification
{
	if ([[self directionsButton] isEnabled])
	{
		NSString *directionsString = [NSString string];
		
		directionsString = [directionsString stringByAppendingString: [[VETimeFormatter sharedDistanceFormatter] stringFromDistance: [[self currentStationRoute] distance]]];
		
		directionsString = [directionsString stringByAppendingString: @"\n"];
		
		directionsString = [directionsString stringByAppendingString: [VETimeFormatter formattedStringForETA: [[self currentStationRoute] expectedTravelTime]]];
		
		[[self directionsLabel] setText: directionsString];
		
		return;
	}
}

- (void) setShowingDirections: (BOOL) showingDirections
{	
	_showingDirections = showingDirections;
		
	[[self directionsButton] setSelected: showingDirections];
	
	[[self delegate] loadDirectionsInfoWithRoute: showingDirections ? [self currentStationRoute] : nil forStation: [self currentStation]];

}

- (UIFont *) availableFont
{
	if (!_availableFont)
	{
		UIFont *availableFont = [self getAvailableFont];
		
		_availableFont = availableFont;
	}
	
	return _availableFont;
}

- (UIFontDescriptor *) availableFontDescriptor
{
	if (!_availableFontDescriptor)
	{
		UIFontDescriptor *availableFontDescriptor = [self getAvailableFontDescriptor];
		
		_availableFontDescriptor = availableFontDescriptor;
	}
	
	return _availableFontDescriptor;
}

- (UIFont *) getAvailableFont
{
	return [UIFont fontWithDescriptor: [self availableFontDescriptor] size: 0];
}

- (UIFontDescriptor *) getAvailableFontDescriptor
{
	UIFontDescriptor *availableFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle: UIFontTextStyleFootnote];
	
	availableFontDescriptor = [availableFontDescriptor fontDescriptorWithSymbolicTraits: ([availableFontDescriptor symbolicTraits] | UIFontDescriptorTraitItalic)];
	
	return availableFontDescriptor;
}

- (void) dealloc
{
	if ([self isShowingDirections])
		[self setShowingDirections: NO];

	if ([_currentStationDirections isCalculating])
		[_currentStationDirections cancel];

	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	//CPLog(@"has dealloced");
}

+ (BOOL) requiresConstraintBasedLayout
{
	return YES;
}

@end
