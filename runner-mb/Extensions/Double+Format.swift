//
//  Double+Format.swift
//  runner-mb
//
//  Created by Matt on 06.01.20.
//

import Foundation

extension Double {
    var short: String {
        return String(format: "%02.02f", self)
    }
}
