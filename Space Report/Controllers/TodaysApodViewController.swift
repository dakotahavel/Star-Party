//
//  HomeViewController.swift
//  Space Report
//
//  Created by Dakota Havel on 1/13/23.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - TodaysApodViewController

class TodaysApodViewController: UIViewController {
    var apodHeroView = ApodDetailView()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTodaysApodImage()
        configureLayout()
    }

    func fetchTodaysApodImage() {
        Task {
            if let (imageData, apod) = try? await NasaAPI.shared.fetchApodImageData(.today) {
                apodHeroView.apodViewModel = ApodViewModel(apod: apod, imageData: imageData)
            }
        }
    }

    private lazy var ExploreApodsButton: UIButton = .configured(type: .system, target: self, selector: #selector(handleExplorePressed)) { button in
        button.setTitle("Explore More", for: .normal)
    }

    @objc func handleExplorePressed() {
        navigationController?.pushViewController(ExploreApodsViewController(), animated: true)
    }

    func configureLayout() {
        view.addSubview(apodHeroView)
        apodHeroView.anchor(top: view.topAnchor)
        apodHeroView.setHeight(view.frame.height * 0.85)
        apodHeroView.fillHorizontal(view, safe: false)

        let buttonWrapper = UIView()
        view.addSubview(buttonWrapper)
        buttonWrapper.anchor(top: apodHeroView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)

        buttonWrapper.addSubview(ExploreApodsButton)
        ExploreApodsButton.centerY(inView: buttonWrapper)

        ExploreApodsButton.anchor(left: buttonWrapper.leftAnchor, right: buttonWrapper.rightAnchor, paddingLeft: 10, paddingRight: 10)
    }
}

// MARK: - HomeViewControllerRepresentation

struct HomeViewControllerRepresentation: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TodaysApodViewController {
        return TodaysApodViewController()
    }

    func updateUIViewController(_ uiViewController: TodaysApodViewController, context: Context) {
    }

    typealias UIViewControllerType = TodaysApodViewController
}

// MARK: - HomeViewController_Preview

struct HomeViewController_Preview: PreviewProvider {
    static var previews: some View {
        HomeViewControllerRepresentation().ignoresSafeArea()
    }
}
