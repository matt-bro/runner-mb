//
//  UIFont+Custom.swift
//  runner-mb
//
//  Created by Matt on 31.12.19.
//

import Foundation
import UIKit

extension UIFont {
    static var large: UIFont {
        return UIFont.systemFont(ofSize: 33.0)
    }

    static var small: UIFont? {
        return UIFont.systemFont(ofSize: 17.0)
    }
}
