//
//  ApodHeaderCell.swift
//  Space Report
//
//  Created by Dakota Havel on 1/19/23.
//

import UIKit

class ApodHeaderCell: UICollectionReusableView {
    static let reuseId = "ApodHeaderCell"
    static let supplementaryKind = "ApodDateHeader"

    var title: String? {
        didSet {
            configureCell()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

//        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
//        let blurView = UIVisualEffectView(effect: blurEffect)
//
//        addSubview(blurView)
//        blurView.fillView(self)

        addSubview(label)
        label.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: frame.width / 20)
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
