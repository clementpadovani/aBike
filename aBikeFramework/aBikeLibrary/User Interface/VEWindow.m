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

+ (NSString *) imagePathForCurrentDevice;

@property (weak, nonatomic) UIImageView *launchImageView;

@end

@implementation VEWindow

- (instancetype) initWithFrame: (CGRect) frame
{
	self = [super initWithFrame: frame];
	
	if (self)
	{
		//CPLog(@"frame: %@", NSStringFromCGRect(frame));
		
//		CGFloat height = CGRectGetHeight(frame);
//				
//		NSString *imageName = (height > 480) ? @"LaunchImage-700-568h@2x" : @"LaunchImage-700@2x";
//		
//		NSString *imagePath = [[NSBundle mainBundle] pathForResource: imageName ofType: @"png"];

		NSString *imagePath = [[self class] imagePathForCurrentDevice];
		
		UIImage *launchImage = [UIImage imageWithContentsOfFile: imagePath];
		
		UIImageView *launchImageView = [[UIImageView alloc] initWithImage: launchImage];
		
		[launchImageView setOpaque: YES];
		
		[self addSubview: launchImageView];
		
		_launchImageView = launchImageView;
	}
	
	return self;
}

- (void) showLaunchImage
{
	[self bringSubviewToFront: [self launchImageView]];
}

- (void) hideLaunchImage
{
	dispatch_async(dispatch_get_main_queue(), ^{
		
		[[self launchImageView] setOpaque: NO];
		
		[UIView animateWithDuration: kLaunchImageHideDuration
						  delay: kLaunchImageDelay
						options: UIViewAnimationOptionTransitionCrossDissolve
					  animations: ^{
						  [[self launchImageView] setAlpha: 0];
					  }
					  completion: ^(BOOL finished) {
						  
						  [self setWindowLevel: UIWindowLevelNormal];
						  
						  [[self launchImageView] removeFromSuperview];
						  
						  [self setLaunchImageView: nil];
						  
					  }];
		
	});
}

//- (void) tintColorDidChange
//{
//	//CPLog(@"tint did change");
//	
//	[super tintColorDidChange];
//	
//	CPLog(@"tint mode: %@", NSStringFromUIViewTintMode([self tintAdjustmentMode]));
//}

+ (NSString *) imagePathForCurrentDevice
{
	CGRect bounds = [[UIScreen mainScreen] bounds];
	
	CGFloat height = CGRectGetHeight(bounds);
	
	//CPLog(@"bounds: %@", NSStringFromCGRect(bounds));
	
	//CPLog(@"height: %f", height);
	
	NSString *imagePath;
	
	NSString *imageName;
	
	if (height == 480)
	{
		imageName = @"LaunchImage-700@2x";
	}
	else if (height == 568)
	{
		imageName = @"LaunchImage-700-568h@2x";
	}
	else if (height == 667)
	{
		imageName = @"LaunchImage-800-667h@2x";
	}
	else if (height == 736)
	{
		imageName = @"LaunchImage-800-Portrait-736h@3x";
	}
	else
	{
		CPLog(@"unknown height");
	}
	
	//CPLog(@"image name: %@", imageName);
	
	imagePath = [[NSBundle mainBundle] pathForResource: imageName ofType: @"png"];
	
	return imagePath;
}

@end
