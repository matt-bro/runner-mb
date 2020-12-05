//
//  Constants.swift
//  runner-mb
//
//  Created by Matt on 03.09.20.
//

import Foundation


class Constants {


    static func pace(distance: Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> Measurement<UnitSpeed> {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit]

        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        formatter.numberFormatter = numberFormatter

        let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        return speed.converted(to: outputUnit)
    }
}
