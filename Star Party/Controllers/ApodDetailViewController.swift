//
//  ApodHeroView.swift
//  Space Report
//
//  Created by Dakota Havel on 1/17/23.
//

import CoreData
import NotificationCenter
import UIKit

class ApodDetailViewController: UIViewController {
    var apodViewModel: ApodViewModel? {
        didSet {
            print("Apod VM set")
            configureWithData()
        }
    }

    var apodContext: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
        if apodViewModel != nil {
            apodContext = apodViewModel?.apod.managedObjectContext

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(apodDidSave),
                name: .NSManagedObjectContextDidSave,
                object: apodContext
            )
        }
//        if apodViewModel != nil {
//            print("started with vm, configureWithData")
//            configureWithData()
//        }
    }

    @objc func apodDidSave(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, !inserts.isEmpty {
            print("--- INSERTS ---")
            print(inserts)
            print("+++++++++++++++")
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updates.isEmpty {
            print("--- UPDATES ---")
            for update in updates {
                print(update.changedValues())
            }
            print("+++++++++++++++")
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletes.isEmpty {
            print("--- DELETES ---")
            print(deletes)
            print("+++++++++++++++")
        }
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

    private var imageQualityLabel: UILabel = .configured { label in
        label.tintColor = .white
        label.backgroundColor = .systemBackground
        label.text = ""
        label.font = UIFont.preferredFont(forTextStyle: .title1)
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

        heroImageView.addSubview(imageQualityLabel)
        imageQualityLabel.anchor(bottom: heroImageView.bottomAnchor, right: heroImageView.rightAnchor, paddingBottom: 8, paddingRight: 8)

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

    @MainActor private func configureWithData() {
        print("configure with data", apodViewModel?.apod)
        // check for high res image first
        var data = apodViewModel?.apod.hdImage?.imageData

        // then sd image
        var notHD = false
        if data == nil {
            data = apodViewModel?.apod.image?.imageData
            // try to get better image
            notHD = true
        }

        // if neither, try to get the best available and then load
        guard let data, fetchImageTask == nil else {
            fetchApodImage()
            return
        }

        if notHD, fetchImageTask == nil {
            // if has sd image, try to get hd if haven't tried already
            fetchApodImage()
        }

        let option: UIView.AnimationOptions = notHD ? .transitionFlipFromTop : .transitionCurlUp
        let imageQuality = notHD ? "SD" : ""
        UIView.transition(with: heroImageView, duration: 0.6, options: option) { [self] in
            heroImageView.image = UIImage(data: data)
            heroImageView.contentMode = .scaleAspectFill
            heroImageView.clipsToBounds = true
            imageQualityLabel.text = imageQuality
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
            print("before fetch apod image")
            _ = try? await NASA_API.shared.fetchApodImageData(apodViewModel!.apod, desiredQuality: .best)
            print("fetchImageTask after fetch")
            
            apodViewModel?.apod.refresh()
//            print("apod vm", apodViewModel?.apod.hd)
//            configureWithData()
        }
    }
}
