//
//  Run+Accessor.swift
//  runner-mb
//
//  Created by Matt on 27.08.20.
//

import Foundation


extension Run {
    var distanceKmString: String {
        return String(format: "%02.02f", distanceKm)
    }

    func paceString(_ outputFormat: UnitSpeed = .minutesPerKilometer) -> String {
        let formattedPace = Constants.pace(distance: Measurement(value: Double(distance), unit: UnitLength.meters), seconds: Int(self.duration), outputUnit: outputFormat)
        let totalSeconds = lrint(formattedPace.value*60)
        //let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }
}
