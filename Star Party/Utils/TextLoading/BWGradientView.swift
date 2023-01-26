//
//  Gradient.swift
//  Space Report
//
//  Created by Dakota Havel on 1/18/23.
//

import UIKit

class BWGradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    let gradientAnimation = CABasicAnimation(keyPath: "locations")

    var colors = [
        UIColor.systemBackground.withAlphaComponent(0.7).cgColor,
        UIColor.label.withAlphaComponent(0.7).cgColor,
        UIColor.systemBackground.withAlphaComponent(0.7).cgColor,
    ]

    var locations: [NSNumber] = [
        0.25,
        0.5,
        0.75,
    ]

    override init(frame: CGRect) {
        super.init(frame: .zero)

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.drawsAsynchronously = true
        gradientLayer.colors = colors
        gradientLayer.locations = locations

        gradientAnimation.fromValue = [-2.0, -1.5, 0.25]
        gradientAnimation.toValue = [0.75, 1.5, 2.0]
        gradientAnimation.duration = 1.6
        gradientAnimation.repeatCount = Float.infinity

        layer.addSublayer(gradientLayer)
        gradientLayer.add(gradientAnimation, forKey: nil)
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = bounds.height / 4
//        gradientLayer.frame = CGRect(
//            x: -bounds.size.width,
//            y: bounds.origin.y,
//            width: 3 * bounds.size.width,
//            height: bounds.size.height
//        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
