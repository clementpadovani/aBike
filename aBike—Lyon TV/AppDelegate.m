//
//  AppDelegate.m
//  aBike—Lyon TV
//
//  Created by Clément Padovani on 1/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

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
	return @"lyon";
}

- (NSString *) cityNameForConsul:(VEConsul *)consul
{
	return @"Lyon";
}

- (NSString *) cityServiceNameForConsul:(VEConsul *)consul
{
	return @"Vélo’v";
}

- (NSString *) cityRegionNameForConsul: (VEConsul *) consul
{
	return NSLocalizedString(@"Lyon", @"");
}

- (UIColor *) mainColorForConsul: (VEConsul *) consul
{
	return [UIColor colorWithRed: (252.f / 255.f) green: (62.f / 255.f) blue: (57.f / 255.f) alpha: 1];
}

- (MKCoordinateRegion) mapRegionForConsul: (VEConsul *) consul
{
	return MKCoordinateRegionMake(CLLocationCoordinate2DMake(45.742657821116687, 4.8527870000000206), MKCoordinateSpanMake(0.15759265270632028, 0.25533911771063345));
}

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
	[[UIScreen mainScreen] setOverscanCompensation: UIScreenOverscanCompensationInsetBounds];

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
