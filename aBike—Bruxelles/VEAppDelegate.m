//
//  VEAppDelegate.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 1/17/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEAppDelegate.h"

@implementation VEAppDelegate


- (id) init
{
	self = [super init];

	if (self)
	{
		[VEConsul sharedConsul];

		[[VEConsul sharedConsul] setDelegate: self];

		[[VEConsul sharedConsul] setup];
	}

	return self;
}

- (NSString *) contractNameForConsul:(VEConsul *)consul
{
	return @"Bruxelles-Capitale";
}

- (NSString *) cityNameForConsul:(VEConsul *)consul
{
	return NSLocalizedString(@"Brussels_name", @"");
}

- (NSString *) cityServiceNameForConsul:(VEConsul *)consul
{
	return @"villo";
}

- (NSString *) cityRegionNameForConsul: (VEConsul *) consul
{
	return NSLocalizedString(@"Brussels", @"");
}

- (UIColor *) mainColorForConsul: (VEConsul *) consul
{
	return [UIColor colorWithRed: (22.f / 255.f) green: (73.f / 255.f) blue: (175.f / 255.f) alpha: 1];
}

- (MKCoordinateRegion) mapRegionForConsul: (VEConsul *) consul
{
	return MKCoordinateRegionMake(CLLocationCoordinate2DMake(50.816703, 4.369955), MKCoordinateSpanMake(0.209625, 0.209625));
}

#if (SCREENSHOTS==1)


- (CLLocation *) locationForScreenshots
{
	return [[CLLocation alloc] initWithLatitude: 50.85 longitude: 4.35];
}

#endif


- (UIWindow *) window
{
	return (UIWindow *) [[VEConsul sharedConsul] window];
}

- (BOOL) application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	return [[VEConsul sharedConsul] applicationWillFinishLaunchingWithOptions: launchOptions];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	return [[VEConsul sharedConsul] applicationDidFinishLaunchingWithOptions: launchOptions];
}

- (BOOL) application: (UIApplication *) application openURL: (NSURL *) url sourceApplication: (NSString *) sourceApplication annotation: (id) annotation
{
	return [[VEConsul sharedConsul] applicationOpenURL: url sourceApplication: sourceApplication annotation: annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[[VEConsul sharedConsul] applicationWillResignActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[[VEConsul sharedConsul] applicationDidBecomeActive];
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
	[[VEConsul sharedConsul] applicationDidEnterBackground];
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
	[[VEConsul sharedConsul] applicationWillReturnToForeground];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[VEConsul sharedConsul] applicationWillTerminate];
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[VEConsul sharedConsul] applicationDidReceiveMemoryWarning];
}

#ifdef DEBUG

- (void) motionBegan: (UIEventSubtype) motion withEvent: (UIEvent *) event
{
	if (motion == UIEventSubtypeMotionShake)
	{
		[[VEConsul sharedConsul] motionShake];

		return;
	}

	[super motionBegan: motion withEvent: event];
}

#endif


@end
