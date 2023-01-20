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

    var imageFetch: URLSessionDataTask?
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
        backgroundColor = .random

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
        print("configure cell", apodViewModel?.apod.date)
        imageView?.image = nil
        guard let apodViewModel else {
            noViewModelFallback()
            return
        }

        loadingImageFallback()

        if let previousTask = imageFetch {
            previousTask.cancel()
        }

        imageFetch = NasaAPI.shared.fetchApodImageDataTask(apodViewModel.apod, quality: .standard, completion: { [weak self] data, resp, error in
            if error != nil || !hasGoodResponseCode(resp) {
                print(String(describing: error), String(describing: resp))
                self?.noImageDataFallback()
                return
            }

            if let data {
                DispatchQueue.main.async {
                    self?.imageView?.image = UIImage(data: data)
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

    func loadingImageFallback() {
        DispatchQueue.main.async { [weak self] in
            self?.loader.isHidden = false
            self?.loader.startAnimating()
        }
    }

    func noImageDataFallback() {
        guard let apodViewModel else {
            noViewModelFallback()
            return
        }
        DispatchQueue.main.async { [weak self] in
            print("no image data", apodViewModel.apod.date, apodViewModel.apod.title)
            self?.label.text = apodViewModel.apod.date
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
