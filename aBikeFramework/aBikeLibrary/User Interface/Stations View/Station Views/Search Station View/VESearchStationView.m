//
//  VESearchStationView.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 2/19/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

#import "VESearchStationView.h"

#import "UIColor+MainColor.h"

#import "UserSettings+Additions.h"

#import "VEConsul.h"

#import "VEMapViewController.h"

#import "UIAlertAction+VEAdditions.h"

@interface VESearchStationView () <UISearchBarDelegate>

@property (nonatomic, weak) UILabel *searchLabel;

@property (nonatomic, weak) UISearchBar *searchBar;

@property (nonatomic, weak) UIActivityIndicatorView *spinnerView;

@property (nonatomic, weak) UIView *bottomBorderView;

@property (nonatomic, strong) MKLocalSearch *localSearcher;

@property (nonatomic, assign) BOOL hasSetupConstraints;

@end

@implementation VESearchStationView

+ (MKCoordinateRegion) currentCityRect
{
	static MKCoordinateRegion _currentCityRect;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		VECityRect cityRect = [[VEConsul sharedConsul] largerCurrentCityRect];

		MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(fabs(cityRect.maxLat - cityRect.minLat),
													fabs(cityRect.maxLon - cityRect.minLon));

		CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(((cityRect.maxLat + cityRect.minLat) / 2.),
															    ((cityRect.maxLon + cityRect.minLon) / 2.));

		_currentCityRect = MKCoordinateRegionMake(centerCoordinate,
										  coordinateSpan);
	});

	return _currentCityRect;
}

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		[self setLayoutMargins: UIEdgeInsetsMake(15, 15, 15, 15)];

		[self setBackgroundColor: [UIColor clearColor]];
		
		[self setOpaque: NO];
		
		[self setTranslatesAutoresizingMaskIntoConstraints: NO];
		
		[self setupViews];
	}
	
	return self;
}

- (void) setupViews
{
	UILabel *searchLabel = [[UILabel alloc] init];

	[searchLabel setFont: [UIFont preferredFontForTextStyle: UIFontTextStyleSubheadline]];

	[searchLabel setTextAlignment: NSTextAlignmentLeft];

	[searchLabel setText: CPLocalizedString(@"Search…", @"VESearchStationView.searchLabel")];

	[searchLabel setTranslatesAutoresizingMaskIntoConstraints: NO];

	UISearchBar *searchBar = [[UISearchBar alloc] init];

	[searchBar setSearchBarStyle: UISearchBarStyleMinimal];

	[searchBar setKeyboardAppearance: UIKeyboardAppearanceLight];

	[searchBar setBarStyle: UIBarStyleDefault];

	[searchBar setPlaceholder: CPLocalizedString(@"Search for a place or area", @"VESearchStationView.searchTextFieldPlaceholder")];

	[searchBar setDelegate: self];

	[searchBar setTranslatesAutoresizingMaskIntoConstraints: NO];

	UIActivityIndicatorView *spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];

	[spinnerView setHidesWhenStopped: YES];

	[spinnerView setTranslatesAutoresizingMaskIntoConstraints: NO];

	UIView *bottomBorderView = [[UIView alloc] init];

	[bottomBorderView setOpaque: NO];

	[bottomBorderView setBackgroundColor: [UIColor ve_shadowColor]];

	[bottomBorderView setTranslatesAutoresizingMaskIntoConstraints: NO];

	[self addSubview: searchLabel];

	[self addSubview: searchBar];

	[self addSubview: spinnerView];

	[self addSubview: bottomBorderView];

	[self setSearchLabel: searchLabel];

	[self setSearchBar: searchBar];

	[self setSpinnerView: spinnerView];

	[self setBottomBorderView: bottomBorderView];

	UITapGestureRecognizer *closeTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self
																			  action: @selector(userDidTap:)];

	[self addGestureRecognizer: closeTapGestureRecognizer];
}

- (void) userDidTap: (UITapGestureRecognizer *) tapGestureRecognizer
{
//	[UIView animateWithDuration: .2
//				  animations: ^{
					  [[self searchBar] resignFirstResponder];
//				  }];
}

- (void) tintColorDidChange
{
	[super tintColorDidChange];

	[[self searchLabel] setTextColor: [self tintColor]];

	[[self searchBar] setBarTintColor: [self tintColor]];

	[[self spinnerView] setColor: [self tintColor]];
}

- (void) setVisible: (BOOL) visible
{
	_visible = visible;

	if (!visible)
		[[self searchBar] resignFirstResponder];
}

- (BOOL) searchBarShouldEndEditing: (UISearchBar *) searchBar
{
//	[searchBar resignFirstResponder];

	return YES;
}

- (UIBarPosition) positionForBar: (id <UIBarPositioning>) bar
{
	return UIBarPositionTop;
}

- (void) searchBar: (UISearchBar *) searchBar textDidChange: (NSString *) searchText
{

}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[searchBar setShowsCancelButton: YES animated: YES];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	[searchBar setShowsCancelButton: NO animated: YES];
}

