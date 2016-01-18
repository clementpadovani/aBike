//
//  VEStationAnnotationView.h
//  abike—Lyon
//
//  Created by Clément Padovani on 3/12/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

@class VEStationAnnotationDirectionsAccessoryView;
@class VEStationAnnotationShareAccessoryView;
@class VEStationView;

@interface VEStationAnnotationView : MKAnnotationView

@property (nonatomic, weak, readonly) VEStationAnnotationDirectionsAccessoryView *directionsAccessoryView;

@property (nonatomic, weak, readonly) VEStationAnnotationShareAccessoryView *sharingAccessoryView;

@property (nonatomic, getter = isTableViewSelected) BOOL tableViewSelected;

- (instancetype) initWithAnnotation: (id <MKAnnotation>) annotation reuseIdentifier: (NSString *) reuseIdentifier withStationView: (VEStationView *) stationView;

- (void) setAnnotation: (id <MKAnnotation>) annotation withStationView: (VEStationView *) stationView;

- (void) setTableViewSelected: (BOOL) tableViewSelected animated: (BOOL) animated;

@end
