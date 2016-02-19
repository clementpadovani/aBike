//
//  VESearchStationView.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 2/19/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

#import "VESearchStationView.h"

#import "UIColor+MainColor.h"

@interface VESearchStationView () <UISearchBarDelegate>

@property (nonatomic, weak) UILabel *searchLabel;

@property (nonatomic, weak) UISearchBar *searchBar;

@property (nonatomic, weak) UIView *bottomBorderView;

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

	UIView *bottomBorderView = [[UIView alloc] init];

	[bottomBorderView setOpaque: NO];

	[bottomBorderView setBackgroundColor: [UIColor ve_shadowColor]];

	[bottomBorderView setTranslatesAutoresizingMaskIntoConstraints: NO];

	[self addSubview: searchLabel];

	[self addSubview: searchBar];

	[self addSubview: bottomBorderView];

	[self setSearchLabel: searchLabel];

	[self setSearchBar: searchBar];

	[self setBottomBorderView: bottomBorderView];

	UITapGestureRecognizer *closeTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self
																			  action: @selector(userDidTap:)];

	[self addGestureRecognizer: closeTapGestureRecognizer];
}

- (void) userDidTap: (UITapGestureRecognizer *) tapGestureRecognizer
{
	[[self searchBar] resignFirstResponder];
}

- (void) tintColorDidChange
{
	[super tintColorDidChange];

	[[self searchLabel] setTextColor: [self tintColor]];

	[[self searchBar] setBarTintColor: [self tintColor]];
}

- (void) setVisible: (BOOL) visible
{
	_visible = visible;

	if (!visible)
		[[self searchBar] resignFirstResponder];
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
													   _searchBar,
													   _bottomBorderView);

	CGFloat shadowViewHeight = 1.f / (float) [[UIScreen mainScreen] scale];

	NSDictionary *metricsDictionary = @{@"shadowViewHeight" : @(shadowViewHeight)};

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[_searchLabel]-(>=0)-|"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-[_searchLabel]-[_searchBar]"
													  options: NSLayoutFormatAlignAllLeading
													  metrics: metricsDictionary
													    views: viewsDictionary]];

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
