//
//  VEStationsScrollView.h
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

@protocol VEStationViewDelegate;

@class VEStationView;

@class Station;

@protocol VEStationView;


@interface VEStationsScrollView : UIScrollView

@property (nonatomic, assign) NSUInteger currentStationIndex;

@property (nonatomic, assign, readonly) NSUInteger searchStationIndex;

- (instancetype) initWithStationDelegate: (id <VEStationViewDelegate>) stationViewDelegate isSearching: (BOOL) searching;

- (void) setStations: (NSArray *) stations;

- (__kindof UIView *) stationViewAtIndex: (NSUInteger) index;

- (VEStationView *) stationViewForStation: (Station *) aStation;

@end
