//
//  VEMapViewController.h
//  Velo'v
//
//  Created by Clément Padovani on 7/17/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

#import "VELocationManager.h"
#import "VEMapContainerView.h"

static NSString * const kVEMapViewControllerViewGoToBackgroundNotification = @"kVEMapViewControllerViewGoToBackgroundNotification";

//static const NSUInteger kNumberOfStations = 5;

@interface VEMapViewController : UIViewController <MKMapViewDelegate, VELocationManagerDelegate>

- (instancetype) initForSearchResult: (MKMapItem *) mapItem;

- (void) loadMapData;

- (void) updateAds;

@end
