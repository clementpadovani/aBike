//
//  aBike_LyonUITests.swift
//  aBike—LyonUITests
//
//  Created by Clément Padovani on 1/15/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

import XCTest

class aBike_LyonUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
	let app = XCUIApplication()
	setupSnapshot(app)
	app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testsScreenshots()
	{
		let app = XCUIApplication()

		addUIInterruptionMonitorWithDescription("Location Alert") { (alert) -> Bool in
			alert.buttons["Allow"].tap()

			app.tap()

//			snapshot("0allStations1", waitForLoadingIndicator: false)

			return true
		}

		app.tap()

		sleep(1)

		if (app.alerts.element.collectionViews.buttons["Allow"].exists)
		{
			app.alerts.element.collectionViews.buttons["Allow"].tap()
		}

		sleep(3)

		snapshot("1allStations", waitForLoadingIndicator: false)



		let scrollViewsQuery = app.scrollViews.matchingIdentifier("Stations Scroll View")

		scrollViewsQuery.element.swipeLeft()

		scrollViewsQuery.element.swipeLeft()

		scrollViewsQuery.element.swipeLeft()

		scrollViewsQuery.element.swipeLeft()

		app.scrollViews.otherElements.buttons["directionsIcon"].tap()

		sleep(3)

		snapshot("2focusedStation")
	}
    
}
