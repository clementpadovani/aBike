//
//  VEStationView.h
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/29/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

static NSString * const kVEStationViewDidStartLoadingDirectionsNotification = @"kVEStationViewDidStartLoadingDirectionsNotification";

static NSString * const kVEStationViewDidLoadDirectionsNotification = @"kVEStationViewDidLoadDirectionsNotification";

@class Station;

@protocol VEStationViewDelegate <NSObject>

- (void) loadDirectionsInfoWithRoute: (MKRoute *) directionsRoute forStation: (Station *) aStation;

@end

@interface VEStationView : UIView

@property (nonatomic, weak) Station *currentStation;

@property (nonatomic, getter = isShowingDirections) BOOL showingDirections;

@property (nonatomic, readonly) BOOL loadedDirections;

@property (nonatomic, weak) id <VEStationViewDelegate> delegate;

@end
