//
//  VEGeometry.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 7/16/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

typedef struct {
    CLLocationDegrees minLat;
    CLLocationDegrees minLon;
    CLLocationDegrees maxLat;
    CLLocationDegrees maxLon;
} VECityRect;

extern const VECityRect VECityRectEmpty;

extern BOOL VECityRectIsEqualToCityRect(VECityRect const aCityRect, VECityRect const anotherCityRect);

extern BOOL VECityRectIsValid(VECityRect const aCityRect);

extern BOOL VECityRectIsEmpty(VECityRect const aCityRect);

extern BOOL VECityRectContainsLocationCoordinates(VECityRect const aCityRect, CLLocationCoordinate2D const locationCoordinates);

extern VECityRect VECityRectMakeLarger(VECityRect aCityRect);
