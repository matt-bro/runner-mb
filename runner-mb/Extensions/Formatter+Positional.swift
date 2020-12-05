//
//  Formatter+Positional.swift
//  runner-mb
//
//  Created by Matt on 31.12.19.
//

import Foundation

extension Formatter {
    static let positional: DateComponentsFormatter = {
        let positional = DateComponentsFormatter()
        positional.unitsStyle = .positional
        positional.zeroFormattingBehavior = .pad
        return positional
    }()
}
