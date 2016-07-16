//
//  VEStationView.h
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/29/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

@class VEStation;

@class MKRoute;

NS_ASSUME_NONNULL_BEGIN

static NSString * const kVEStationViewDidStartLoadingDirectionsNotification = @"kVEStationViewDidStartLoadingDirectionsNotification";

static NSString * const kVEStationViewDidLoadDirectionsNotification = @"kVEStationViewDidLoadDirectionsNotification";

@protocol VEStationViewDelegate <NSObject>

@required

- (void) loadDirectionsInfoWithRoute: (MKRoute *) directionsRoute forStation: (VEStation *) aStation;

@end

@interface VEStationView : UIView

@property (nonatomic, weak) VEStation *currentStation;

@property (nonatomic, assign, getter = isShowingDirections) BOOL showingDirections;

@property (nonatomic, assign, readonly) BOOL loadedDirections;

@property (nonatomic, assign, getter = areDirectionsEnabled) BOOL directionsEnabled;

@property (nonatomic, weak) id <VEStationViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
