//
//  ApodHeaderCell.swift
//  Space Report
//
//  Created by Dakota Havel on 1/19/23.
//

import SwiftUI
import UIKit

// MARK: - ApodHeaderCell

class ApodHeaderCell: UICollectionReusableView {
    static let reuseId = "ApodHeaderCell"
    static let supplementaryKind = "ApodDateHeader"

    var title: String? {
        didSet {
            configureCell()
        }
    }

    let base: CGFloat = 0
    let background: CGFloat = 100
    let foreground: CGFloat = 200

    override init(frame: CGRect) {
        super.init(frame: frame)
        let height = label.font.lineHeight
        let halfHeight = height / 2
        backgroundColor = .clear
        layer.zPosition = base

        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, paddingTop: halfHeight, paddingLeft: height)
        label.layer.zPosition = foreground

        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
//        let blurLabelWrapper = UIView()
//        blurLabelWrapper.backgroundColor = .blue
        addSubview(blurView)
        blurView.layer.zPosition = background

        blurView.anchor(top: label.topAnchor, left: label.leftAnchor, bottom: label.bottomAnchor, right: label.rightAnchor, paddingLeft: -halfHeight, paddingRight: -halfHeight)
        blurView.roundCorners(radius: halfHeight)
        blurView.clipsToBounds = true
    }

    private let label: UILabel = .configured { label in
        label.font = UIFont.systemFont(ofSize: 24)
    }

    func configureCell() {
        label.text = title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
