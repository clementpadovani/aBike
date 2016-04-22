//
//  UIColor+MainColor.m
//  Velo'v
//
//  Created by Clément Padovani on 11/20/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "UIColor+MainColor.h"

#import "VEConsul.h"

#define kColorsCacheName @"com.clement.padovani.aBike.colors-cache"

//#define RGB(r, g, b, a) [UIColor colorWithRed: (r/255.f) green: (g/255.f) blue: (b/255.f) alpha: (float) a]

#define RGB(r, g, b, a) \
[UIColor colorWithRed: (r##.0f/255.0f)   \
			 green: (g##.0f/255.0f)   \
			  blue: (b##.0f/255.0f)   \
			 alpha: (a)];


//#if CGFLOAT_IS_DOUBLE
//
//#define RGB(r, g, b, a) [UIColor colorWithRed: ((double) r/255.) green: ((double) g/255.) blue: ((double) b/255.) alpha: (double) a]
//
//#else
//
//#define RGB(r, g, b, a) [UIColor colorWithRed: ((float) r/255.f) green: ((float) g/255.f) blue: ((float) b/255.f) alpha: (float) a]
//
//#endif

static NSCache *_colorsCache;

@interface UIColor (Notifications)

+ (void) ve_receivedMemoryWarning: (NSNotification *) notification;

@end

@implementation UIColor (Notifications)

+ (void) ve_receivedMemoryWarning: (NSNotification *) notification
{
	//CPLog(@"received mem warning");
	
	[_colorsCache removeAllObjects];
	
	//CPLog(@"removed all objects");
}

@end

#pragma clang diagnostic push

#pragma clang diagnostic ignored "-Wunreachable-code"

@implementation UIColor (VEMainColor)

+ (void) ve_setupColorsCache
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(ve_receivedMemoryWarning:) name: UIApplicationDidReceiveMemoryWarningNotification object: nil];
		
		_colorsCache = [[NSCache alloc] init];
		
		[_colorsCache setName: kColorsCacheName];
		
	});
}

+ (void) ve_stripColorsCache
{
	CPLog(@"will strip colors cache");
	
	[[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidReceiveMemoryWarningNotification object: nil];
	
	//[_colorsCache removeAllObjects];
	
	_colorsCache = nil;
}

+ (UIColor *) ve_mainColor
{
	NSString *colorString = NSStringFromSelector(_cmd);
	
	UIColor *color = [_colorsCache objectForKey: colorString];
	
	if (color)
		return color;
	
	color = [[VEConsul sharedConsul] mainColor];
	
	[_colorsCache setObject: color forKey: colorString];
	
	return color;
}

+ (UIColor *) ve_mainBackgroundColor
{
	NSString *colorString = NSStringFromSelector(_cmd);
	
	UIColor *color = [_colorsCache objectForKey: colorString];
	
	if (color)
		return color;
	
	color = [UIColor blackColor];
	
	[_colorsCache setObject: color forKey: colorString];
	
	return color;
}

+ (UIColor *) ve_gradientStartColor
{
	NSString *colorString = NSStringFromSelector(_cmd);
	
	UIColor *color = [_colorsCache objectForKey: colorString];
	
	if (color)
		return color;
	
	color = RGB(255, 255, 255, .9f);
	
	//color = [UIColor purpleColor];
	
	[_colorsCache setObject: color forKey: colorString];
	
	return color;
}

+ (UIColor *) ve_gradientEndColor
{
	NSString *colorString = NSStringFromSelector(_cmd);
	
	UIColor *color = [_colorsCache objectForKey: colorString];
	
	if (color)
		return color;
	
	//color = [UIColor purpleColor];
	
	color = RGB(247, 247, 248, .9f);
	
	[_colorsCache setObject: color forKey: colorString];
	
	return color;
}

+ (UIColor *) ve_shadowColor
{
	NSString *colorString = NSStringFromSelector(_cmd);
	
	UIColor *color = [_colorsCache objectForKey: colorString];
	
	if (color)
		return color;
	
	color = RGB(0, 0, 0, .3f);
	
	[_colorsCache setObject: color forKey: colorString];
	
	return color;
}

+ (UIColor *) ve_pagerInactiveColor
{
	NSString *colorString = NSStringFromSelector(_cmd);
	
	UIColor *color = [_colorsCache objectForKey: colorString];
	
	if (color)
		return color;
	
	color = RGB(138, 138, 138, 1);
	
	[_colorsCache setObject: color forKey: colorString];
	
	return color;
}

+ (UIColor *) ve_stationNumberTextColor
{
	NSString *colorString = NSStringFromSelector(_cmd);
	
	UIColor *color = [_colorsCache objectForKey: colorString];
	
	if (color)
		return color;
	
	color = RGB(138, 138, 138, 1);
	
	[_colorsCache setObject: color forKey: colorString];
	
	return color;
}

+ (UIColor *) ve_horizontalSeperatorColor
{
	NSString *colorString = NSStringFromSelector(_cmd);
	
	UIColor *color = [_colorsCache objectForKey: colorString];
	
	if (color)
		return color;
	
	color = RGB(200, 199, 204, 1);
	
	[_colorsCache setObject: color forKey: colorString];
	
	return color;
}

+ (UIColor *) ve_blurTintColor
{
	NSString *colorString = NSStringFromSelector(_cmd);
	
	UIColor *color = [_colorsCache objectForKey: colorString];
	
	if (color)
		return color;
	
	color = [UIColor colorWithWhite: 1.f alpha: .75f];
	
	[_colorsCache setObject: color forKey: colorString];
	
	return color;
}

+ (UIColor *) ve_mapViewControllerBackgroundColor
{
	NSString *colorString = NSStringFromSelector(_cmd);
	
	UIColor *color = [_colorsCache objectForKey: colorString];

	if (color)
		return color;
	
	color = [UIColor whiteColor];
	
	[_colorsCache setObject: color forKey: colorString];
	
	return color;
}

+ (UIColor *) ve_mapViewControllerOverlayStrokeColor
{
	NSString *colorString = NSStringFromSelector(_cmd);
	
	UIColor *color = [_colorsCache objectForKey: colorString];
	
	if (color)
		return color;
	
	color = [UIColor ve_mainColor];
	
	[_colorsCache setObject: color forKey: colorString];
	
	return color;
}

#pragma clang diagnostic pop

@end
