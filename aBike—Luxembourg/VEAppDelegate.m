//
//  VEAppDelegate.m
//  aBike—Nantes
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
	return @"luxembourg";
}

- (NSString *) cityNameForConsul:(VEConsul *)consul
{
	return @"Luxembourg";
}

- (NSString *) cityServiceNameForConsul:(VEConsul *)consul
{
	return @"Veloh";
}

- (NSString *) cityRegionNameForConsul: (VEConsul *) consul
{
	return NSLocalizedString(@"Luxembourg", @"");
}

- (UIColor *) mainColorForConsul: (VEConsul *) consul
{
	return [UIColor colorWithRed: (39.f / 255.f) green: (82.f / 255.f) blue: (213.f / 255.f) alpha: 1];
}

- (MKCoordinateRegion) mapRegionForConsul: (VEConsul *) consul
{
	return MKCoordinateRegionMake(CLLocationCoordinate2DMake(49.611500, 6.127650), MKCoordinateSpanMake(0.003800, 0.003800));
}

#if (SCREENSHOTS==1)


- (CLLocation *) locationForScreenshots
{
	return [[CLLocation alloc] initWithLatitude: 49.612295 longitude: 6.125882];
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
