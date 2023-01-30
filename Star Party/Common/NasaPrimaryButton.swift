//
//  NasaPrimaryButton.swift
//  Space Report
//
//  Created by Dakota Havel on 1/18/23.
//

import UIKit

// MARK: - HighlightButton

class HighlightButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            blurView.isHidden = !isHighlighted
        }
    }

    init(with blurEffectStyle: UIBlurEffect.Style) {
        super.init(frame: .zero)
        layer.masksToBounds = true
        layer.cornerRadius = 4
        blurView.effect = UIBlurEffect(style: blurEffectStyle)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.adjustsFontSizeToFitWidth = true

        if let image = imageView {
            insertSubview(blurView, belowSubview: image)
        } else {
            insertSubview(blurView, at: 0)
        }

        blurView.fillView(self, safe: false)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let blurView: UIVisualEffectView = {
        let bv = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.isHidden = true

        return bv
    }()
}

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
                backgroundColor = .nasa.primaryBlue
            case .dark,
                 .unspecified:
                backgroundColor = .nasa.secondaryRed
            @unknown default:
                backgroundColor = .nasa.primaryBlue
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = traitCollection.userInterfaceStyle == .light ? .nasa.primaryBlue : .nasa.secondaryRed
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        tintColor = .white
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        roundCorners(radius: 6)
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
