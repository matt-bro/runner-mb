//MIT License
//
//Copyright (c) 2020 Matthias Brodalka
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import XCTest
import CoreLocation
@testable import runner_mb

class runner_mbTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let locations:[(CLLocation, Date)] = [
                    (CLLocation(latitude:50.110924, longitude:8.682127), Date()),
                   (CLLocation(latitude:50.111211, longitude:8.682976), Date())
        ]

        let mappedLocations:[(CLLocationCoordinate2D, Date)] = locations.map({($0.0.coordinate, Date())})
        Database.shared.saveRun(distance: 10000, pace: 3.0, locations: mappedLocations, image: nil)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPace() {
        let runModel = RunModel()

        var distanceInMeters = Measurement(value: 1000, unit: UnitLength.meters)
        var timeInSeconds = 360

        var formattedPace = runModel.pace(distance: distanceInMeters, seconds: timeInSeconds, outputUnit: .minutesPerKilometer)

        XCTAssertTrue(formattedPace.value == 6.0)

        distanceInMeters = Measurement(value: 3600, unit: UnitLength.meters)
        timeInSeconds = 459

        formattedPace = runModel.pace(distance: distanceInMeters, seconds: timeInSeconds, outputUnit: .minutesPerKilometer)

        print(formattedPace)

        let totalSeconds = lrint(formattedPace.value*60)
        //let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        print(String(format: "%02d:%02d \(formattedPace.unit.symbol)", minutes, seconds))
    }

    func testSavedRuns() {
        let runs = Database.shared.getRuns()
        XCTAssertNotNil(runs.first)

        let run = runs.first!
        XCTAssertTrue(run.distance == 10000)
        XCTAssertTrue(run.pace == 3.0)
        
    }

}
