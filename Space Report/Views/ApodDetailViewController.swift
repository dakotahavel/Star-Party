//
//  ApodHeroView.swift
//  Space Report
//
//  Created by Dakota Havel on 1/17/23.
//

import UIKit

class ApodDetailViewController: UIViewController {
    var apodViewModel: ApodViewModel? {
        didSet {
            configureWithData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
        if apodViewModel != nil {
            configureWithData()
        }
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
        view.addSubview(heroImageView)
        heroImageView.fillHorizontal(view, safe: false)
        heroImageView.anchor(top: view.topAnchor, bottom: view.centerYAnchor)
        heroImageView.addSubview(copyrightLabel)
        copyrightLabel.anchor(left: heroImageView.leftAnchor, bottom: heroImageView.bottomAnchor, paddingLeft: 4, paddingBottom: 4)

        view.addSubview(titleLabel)
        titleLabel.fillHorizontal(view)
        titleLabel.anchor(top: heroImageView.bottomAnchor)
        titleLabelPlaceholderHeight = titleLabel.heightAnchor.constraint(equalToConstant: 60)
        titleLabelPlaceholderHeight?.isActive = true

        view.addSubview(titleBreak)
        titleBreak.anchor(top: titleLabel.bottomAnchor)
        titleBreak.fillHorizontal(view)

        view.addSubview(descriptionView)
        descriptionView.anchor(top: titleBreak.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor)

        titleLabelPlaceholder = TextLoadingPlaceholder(fontSize: titleLabel.font.pointSize, lineHeight: titleLabel.font.lineHeight)
        view.addSubview(titleLabelPlaceholder)
        titleLabelPlaceholder.fillView(titleLabel)

        descriptionViewPlaceholder = TextLoadingPlaceholder(fontSize: descriptionView.font?.pointSize ?? 16, lineHeight: descriptionView.font?.lineHeight ?? 18)
        view.addSubview(descriptionViewPlaceholder)
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

    var fetchImageTask: Task<Void, Never>?

    private func configureWithData() {
        // alot of this is set up to handle where the view model already has data
        // this isn't happening at the moment though b/c the cell that gets the sd image can't update the vm struct
        // nor can this view persist the hd image to the model

        // check for high res image first
        var data = apodViewModel?.apod.hdImageData
        // then sd image

        var notHD = false
        if data == nil {
            data = apodViewModel?.apod.sdImageData
            // try to get better image
            notHD = true
        }

        // if neither, try to get the best available and then load
        guard let data else {
            fetchApodImage()
            return
        }

        if !notHD, fetchImageTask == nil {
            // if has sd image, try to get hd
            fetchApodImage()
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
        print("detail view is fetching image")
        if apodViewModel?.apod == nil {
            return
        }
        if let previousTask = fetchImageTask {
            previousTask.cancel()
        }
        fetchImageTask = Task {
            if let data = try? await NasaAPI.shared.fetchApodImageData(apodViewModel!.apod, quality: .best) {
                DispatchQueue.main.async {
                    self.apodViewModel?.apod.hdImageData = data
                }
            }
        }
    }
}
