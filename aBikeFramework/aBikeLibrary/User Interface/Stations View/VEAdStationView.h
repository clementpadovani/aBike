//
//  VEAdStationView.h
//  aBikeLibrary
//
//  Created by Clément Padovani on 9/11/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

@interface VEAdStationView : UIView

+ (VEAdStationView *) sharedAdStationView;

+ (void) tearDownAdStationView;

- (void) canLoad;

@end
