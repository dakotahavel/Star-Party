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

    var imageFetchTask: URLSessionDataTask?
    var imageSetTask: Task<Void, Never>?
    var imageView: UIImageView? = .configured { iv in
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
    }

    let loader: UIActivityIndicatorView = .init(style: .large)

    var apodViewModel: ApodViewModel? {
        didSet {
            configureCell()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        addSubview(label)
        label.center(inView: self)

        addSubview(loader)
        loader.fillView(self)
        loader.startAnimating()

        addSubview(imageView!)
        imageView?.fillView(self)
    }

    private let label: UILabel = .configured { label in
        label.font = UIFont.systemFont(ofSize: 18)
    }

    func configureCell() {
        if let previousTask = imageFetchTask {
            previousTask.cancel()
        }

        guard let apodViewModel else {
            noViewModelFallback()
            return
        }

        configureLoadingUI()

        imageFetchTask = NASA_API.shared.fetchApodImageDataTask(apodViewModel.apod, desiredQuality: .standard, completion: { [weak self] data, resp, error, _ in
            if error != nil || !Requests.hasGoodResponseCode(resp) {
                return
            }

            if let data {
                DispatchQueue.main.async {
                    self?.imageView?.image = UIImage(data: data)
                    self?.label.text = nil
                    self?.loader.isHidden = true
                    self?.loader.stopAnimating()
                }
            } else {
                self?.noImageDataFallback()
            }

        })
    }

    func noViewModelFallback() {
        DispatchQueue.main.async { [weak self] in
            print("no view model")
            self?.label.text = "Error"
        }
    }

    func configureLoadingUI() {
        DispatchQueue.main.async { [weak self] in
            self?.imageView?.image = nil
            self?.loader.isHidden = false
            self?.loader.startAnimating()
            self?.label.text = self?.apodViewModel?.dateString
        }
    }

    func noImageDataFallback() {
        guard let apodViewModel else {
            noViewModelFallback()
            return
        }
//        print("no image data", apodViewModel.apod.date, apodViewModel.apod.title)
        DispatchQueue.main.async { [weak self] in

            self?.label.text = apodViewModel.dateString
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
