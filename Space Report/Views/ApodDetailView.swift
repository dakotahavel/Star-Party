//
//  ApodHeroView.swift
//  Space Report
//
//  Created by Dakota Havel on 1/17/23.
//

import UIKit

class ApodDetailView: UIView {
    var apodViewModel: ApodViewModel? {
        didSet {
            configureWithData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    init(apodViewModel: ApodViewModel) {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        configureLayout()
        self.apodViewModel = apodViewModel
        configureWithData()
    }

    private var heroImageView: UIImageView = .configured { iv in
        iv.backgroundColor = .black
        iv.tintColor = .label
        iv.image = UIImage(systemName: "moon.stars.fill")
        iv.contentMode = .scaleAspectFit
    }

    private var copyrightLabel: UILabel = .configured { label in
        label.tintColor = .white
    }

    private var titleLabel: UILabel = .configured { label in
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
    }

    private var titleLabelPlaceholderHeight: NSLayoutConstraint?
    private var titleLabelPlaceholder: UIView = .init()

    private let titleBreak: UIView = .configured { v in
        v.backgroundColor = .label
        v.setHeight(2)
    }

    private var descriptionView: UITextView = .configured { tv in
        tv.font = UIFont.preferredFont(forTextStyle: .body)
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 10)
    }

    private var descriptionViewPlaceholder: UIView = .init()

    private func configureLayout() {
        addSubview(heroImageView)
        heroImageView.fillHorizontal(self, safe: false)
        heroImageView.anchor(top: topAnchor, bottom: centerYAnchor)
        heroImageView.addSubview(copyrightLabel)
        copyrightLabel.anchor(left: heroImageView.leftAnchor, bottom: heroImageView.bottomAnchor, paddingLeft: 4, paddingBottom: 4)

        addSubview(titleLabel)
        titleLabel.fillHorizontal(self)
        titleLabel.anchor(top: heroImageView.bottomAnchor)
        titleLabelPlaceholderHeight = titleLabel.heightAnchor.constraint(equalToConstant: 60)
        titleLabelPlaceholderHeight?.isActive = true

        addSubview(titleBreak)
        titleBreak.anchor(top: titleLabel.bottomAnchor)
        titleBreak.fillHorizontal(self)

        addSubview(descriptionView)
        descriptionView.anchor(top: titleBreak.bottomAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: bottomAnchor, right: safeAreaLayoutGuide.rightAnchor)

        titleLabelPlaceholder = TextLoadingPlaceholder(fontSize: titleLabel.font.pointSize, lineHeight: titleLabel.font.lineHeight)
        addSubview(titleLabelPlaceholder)
        titleLabelPlaceholder.fillView(titleLabel)

        descriptionViewPlaceholder = TextLoadingPlaceholder(fontSize: descriptionView.font?.pointSize ?? 16, lineHeight: descriptionView.font?.lineHeight ?? 18)
        addSubview(descriptionViewPlaceholder)
        descriptionViewPlaceholder.fillView(descriptionView)
    }

    func hidePlaceholders() {
        titleLabelPlaceholderHeight?.isActive = false

        UIView.animate(withDuration: 1) {
            self.titleLabelPlaceholder.alpha = 0
            self.descriptionViewPlaceholder.alpha = 0
        } completion: { finished in
            self.titleLabelPlaceholder.removeFromSuperview()
            self.descriptionViewPlaceholder.removeFromSuperview()
        }
    }

    private func configureWithData() {
        var data = apodViewModel?.apod.hdImageData

        if data == nil {
            data = apodViewModel?.apod.sdImageData
        }

        guard let data else {
            fetchApodImage()
            return
        }

        UIView.transition(with: heroImageView, duration: 0.6, options: .transitionCrossDissolve) { [self] in
            heroImageView.image = UIImage(data: data)
            heroImageView.contentMode = .scaleAspectFill
            heroImageView.clipsToBounds = true
        }

        copyrightLabel.attributedText = apodViewModel?.copyrightAttrString
        titleLabel.text = apodViewModel?.apod.title
        descriptionView.attributedText = apodViewModel?.descriptionAttrString
        hidePlaceholders()
    }

    private func fetchApodImage() {
        if apodViewModel?.apod == nil {
            return
        }

        Task {
            if let data = try? await NasaAPI.shared.fetchApodImageData(apodViewModel!.apod, quality: .best) {
                DispatchQueue.main.async {
                    self.apodViewModel?.apod.sdImageData = data
                }
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
