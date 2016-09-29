//
//  VERouteRenderer.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 7/12/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VERouteRenderer.h"
#import "UIColor+MainColor.h"
#import "MKPolyline+VETransitionAdditions.h"

static const CGFloat kVERouteRendererDirectionsRouteAlpha = .85f;

@implementation VERouteRenderer

- (instancetype) initWithPolyline: (MKPolyline *) polyline
{
	self = [super initWithPolyline: polyline];
	
	if (self)
	{
		[self setStrokeColor: [UIColor ve_mapViewControllerOverlayStrokeColor]];
		
		[self setAlpha: kVERouteRendererDirectionsRouteAlpha];
        
        [polyline addObserver: self
                   forKeyPath: NSStringFromSelector(@selector(ve_transitionProgress))
                      options: NSKeyValueObservingOptionNew
                      context: NULL];
	}
	
	return self;
}

- (void) dealloc
{
    [[self polyline] removeObserver: self
                         forKeyPath: NSStringFromSelector(@selector(ve_transitionProgress))];
}

- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary <NSKeyValueChangeKey, id> *) change context: (void *) context
{
    if ([keyPath isEqualToString: NSStringFromSelector(@selector(ve_transitionProgress))])
    {
        if ([[self polyline] ve_transitionProgress] > kVERouteRendererDirectionsRouteAlpha)
            [self setAlpha: kVERouteRendererDirectionsRouteAlpha];
        else
            [self setAlpha: [[self polyline] ve_transitionProgress]];
    }
    else
    {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
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

#if (DEBUG == 1)

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
