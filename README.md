#aBike

Hey, aBike is a collection of apps powered by JCDecaux’s cyclocity [API](https://developer.jcdecaux.com).

aBike’s “raison d’être” is to be fast and efficient—it displays the 5 closest stations next to you, configurable to 3 or 7.

##Add a new city

To add a new city create a new target as usual. You can copy paste the `Info.plist` from another city, same for the `VEAppDelegate` file along with the `InfoPlist.strings`. In there you must change the following methods:

- `- (NSString *) contractNameForConsul:(VEConsul *)consul`
- `- (NSString *) cityNameForConsul:(VEConsul *)consul`
- `- (NSString *) cityServiceNameForConsul:(VEConsul *)consul`
- `- (NSString *) cityRegionNameForConsul: (VEConsul *) consul`
- `- (UIColor *) mainColorForConsul: (VEConsul *) consul`

You can ignore the `- (MKCoordinateRegion) mapRegionForConsul: (VEConsul *) consul` for now, to retrieve its value set the value of `enableNumberOfStations` to `0`; once you run the app it will print out the map region of the city based on all of the bike stations (don’t forget to set it back to `1` after).

Then set `- (CLLocation *) locationForScreenshots` to a position inside of the current city (usually a well-known area) to be set as the faked-location for the automated screenshots (via [`snapshot`](https://github.com/fastlane/snapshot)).

Create a new `UI Test` target with **Swift** as its language. Delete the generated test `swift` file. Locate the following files: `SnapshotHelper.swift` & `aBike_LyonUITests.swift`, make them part of your number target using the inspector.

You can duplicate an existing folder in the `Deliver` directory and edit the `Snapfile` file to make it work with your new target.

Run `snapshot run` inside the directory (you might want to clean your simulators first by using `snapshot reset_simulators`).
