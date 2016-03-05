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

##Thanks
Thanks [@MathieuWhite](https://twitter.com/MathieuWhite) ([GitHub](https://github.com/MathieuWhite))

#License

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">aBike</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="https://github.com/ClementPadovani/aBike" property="cc:attributionName" rel="cc:attributionURL">Clément PADOVANI</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.<br />Based on a work at <a xmlns:dct="http://purl.org/dc/terms/" href="https://github.com/ClementPadovani/aBike" rel="dct:source">https://github.com/ClementPadovani/aBike</a>.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/ClementPadovani/abike/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

