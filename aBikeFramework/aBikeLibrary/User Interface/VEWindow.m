//
//  VEWindow.m
//  abike—Lyon
//
//  Created by Clément Padovani on 4/30/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEWindow.h"

static const NSTimeInterval kLaunchImageHideDuration = 1;

static const NSTimeInterval kLaunchImageDelay = .5;

@interface VEWindow ()

@property (nonatomic, weak) UIView *launchView;

@end

@implementation VEWindow

- (instancetype) initWithFrame: (CGRect) frame
{
	self = [super initWithFrame: frame];
	
	if (self)
	{
		UIViewController *viewController = [[UIStoryboard storyboardWithName: @"Launch Screen"
														  bundle: nil] instantiateInitialViewController];

		UIView *launchView = [viewController view];

		[launchView setOpaque: YES];

		[self addSubview: launchView];

		_launchView = launchView;
	}
	
	return self;
}

- (void) showLaunchImage
{
	[self bringSubviewToFront: [self launchView]];
}

- (void) hideLaunchImage
{
	dispatch_async(dispatch_get_main_queue(), ^{
		
		[[self launchView] setOpaque: NO];
		
		[UIView animateWithDuration: kLaunchImageHideDuration
						  delay: kLaunchImageDelay
						options: UIViewAnimationOptionTransitionCrossDissolve
					  animations: ^{
						  [[self launchView] setAlpha: 0];
					  }
					  completion: ^(BOOL finished) {
						  
						  [self setWindowLevel: UIWindowLevelNormal];
						  
						  [[self launchView] removeFromSuperview];
						  
						  [self setLaunchView: nil];
						  
					  }];
		
	});
}

@end
