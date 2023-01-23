//
//  Effects.swift
//  Space Report
//
//  Created by Dakota Havel on 1/20/23.
//

import UIKit

// let blurEffect = UIBlurEffect(style: .systemThinMaterial)
// let blurView = UIVisualEffectView(effect: blurEffect)
//

// MARK: - ContrastVisualEffectView

class ContrastVisualEffectView: UIVisualEffectView {
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            switch traitCollection.userInterfaceStyle {
            case .light:
                backgroundColor = .nasa.secondaryRed
            case .dark,
                 .unspecified:
                backgroundColor = .nasa.primaryBlue
            @unknown default:
                backgroundColor = .nasa.primaryBlue
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
