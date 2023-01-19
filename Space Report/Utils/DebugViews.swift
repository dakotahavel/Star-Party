//
//  DebugViews.swift
//  Space Report
//
//  Created by Dakota Havel on 1/13/23.
//

import SwiftUI
import UIKit

#if DEBUG
    let highlightColors: [UIColor] = [
        .magenta,
        .yellow,
        .red,
        .systemTeal,
        .systemIndigo,
        .orange,
        .cyan,
    ]

    extension UIView {
        private enum SharedData {
            static var highlightCount: Int = 0
        }

        private var highlightColor: CGColor {
            let color = highlightColors[SharedData.highlightCount % highlightColors.count]
            SharedData.highlightCount += 1
            return color.cgColor
        }

        func DEBUG_Highlight() {
            layer.borderColor = highlightColor
            layer.borderWidth = 3.0
        }
    }
#endif
