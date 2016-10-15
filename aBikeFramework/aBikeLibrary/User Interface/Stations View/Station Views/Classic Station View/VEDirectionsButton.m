//
//  VEDirectionsButton.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 10/15/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

#import "VEDirectionsButton.h"

static const UIEdgeInsets kVEDirectionsButtonInsets = {14, 16, 14, 16};

@interface VEDirectionsButton () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <UIGestureRecognizerDelegate> originalDelegate;

@end

@implementation VEDirectionsButton

+ (instancetype) directionsButton
{
    VEDirectionsButton *directionsButton = [self buttonWithType: UIButtonTypeCustom];
    
    [directionsButton setEnabled: NO];
    
    [directionsButton setMultipleTouchEnabled: YES];
    
    UIImage *directionsImage = [UIImage imageNamed: @"directionsIcon"
                                          inBundle: [NSBundle ve_libraryResources]
                     compatibleWithTraitCollection: nil];
    
    UIImage *disabledDirectionsImage = [UIImage imageNamed: @"noDirectionsIcon"
                                                  inBundle: [NSBundle ve_libraryResources]
                             compatibleWithTraitCollection: nil];
    
    UIImage *templateDirectionsImage = [directionsImage imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    
    
#if (SCREENSHOTS==1)
    
    [directionsButton setAccessibilityIdentifier: @"directionsIcon"];
    
#endif
    
    [directionsButton setImage: disabledDirectionsImage forState: UIControlStateDisabled];
    
    [directionsButton setImage: templateDirectionsImage forState: UIControlStateNormal];
    
    [directionsButton setImage: directionsImage forState: UIControlStateSelected];
    
    [directionsButton setContentEdgeInsets: kVEDirectionsButtonInsets];

    
    return directionsButton;
}

- (void) addGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer
{
    [self setOriginalDelegate: [gestureRecognizer delegate]];
    
    [gestureRecognizer setDelegate: self];
    
    [super addGestureRecognizer: gestureRecognizer];
}

- (BOOL) gestureRecognizer: (UIGestureRecognizer *) gestureRecognizer shouldReceiveTouch: (UITouch *) touch
{
    BOOL originalResponse = [[self originalDelegate] gestureRecognizer: gestureRecognizer shouldReceiveTouch: touch];
    
    CPLog(@"%@ = %@", NSStringFromSelector(_cmd), originalResponse ? @"YES" : @"NO");
    
    return originalResponse;
}

- (BOOL) gestureRecognizer: (UIGestureRecognizer *) gestureRecognizer shouldReceivePress: (UIPress *) press
{
    BOOL originalResponse = [[self originalDelegate] gestureRecognizer: gestureRecognizer shouldReceivePress: press];
    
    CPLog(@"%@ = %@", NSStringFromSelector(_cmd), originalResponse ? @"YES" : @"NO");
    
    return originalResponse;
}

//- (void) sendAction: (SEL) action to: (id) target forEvent: (UIEvent *) event
//{
//    CPLog(@"send %@ to %@ for %@", NSStringFromSelector(action), target, event);
//    
//    [super sendAction: action to: target forEvent: event];
//}

- (void) cancelTrackingWithEvent: (UIEvent *) event
{
    CPLog(@"%@ = %@", NSStringFromSelector(_cmd), event);
    
    [super cancelTrackingWithEvent: event];
}

//- (BOOL) continueTrackingWithTouch: (UITouch *) touch withEvent: (UIEvent *) event
//{
//    BOOL superContinues = [super continueTrackingWithTouch: touch withEvent: event];
//    
//    CPLog(@"%@ %@ = %@", NSStringFromSelector(_cmd), event, superContinues ? @"YES" : @"NO");
//    
//    return superContinues;
//}
//
//- (void) endTrackingWithTouch: (UITouch *) touch withEvent: (UIEvent *) event
//{
//    CPLog(@"%@ = %@ %@", NSStringFromSelector(_cmd), touch, event);
//    
//    [super endTrackingWithTouch: touch withEvent: event];
//}

- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer *) gestureRecognizer
{
    BOOL gestureRecognizerShouldBegin = [super gestureRecognizerShouldBegin: gestureRecognizer];
    
    CPLog(@"%@ = %@", NSStringFromSelector(_cmd), gestureRecognizerShouldBegin ? @"YES" : @"NO");
    
    return gestureRecognizerShouldBegin;
}

@end
