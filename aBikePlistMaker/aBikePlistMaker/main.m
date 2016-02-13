//
//  main.m
//  aBikePlistMaker
//
//  Created by Clément Padovani on 8/29/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

NSString * nameForCityNumber(NSUInteger cityNumber);

CLLocationCoordinate2D coordsForCityNumber(NSUInteger cityNumber);

CLLocationDegrees spanForCityNumber(NSUInteger cityNumber);

NSNumber * appIdForCityNumber(NSUInteger cityNumber);

int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		NSMutableArray *mainArray = [NSMutableArray array];
		
		
		for (NSUInteger i = 0; i < 10; i++)
		{
			NSMutableDictionary *city = [NSMutableDictionary dictionary];
			
			city[@"name"] = nameForCityNumber(i);
			
			CLLocationCoordinate2D coords = coordsForCityNumber(i);
			
			CLLocationDegrees coordsTotal = spanForCityNumber(i);
			
			CLLocationDistance acceptableDistance = coordsTotal * 111000;
			
			NSData *coordsData = [NSData dataWithBytes: &coords length: sizeof(coords)];
			
			city[@"coords"] = coordsData;
			
			city[@"appId"] = appIdForCityNumber(i);
			
			city[@"distance"] = @(acceptableDistance);
			
			[mainArray addObject: city];
		}
				
		NSString *path = @"~/Desktop/aBikeCities.plist";
		
		path = [path stringByExpandingTildeInPath];
		
		[mainArray writeToURL: [NSURL fileURLWithPath: path] atomically: YES];
	}
	return 0;
}

NSString * nameForCityNumber(NSUInteger cityNumber)
{
	switch (cityNumber)
	{
		case 0:	return @"Lyon";
		case 1:	return @"Paris";
		case 2:	return @"Brussels";
		case 3:	return @"Marseille";
		case 4:	return @"Toulouse";
		case 5:	return @"Mulhouse";
		case 6:	return @"Nantes";
		case 7:	return @"Créteil";
		case 8:	return @"Dublin";
		case 9:	return @"Luxembourg";
			
		default:
			return nil;
	}
}

CLLocationCoordinate2D coordsForCityNumber(NSUInteger cityNumber)
{
	switch (cityNumber)
	{
		case 0:	return CLLocationCoordinate2DMake(45.742657821116687, 4.8527870000000206);
		case 1:	return CLLocationCoordinate2DMake(48.873090231884206, 2.3508267521949922);
		case 2:	return CLLocationCoordinate2DMake(50.816703, 4.369955);
		case 3:	return CLLocationCoordinate2DMake(43.260528, 5.377849);
		case 4:	return CLLocationCoordinate2DMake(43.602394, 1.432450);
		case 5:	return CLLocationCoordinate2DMake(47.746809, 7.331784);
		case 6:	return CLLocationCoordinate2DMake(47.217763, -1.552311);
		case 7:	return CLLocationCoordinate2DMake(48.783898, 2.451457);
		case 8:	return CLLocationCoordinate2DMake(53.344546, -6.266745);
		case 9:	return CLLocationCoordinate2DMake(49.611500, 6.127650);
			
		default:
			return CLLocationCoordinate2DMake(0, 0);
	}
}

CLLocationDegrees spanForCityNumber(NSUInteger cityNumber)
{
	switch (cityNumber)
	{
		case 0:	return 0.206465885208476865;
		case 1:	return 0.2504163631815004;
		case 2:	return 0.209625;
		case 3:	return 0.117450;
		case 4:	return 0.090266;
		case 5:	return 0.027193;
		case 6:	return 0.057086;
		case 7:	return 0.029879;
		case 8:	return 0.003023;
		case 9:	return 0.003800;
			
		default:
			return 0;
	}
}

NSNumber * appIdForCityNumber(NSUInteger cityNumber)
{
	switch (cityNumber)
	{
		case 0:	return @(737480360);
		case 1:	return @(882298849);
		case 2:	return @(898838535);
		case 3:	return @(907179797);
		case 4:	return @(907384126);
		case 5:	return @(907384332);
		case 6:	return @(1073604521);
		case 7:	return @(1081759410);
		case 8:	return @(1083001230);
		case 9:	return @(1083005672);
			
		default:
			return nil;
	}
}
