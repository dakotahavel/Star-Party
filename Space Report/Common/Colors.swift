//
//  Colors.swift
//  Space Report
//
//  Created by Dakota Havel on 1/7/23.
//

import Foundation
import SwiftUI

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF)
    }

    static func hex(hex: Int) -> UIColor {
        return UIColor(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF)
    }

    enum nasa {
        static let primaryBlue = UIColor(hex: 0x105BD8)
        static let primaryBlueDarker = UIColor(hex: 0x0B3D91)
        static let primaryBlueDarkest = UIColor(hex: 0x061F4A)
        static let secondaryRed = UIColor(hex: 0xDD361C)
        static let white: UIColor = .white
    }

    enum spacex {
        static let primaryBlue = UIColor(hex: 0x005288)
        static let secondarySilver = UIColor(hex: 0xA7A9AC)
    }
}
