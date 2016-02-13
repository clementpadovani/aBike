//
//  VEConnectionManager.m
//  Velo'v
//
//  Created by Clément Padovani on 10/24/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

@import Reachability;

#import "VEConnectionManager.h"

#import "VEConsul.h"


static NSString * const kVEConnectionManagerReachabilityHost = @"www.apple.com";

@interface VEConnectionManager ()

@property (strong, nonatomic) Reachability *reacher;

@property (nonatomic, readwrite, getter = isReachable) BOOL reachable;

@end

static VEConnectionManager *_sharedConnectionManager = nil;

@implementation VEConnectionManager

+ (VEConnectionManager *) sharedConnectionManger
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedConnectionManager = [[VEConnectionManager alloc] init];
	});
	
	return _sharedConnectionManager;
}

+ (void) tearDownConnectionManager
{
	_sharedConnectionManager = nil;
}

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		_reachable = YES;
		
		Reachability *reacher = [Reachability reachabilityWithHostname: kVEConnectionManagerReachabilityHost];
		
		//CPLog(@"init");
		
		__weak VEConnectionManager *weakSelf = self;
		
		[reacher setReachableBlock: ^(Reachability *aReacher) {
			
			//CPLog(@"isReachable");
			
			[weakSelf setReachable: YES];
			
		}];
		
		[reacher setUnreachableBlock: ^(Reachability *aReacher) {
			
			//CPLog(@"isUnreachable");
			
			[weakSelf setReachable: NO];
			
		}];
		
		_reacher = reacher;
		
		[_reacher startNotifier];
		
		//[[self reacher] startNotifier];
		

		//CPLog(@"done init");
	}
	
	return self;
}

- (void) setReachable: (BOOL) reachable
{
	@synchronized(self)
	{
		
		_reachable = reachable;
		
		CPLog(@"reachable: %@", reachable ? @"YES" : @"NO");

		if (![self canCallBack])
			return;
		
		if (reachable)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
	
				[[VEConsul sharedConsul] reachable];
				
				//[[VEConsul sharedConsul] loadData];
				
				
			});
		}
		else
		{
			
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				[[VEConsul sharedConsul] unReachable];
				
			});
		}
	}
}

- (void) setCanCallBack: (BOOL) canCallBack
{	
	_canCallBack = canCallBack;
	
	__weak VEConnectionManager *weakSelf = self;
	
	BOOL isReachable = [self isReachable];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		[weakSelf setReachable: isReachable];
		
	});
}

- (void) dealloc
{
	[_reacher stopNotifier];

	_reacher = nil;
}

@end
