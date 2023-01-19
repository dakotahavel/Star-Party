//
//  NasaPrimaryButton.swift
//  Space Report
//
//  Created by Dakota Havel on 1/18/23.
//

import UIKit

// MARK: - NasaPrimaryButton

class NasaPrimaryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .nasa.secondaryRed
        tintColor = .label
        border(color: .label, width: 3)
        roundCorners(radius: 6)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
