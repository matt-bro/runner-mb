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

import Foundation
import CoreLocation
import RxSwift
import RxCocoa
import AVKit

protocol LocationManagerDelegate: class {
    func updatedLocation(locationManager: LocationManager)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    var pastLocations: [(CLLocation, Date)] = []
    var pastLocationsBinding: BehaviorRelay<[(CLLocation, Date)]> = BehaviorRelay(value: [])
    var locationManager: CLLocationManager? {
        didSet {
            if CLLocationManager.locationServicesEnabled() {
                locationManager?.delegate = self
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.requestWhenInUseAuthorization()
                locationManager?.distanceFilter = 10
                locationManager?.activityType = .fitness
            }
        }
    }
    weak var delegate: LocationManagerDelegate?

    var traveledDistance = Measurement(value: 0, unit: UnitLength.meters) {
        didSet {
            print(String(format: "location distance: %02.02f", self.traveledDistance.value))

        }
    }

    var distance = BehaviorRelay<Measurement>(value: Measurement(value: 0, unit: UnitLength.meters))

    func setup() {
        self.locationManager = CLLocationManager()
        self.locationManager?.allowsBackgroundLocationUpdates = true
        self.locationManager?.pausesLocationUpdatesAutomatically = false
    }

    func start() {
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringSignificantLocationChanges()
    }

    func stop() {
        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.stopMonitoringSignificantLocationChanges()
    }

    func kill() {
        self.stop()
        self.locationManager = nil
        self.pastLocations = []
    }

    var newDate:Date? = Date(timeIntervalSinceNow: 10)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location update")
        //I want to compare this current location with the last location we got
        //so I know the distance I traveled
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }

            if let lastLocation = pastLocations.last?.0 {
                let delta = newLocation.distance(from: lastLocation)
                self.traveledDistance = self.traveledDistance + Measurement(value: delta, unit: UnitLength.meters)
                self.distance.accept(self.traveledDistance)
            }

            pastLocations.append((newLocation, Date()))
            pastLocationsBinding.accept(pastLocations)
        }

        self.delegate?.updatedLocation(locationManager: self)

//        let currentDate = Date()
//        let nextDate = Date(timeIntervalSinceNow: -1.0)
//
//        guard let newDate = newDate else { return }
//        if currentDate > newDate {
//            //advance goal
//            //say something
//            print("should say ghost goal")
//            do {
//                try AVAudioSession.sharedInstance().setActive(true)
//                print("Session is Active")
//                AudioPlayerManager.shared.playSound(fileName: "half.caf", completion: {
//                    do {
//                        try? AVAudioSession.sharedInstance().setActive(false)
//                    }
//                })
//            } catch {
//                print(error)
//            }
//            SpeechManager.shared.say(text: "ghost new goal")
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as? CLError)?.code == .denied {
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
        }
    }

    @objc func stopLocationManager() {
        self.kill()
    }

    static func pace(distance: Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> Measurement<UnitSpeed> {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit] // 1
        let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        return speed.converted(to: outputUnit)

    }

    static func formatSpeed(speed:Measurement<UnitSpeed>, outputUnit: UnitSpeed) -> String {
        let formatter = MeasurementFormatter()
        return formatter.string(from: speed.converted(to: outputUnit))
    }
}


