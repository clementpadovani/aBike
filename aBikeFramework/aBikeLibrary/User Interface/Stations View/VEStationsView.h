//
//  VEStationsView.h
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/28/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

@class Station;

@class VEStationView;

@protocol VEStationViewDelegate;

@protocol VEStationsViewDelegate <NSObject>

- (void) userDidScrollToNewStationForIndex: (NSUInteger) index;

@end

@interface VEStationsView : UIView

@property (nonatomic, weak) id <VEStationsViewDelegate> delegate;

@property (nonatomic, assign) NSUInteger currentStationIndex;

- (instancetype) initWithStationDelegate: (id <VEStationViewDelegate>) stationViewDelegate isSearching: (BOOL) searching;

- (void) setStations: (NSArray *) stations;

- (VEStationView *) stationViewForStation: (Station *) aStation;

@end
