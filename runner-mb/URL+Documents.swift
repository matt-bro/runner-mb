//
//  URL+Documents.swift
//  runner-mb
//
//  Created by Matt on 16.11.20.
//

import Foundation

extension URL {
    static var documentsURL: URL {
        return try! FileManager
            .default
            .url(for: .documentDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil,
                 create: true)
    }
}
