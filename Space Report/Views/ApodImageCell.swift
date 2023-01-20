//
//  ApodImageCell.swift
//  Space Report
//
//  Created by Dakota Havel on 1/19/23.
//

import Foundation
import UIKit

class ApodImageCell: UICollectionViewCell {
    static let reuseId = "ApodImageCell"

    var apodViewModel: ApodViewModel? {
        didSet {
            configureCell()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)
        label.center(inView: self)
        backgroundColor = .random
    }

    private let label: UILabel = .configured { label in
        label.font = UIFont.systemFont(ofSize: 18)
    }

    func configureCell() {
        label.text = apodViewModel?.apod.date
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
