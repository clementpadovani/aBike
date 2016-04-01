//
//  NSBundle+VELibrary.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/31/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "NSBundle+VELibrary.h"

@implementation NSBundle (VELibrary)

+ (NSBundle *) ve_libraryResources
{
	if (![NSThread isMainThread])
		CPLog(@"not main thread");
	
	static NSBundle *_libraryResources = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{

		#if TARGET_OS_TV

		_libraryResources = [NSBundle bundleWithIdentifier: @"com.clement.padovani.aBikeTVFramework"];

		#else

		_libraryResources = [NSBundle bundleWithIdentifier: @"com.clement.padovani.aBikeFramework"];

		#endif

		if (!_libraryResources)
		{
			CPLog(@"nil bundle");
			
//			libraryResourcesURL = [[NSBundle mainBundle] URLForResource: @"app" withExtension: @"bundle"];
//			
//			_libraryResources = [NSBundle bundleWithURL: libraryResourcesURL];
		}
		
	});
	
	
	
	return _libraryResources;
}

+ (NSURL *) ve_fileURLForCities
{
	return (NSURL *__nonnull) [[NSBundle ve_libraryResources] URLForResource: @"aBikeCities" withExtension: @"plist"];
}

+ (NSString *) ve_adRemoverProductIdentifier
{
	NSString *adRemover;
	
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	
	adRemover = [bundleIdentifier stringByAppendingString: @".ads"];
	
	return adRemover;
}

@end
