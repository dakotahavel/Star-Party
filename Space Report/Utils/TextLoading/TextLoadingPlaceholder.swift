//
//  TextLoadingPlaceholder.swift
//  Space Report
//
//  Created by Dakota Havel on 1/17/23.
//

import CoreGraphics
import UIKit

// MARK: - TextLoadingPlaceholder

class TextLoadingPlaceholder: UIView {
    let fakeProportions: [CGFloat] = [
        0.95,
        0.90,
        0.86,
        0.85,
        0.99,
        0.95,
        0.60,
        0.92,
        0.98,
        0.93,
        0.85,
        0.97,
        0.92,
        0.43,
    ]

    var fontSize: CGFloat = 16.0
    var lineHeight: CGFloat = 18.0
    var currentHeight = CGFloat(0.0)
    init(fontSize: CGFloat = 16.0, lineHeight: CGFloat = 18.0) {
        self.fontSize = fontSize
        self.lineHeight = lineHeight

        super.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func addLines() {
        backgroundColor = .systemBackground
        // remove old lines
        subviews.forEach { $0.removeFromSuperview() }

        var lastBottom = topAnchor

        let count = Int(currentHeight / lineHeight)
        let headroom = lineHeight - fontSize

//        print("line count", count, "fontsize", fontSize, "line height", lineHeight, "gap", gap)
        for i in 0..<count {
            let line = BWGradientView()
            line.setHeight(fontSize)

            let widthProportion = fakeProportions[i % fakeProportions.count]
            line.setWidth(frame.width * widthProportion)

            addSubview(line)
            line.anchor(top: lastBottom, left: leftAnchor, paddingTop: headroom, paddingLeft: headroom)

            lastBottom = line.bottomAnchor

            //            line.DEBUG_Highlight()
        }
    }

    override func layoutSubviews() {
        // only call if the height has changed
        if currentHeight != frame.height {
            currentHeight = frame.height
            addLines()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
