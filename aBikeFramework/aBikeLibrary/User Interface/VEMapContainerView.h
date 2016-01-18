//
//  VEMapContainerView.h
//  Velo'v
//
//  Created by Clément Padovani on 11/3/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "VEMapViewBlurImageView.h"

@interface VEMapContainerView : UIView

@property (weak, nonatomic, readonly) MKMapView *mapView;

@property (weak, nonatomic, readonly) VEMapViewBlurImageView *blurImageView;

- (instancetype) initWithMapViewDelegate: (id <MKMapViewDelegate>) mapViewDelegate;

@end
