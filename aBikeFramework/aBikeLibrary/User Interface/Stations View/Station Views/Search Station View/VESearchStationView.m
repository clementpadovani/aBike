//
//  VESearchStationView.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 2/19/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

#import "VESearchStationView.h"

@interface VESearchStationView () <UISearchBarDelegate>

@property (nonatomic, weak) UILabel *searchLabel;

@property (nonatomic, weak) UISearchBar *searchBar;

@property (nonatomic, assign) BOOL hasSetupConstraints;

@end

@implementation VESearchStationView

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

	[searchBar setPlaceholder: CPLocalizedString(@"Search for a place or area", @"VESearchStationView.searchTextFieldPlaceholder")];

	[searchBar setDelegate: self];

	[searchBar setTranslatesAutoresizingMaskIntoConstraints: NO];

	[self addSubview: searchLabel];

	[self addSubview: searchBar];

	[self setSearchLabel: searchLabel];

	[self setSearchBar: searchBar];
}

- (void) tintColorDidChange
{
	[super tintColorDidChange];

	[[self searchLabel] setTextColor: [self tintColor]];

	[[self searchBar] setBarTintColor: [self tintColor]];
}

- (BOOL) searchBarShouldEndEditing: (UISearchBar *) searchBar
{
	[searchBar resignFirstResponder];

	return YES;
}

- (void) searchBarCancelButtonClicked: (UISearchBar *) searchBar
{
	[searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked: (UISearchBar *) searchBar
{
	[searchBar resignFirstResponder];
}

- (void) setupConstraints
{
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_searchLabel,
													   _searchBar);
	
	NSDictionary *metricsDictionary = nil;

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[_searchLabel]-(>=0)-|"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-[_searchLabel]-[_searchBar]-(>=0)-|"
													  options: NSLayoutFormatAlignAllLeading
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:[_searchBar]-|"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];
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
