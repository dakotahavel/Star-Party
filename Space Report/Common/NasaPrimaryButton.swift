//
//  NasaPrimaryButton.swift
//  Space Report
//
//  Created by Dakota Havel on 1/18/23.
//

import UIKit

// MARK: - NasaPrimaryButton

class NasaPrimaryButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
        }
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .nasa.secondaryRed
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        tintColor = .white
        roundCorners(radius: 6)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
