//
//  VEStationAnnotationView.m
//  abike—Lyon
//
//  Created by Clément Padovani on 3/12/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEStationAnnotationView.h"

#import "VEStationAnnotationDirectionsAccessoryView.h"

#import "VEStationAnnotationShareAccessoryView.h"

#import "VEStationView.h"

#import "UIImage+VEImageAdditions.h"

#import "VEConsul.h"

static const NSTimeInterval kVEStationAnnotationViewAnimationDuration = .3;

static const CGPoint kVEStationAnnotationViewIdleCenterOffSet = { 0, -15 };

static const CGPoint kVEStationAnnotationViewSelectedCenterOffSet = { 0, -24 };

static const CGPoint kVEStationAnnotationViewCalloutOffset = { 0, -1.5 };

@interface VEStationAnnotationView ()

@property (nonatomic) BOOL hasMotionEffects;

@property (nonatomic, weak, readwrite) VEStationAnnotationDirectionsAccessoryView *directionsAccessoryView;

@property (nonatomic, weak, readwrite) VEStationAnnotationShareAccessoryView *sharingAccessoryView;

@end

@implementation VEStationAnnotationView

+ (UIImage *) ve_tintedImage
{
	static UIImage *_tintedImage = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{

		UIColor *tintColor = [[VEConsul sharedConsul] mainColor];

		_tintedImage = [self ve_doCreateTintedImageForTintColor: tintColor];
	});

	return _tintedImage;
}

+ (UIImage *) ve_doCreateTintedImageForTintColor: (UIColor * __nonnull) tintColor
{
	UIImage *image = [UIImage ve_imageNamed: @"selectedPin"];

	UIGraphicsBeginImageContextWithOptions([image size], NO, [image scale]);

	CGRect rect = CGRectZero;

	rect.size = [image size];

	[tintColor set];

	UIRectFill(rect);

	[image drawInRect: rect blendMode: kCGBlendModeDestinationIn alpha: 1];

	image = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	UIGraphicsBeginImageContextWithOptions([image size], NO, [image scale]);

	UIColor *whiteColor = [UIColor whiteColor];

	CGRect bikeRect = CGRectMake(4, 6, 26, 16);

	[whiteColor setFill];

	UIRectFill(bikeRect);

	[image drawInRect: rect];

	image = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return image;
}

- (instancetype) initWithAnnotation: (id <MKAnnotation>) annotation reuseIdentifier: (NSString *) reuseIdentifier withStationView: (VEStationView *) stationView
{
	self = [super initWithAnnotation: annotation reuseIdentifier: reuseIdentifier];
	
	if (self)
	{
		UIImage *image = [UIImage ve_imageNamed: @"pin"];
		
		[self setCanShowCallout: YES];
		
		[self setOpaque: NO];
		
		[self setImage: image];
		
		[self setCalloutOffset: kVEStationAnnotationViewCalloutOffset];
		
		VEStationAnnotationDirectionsAccessoryView *directionsAccessoryView = [VEStationAnnotationDirectionsAccessoryView accessoryView];
	
		[directionsAccessoryView setStationView: stationView];
		
		#if kEnableSharing
		
			VEStationAnnotationShareAccessoryView *sharingAccessoryView = [VEStationAnnotationShareAccessoryView accessoryView];
		
		#endif
		
		if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionLeftToRight)
		{
			[self setLeftCalloutAccessoryView: directionsAccessoryView];
			
			#if kEnableSharing
			
				[self setRightCalloutAccessoryView: sharingAccessoryView];
			
			#endif
		}
		else
		{
			[self setRightCalloutAccessoryView: directionsAccessoryView];
			
			#if kEnableSharing
			
				[self setLeftCalloutAccessoryView: sharingAccessoryView];
			
			#endif
		}
		
		_directionsAccessoryView = directionsAccessoryView;
		
		#if kEnableSharing

			_sharingAccessoryView = sharingAccessoryView;
		
		#endif
		
		[self setCenterOffset: kVEStationAnnotationViewIdleCenterOffSet];
	}
	
	return self;
}

- (void) prepareForReuse
{
	[super prepareForReuse];
	
	[self setCenterOffset: kVEStationAnnotationViewIdleCenterOffSet];
}

- (void) setAnnotation: (id <MKAnnotation>) annotation withStationView: (VEStationView *) stationView
{
	[self setAnnotation: annotation];
	
	[[self directionsAccessoryView] setStationView: stationView];
}

//- (void) setSelected: (BOOL) selected
//{
//	[super setSelected: selected];
//	
//	[[self sharingAccessoryView] setEnabled: YES];
//}

//- (void) setSelected: (BOOL) selected animated: (BOOL) animated
//{	
//	[self setTableViewSelected: selected animated: animated];
//	
//	[super setSelected: selected animated: animated];
//}

- (void) setTableViewSelected: (BOOL) tableViewSelected animated: (BOOL) animated
{
	BOOL doWithAnimations = animated;
	
	if ([self isTableViewSelected] == tableViewSelected)
	{
		doWithAnimations = NO;
	}

	_tableViewSelected = tableViewSelected;
	
	void (^animations)(void) = ^{
		
		UIImage *selectedPinImage = [[self class] ve_tintedImage];

		UIImage *pinImage = [UIImage ve_imageNamed: @"pin"];

		UIImage *image = tableViewSelected ? selectedPinImage : pinImage;
		
		CGPoint centerOffset = tableViewSelected ? kVEStationAnnotationViewSelectedCenterOffSet : kVEStationAnnotationViewIdleCenterOffSet;
		
		[self setImage: image];
		
		[self setCenterOffset: centerOffset];
	};
	
	[UIView animateWithDuration: doWithAnimations ? kVEStationAnnotationViewAnimationDuration : 0
				  animations: animations];	
}

- (void) setTableViewSelected: (BOOL) tableViewSelected
{
	[self setTableViewSelected: tableViewSelected animated: NO];
}

@end
