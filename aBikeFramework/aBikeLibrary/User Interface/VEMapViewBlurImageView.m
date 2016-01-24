//
//  VEMapViewBlurImageView.m
//  Velo'v
//
//  Created by Clément Padovani on 12/7/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "VEMapViewBlurImageView.h"

#import "VEConsul.h"

#import "UIColor+MainColor.h"

@interface VEMapViewBlurImageView ()

@property (nonatomic, weak) UIView *shadowView;

@property (nonatomic, weak) UIVisualEffectView *blurEffectView;

@property (nonatomic, assign) BOOL hasSetupConstraints;

@end

@implementation VEMapViewBlurImageView

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		UIView *shadowView = [[UIView alloc] init];
		
		[shadowView setOpaque: NO];
		
		[shadowView setBackgroundColor: [UIColor ve_shadowColor]];
		
		[shadowView setTranslatesAutoresizingMaskIntoConstraints: NO];
		
		UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect: [UIBlurEffect effectWithStyle: UIBlurEffectStyleExtraLight]];

		[blurEffectView setTranslatesAutoresizingMaskIntoConstraints: NO];

		[self addSubview: blurEffectView];
		
		[self addSubview: shadowView];
		
		_blurEffectView = blurEffectView;
		
		_shadowView = shadowView;
		
		[self setOpaque: NO];
		
		[self setBackgroundColor: [UIColor clearColor]];
		
		[self setTranslatesAutoresizingMaskIntoConstraints: NO];

		[[NSNotificationCenter defaultCenter] addObserver: self
										 selector: @selector(applicationStatusBarDidChangeFrame:)
											name: UIApplicationDidChangeStatusBarFrameNotification
										   object: nil];
	}
	
	return self;
}

- (void) setupConstraints
{
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_shadowView,
													   _blurEffectView);
 
	NSDictionary *metricsDictionary = @{@"shadowViewHeight" : @(.5)};
	
	NSArray *shadowViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[_shadowView]|"
																	   options: 0
																	   metrics: metricsDictionary
																		views: viewsDictionary];
	
	[self addConstraints: shadowViewHorizontalConstraints];
	
	NSArray *shadowViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[_shadowView(==shadowViewHeight)]|"
																	 options: 0
																	 metrics: metricsDictionary
																	   views: viewsDictionary];
	
	[self addConstraints: shadowViewVerticalConstraints];
	
		NSArray *blurEffectViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[_blurEffectView]|"
																			  options: 0
																			  metrics: metricsDictionary
																			    views: viewsDictionary];
		
		[self addConstraints: blurEffectViewHorizontalConstraints];
		
		NSArray *blurEffectViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[_blurEffectView]|"
																			options: 0
																			metrics: metricsDictionary
																			  views: viewsDictionary];
		
		[self addConstraints: blurEffectViewVerticalConstraints];
}

- (void) applicationStatusBarDidChangeFrame: (NSNotification *) notification
{
	[self invalidateIntrinsicContentSize];
}

- (CGSize) intrinsicContentSize
{
	CGFloat statusBarHeight = [[VEConsul sharedConsul] statusBarHeight];
	
	return CGSizeMake(UIViewNoIntrinsicMetric, statusBarHeight);
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self
									  forKeyPath: UIApplicationDidChangeStatusBarFrameNotification];
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
