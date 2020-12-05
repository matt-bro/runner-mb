//
//  UnitConverterPace.swift
//  runner-mb
//
//  Created by Matt on 04.01.20.
//

import Foundation

class UnitConverterPace: UnitConverter {
    private let coefficient: Double

    init(coefficient: Double) {
        self.coefficient = coefficient
    }

    override func baseUnitValue(fromValue value: Double) -> Double {
        return reciprocal(value * coefficient)
    }

    override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        return reciprocal(baseUnitValue * coefficient)
    }

    private func reciprocal(_ value: Double) -> Double {
        guard value != 0 else { return 0 }
        return 1.0 / value
    }
}
