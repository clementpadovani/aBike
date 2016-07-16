//
//  VEStationsScrollView.h
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

@protocol VEStationViewDelegate;

@class VEStationView;

@class VEStation;

@protocol VEStationView;


@interface VEStationsScrollView : UIScrollView

@property (nonatomic, assign) NSUInteger currentStationIndex;

@property (nonatomic, assign, readonly) NSUInteger searchStationIndex;

#if kEnableTimerStationView

@property (nonatomic, assign, readonly) NSUInteger timerStationIndex;

#endif

- (instancetype) initWithStationDelegate: (id <VEStationViewDelegate>) stationViewDelegate isSearching: (BOOL) searching;

- (void) setStations: (NSArray <VEStation *> *) stations;

- (__kindof UIView *) stationViewAtIndex: (NSUInteger) index;

- (VEStationView *) stationViewForStation: (VEStation *) aStation;

@end
