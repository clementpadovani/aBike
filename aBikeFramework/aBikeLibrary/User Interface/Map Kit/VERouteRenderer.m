//
//  VERouteRenderer.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 7/12/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VERouteRenderer.h"

#import "UIColor+MainColor.h"

static const CGFloat kVERouteRendererDirectionsRouteAlpha = .85f;

@implementation VERouteRenderer

- (instancetype) initWithPolyline: (MKPolyline *) polyline
{
	self = [super initWithPolyline: polyline];
	
	if (self)
	{
		[self setStrokeColor: [UIColor ve_mapViewControllerOverlayStrokeColor]];
		
		[self setAlpha: kVERouteRendererDirectionsRouteAlpha];
	}
	
	return self;
}

- (BOOL) canDrawMapRect: (MKMapRect) mapRect zoomScale: (MKZoomScale) zoomScale
{
	return MKMapRectIntersectsRect([[self overlay] boundingMapRect],  mapRect);
}

//- (void) drawMapRect: (MKMapRect) mapRect zoomScale: (MKZoomScale) zoomScale inContext: (CGContextRef) context
//{
//	if (!MKMapRectIntersectsRect([[self overlay] boundingMapRect], mapRect))
//	{		
//		return;
//	}
//	
//	[super drawMapRect: mapRect zoomScale: zoomScale inContext: context];
//}

#ifdef DEBUG

- (id) debugQuickLookObject
{
	UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath: [self path]];
	
	[bezierPath setLineCapStyle: kCGLineCapRound];
	
	[bezierPath setLineJoinStyle: kCGLineJoinRound];
	
	[bezierPath setMiterLimit: 10];
	
	return bezierPath;
}

#endif

@end
