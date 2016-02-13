//
//  VEAppDelegate.m
//  aBike—Mulhouse
//
//  Created by Clément Padovani on 8/8/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
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
	return @"mulhouse";
}

- (NSString *) cityNameForConsul:(VEConsul *)consul
{
	return @"Mulhouse";
}

- (NSString *) cityServiceNameForConsul:(VEConsul *)consul
{
	return @"VéloCité";
}

- (NSString *) cityRegionNameForConsul: (VEConsul *) consul
{
	return NSLocalizedString(@"Mulhouse", @"");
}

- (UIColor *) mainColorForConsul: (VEConsul *) consul
{
	return [UIColor colorWithRed: (227.f / 255.f) green: (.0f / 255.f) blue: (28.f / 255.f) alpha: 1];
}

- (MKCoordinateRegion) mapRegionForConsul: (VEConsul *) consul
{
	return MKCoordinateRegionMake(CLLocationCoordinate2DMake(47.746809, 7.331784), MKCoordinateSpanMake(0.027193, 0.027193));
}

#if (SCREENSHOTS==1)


- (CLLocation *) locationForScreenshots
{
	return [[CLLocation alloc] initWithLatitude: 47.751416 longitude: 7.333864];
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

#if DEBUG == 1

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