- (void) searchBarCancelButtonClicked: (UISearchBar *) searchBar
{
	[searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked: (UISearchBar *) searchBar
{
	[searchBar resignFirstResponder];

	if ([[self localSearcher] isSearching])
	{
		[[self spinnerView] stopAnimating];

		[[self localSearcher] cancel];
	}

	NSString *searchText = [searchBar text];

	if (!searchText ||
	    ![searchText length])
		return;

	MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];

	[searchRequest setNaturalLanguageQuery: searchText];

	[searchRequest setRegion: [[self class] currentCityRect]];

	MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest: searchRequest];

	__weak typeof(self) weakSelf = self;

	[[self spinnerView] startAnimating];

	[localSearch startWithCompletionHandler: ^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {

		if (error)
		{
			CPLog(@"error: %@", error);

			return;
		}

		__strong typeof(weakSelf) strongSelf = weakSelf;

//		UIAlertController *alertController = [UIAlertController alertControllerWithTitle: CPLocalizedString(@"Search Results", @"VESearchStationView.localSearch.title")
//																   message: nil
//															 preferredStyle: UIAlertControllerStyleAlert];

		UIAlertController *alertController = [UIAlertController alertControllerWithTitle: CPLocalizedString(@"Search Results", @"VESearchStationView.localSearch.title")
																   message: nil
															 preferredStyle: UIAlertControllerStyleActionSheet];

		void (^handleAlertAction)(UIAlertAction *action) = ^(UIAlertAction *action) {

			CPLog(@"action: %@", action);

			VEMapViewController *mapViewController = [[VEMapViewController alloc] initForSearchResult: [action ve_mapItem]];

			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: mapViewController];

			[[[VEConsul sharedConsul] mapViewController] presentViewController: navigationController
														   animated: YES
														 completion: ^{
															 [mapViewController loadMapData];
														 }];

		};


		for (MKMapItem *anItem in [response mapItems])
		{
			UIAlertAction *alertAction = [UIAlertAction actionWithTitle: [anItem name]
													    style: UIAlertActionStyleDefault
													  handler: handleAlertAction];

			[alertAction ve_setMapItem: anItem];

			[alertController addAction: alertAction];
		}


		UIAlertAction *closeAction = [UIAlertAction actionWithTitle: CPLocalizedString(@"Close", @"Close")
												    style: UIAlertActionStyleCancel
												  handler: ^(UIAlertAction * _Nonnull action) {

												  }];

		[alertController addAction: closeAction];

		VEMapViewController *mapViewController = [[VEConsul sharedConsul] mapViewController];

		[mapViewController presentViewController: alertController
								  animated: YES
								completion: NULL];

		[[strongSelf searchBar] resignFirstResponder];

		[[strongSelf spinnerView] stopAnimating];
	}];
	
	[self setLocalSearcher: localSearch];
}

- (void) setupConstraints
{
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_searchLabel,
													   _searchBar,
													   _spinnerView,
													   _bottomBorderView);

	CGFloat shadowViewHeight = 1.f / (float) [[UIScreen mainScreen] scale];

	NSDictionary *metricsDictionary = @{@"shadowViewHeight" : @(shadowViewHeight)};

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[_searchBar]-(>=0)-|"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-[_searchLabel]-[_searchBar]"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraint: [NSLayoutConstraint constraintWithItem: [self searchLabel]
											attribute: NSLayoutAttributeLeading
											relatedBy: NSLayoutRelationEqual
											   toItem: [self searchBar]
											attribute: NSLayoutAttributeLeadingMargin
										    multiplier: 1
											 constant: 0]];

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:[_searchBar]-|"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[_bottomBorderView]|"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[_searchBar]-(>=0)-[_bottomBorderView(==shadowViewHeight)]|"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:[_searchLabel]-(>=0)-[_spinnerView]-|"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraint: [NSLayoutConstraint constraintWithItem: [self spinnerView]
											attribute: NSLayoutAttributeBottom
											relatedBy: NSLayoutRelationEqual
											   toItem: [self searchLabel]
											attribute: NSLayoutAttributeBaseline
										    multiplier: 1
											 constant: 0]];

	[self addConstraint: [NSLayoutConstraint constraintWithItem: [self spinnerView]
											attribute: NSLayoutAttributeHeight
											relatedBy: NSLayoutRelationEqual
											   toItem: [self searchLabel]
											attribute: NSLayoutAttributeHeight
										    multiplier: 1
											 constant: 0]];

//	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[_searchBar][_spinnerViewTopSpacerView(==_spinnerView)][_spinnerView(==_spinnerViewBottomSpacerView)][_spinnerViewBottomSpacerView(==_spinnerViewTopSpacerView)][_bottomBorderView]"
//													  options: 0
//													  metrics: metricsDictionary
//													    views: viewsDictionary]];

//	[self addConstraint: [NSLayoutConstraint constraintWithItem: [self spinnerView]
//											attribute: NSLayoutAttributeCenterX
//											relatedBy: NSLayoutRelationEqual
//											   toItem: self
//											attribute: NSLayoutAttributeCenterX
//										    multiplier: 1
//											 constant: 0]];

	[self addConstraint: [NSLayoutConstraint constraintWithItem: [self spinnerView]
											attribute: NSLayoutAttributeWidth
											relatedBy: NSLayoutRelationEqual
											   toItem: [self spinnerView]
											attribute: NSLayoutAttributeHeight
										    multiplier: 1
											 constant: 0]];
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
