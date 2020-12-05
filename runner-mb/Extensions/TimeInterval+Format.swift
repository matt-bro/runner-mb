//
//  TimeInterval+Format.swift
//  runner-mb
//
//  Created by Matt on 31.12.19.
//

import Foundation

extension TimeInterval {
    var durationString: String {
        get {
            let interval = self

            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .full

            let formattedString = formatter.string(from: TimeInterval(interval))!
            print(formattedString)
            return formattedString
        }
    }

    var positionalTime: String {
        Formatter.positional.allowedUnits = self >= 3600 ?
            [.hour, .minute, .second] :
            [.hour, .minute, .second]
        return Formatter.positional.string(from: self)!
    }
}
