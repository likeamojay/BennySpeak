//
//  BennySpeakUITestsLaunchTests.swift
//  BennySpeakUITests
//
//  Created by James Lane on 10/13/24.
//

import XCTest

final class BennySpeakUITestsLaunchTests: XCTestCase {
    
    private let iterations = 10


    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testPerformanceRuns() {
        let app = XCUIApplication()

        for i in 1...iterations {
            app.launchArguments = ["-isPerformanceTest"]
            if i == iterations {
                app.launchArguments.append("-isFinalPerformanceRun")
            }

            app.launch()

            XCTAssertTrue(
                app.textFields["search_text_field"].waitForExistence(timeout: 5.0),
                "search_text_field did not appear in time"
            )
            app.terminate()
            sleep(1)
        }
    }
}
