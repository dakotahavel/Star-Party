//
//  HomeViewController.swift
//  Space Report
//
//  Created by Dakota Havel on 1/13/23.
//

import CoreData
import Foundation
import SwiftUI
import UIKit

// MARK: - TodaysApodViewController

class TodaysApodViewController: UIViewController {
    var apodDetailViewController = ApodDetailViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        fetchTodaysApodAndImage()
        configureLayout()
    }

    func fetchTodaysApodAndImage() {
        Task {
            do {
                let today = Date()
                let todayString = ApodDateFormatter.string(from: today)
                try await NASA_API.shared.fetchApodsData(.date(date: todayString))
                let request = APOD.fetchRequest() as NSFetchRequest<APOD>
                request.predicate = NSPredicate(format: "%K == %@", "dateString", todayString)

                let apod = try APOD.context.fetch(request).first

                if let found = apod {
                    try await NASA_API.shared.fetchApodImageData(found, desiredQuality: .best)

                    apodDetailViewController.apodViewModel = ApodViewModel(apod: found)
                }

            } catch {
                print(error)
            }
        }
    }

    private lazy var ExploreApodsButton: NasaPrimaryButton = {
        let button = NasaPrimaryButton(type: .system)
        button.setTitle("Explore More", for: .normal)
        button.addTarget(self, action: #selector(handleExplorePressed), for: .touchUpInside)
        return button
    }()

    @objc func handleExplorePressed() {
        navigationController?.pushViewController(ImagesCollectionViewController(), animated: true)
    }

    func configureLayout() {
        if let apodHeroView = apodDetailViewController.view {
            addChild(apodDetailViewController)
            view.addSubview(apodHeroView)
            apodDetailViewController.didMove(toParent: self)

            apodHeroView.anchor(top: view.topAnchor)
            apodHeroView.setHeight(view.frame.height * 0.85)
            apodHeroView.fillHorizontal(view, safe: false)

            let buttonLayoutContainer = UIView()
            view.addSubview(buttonLayoutContainer)
            buttonLayoutContainer.anchor(top: apodHeroView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)

            buttonLayoutContainer.addSubview(ExploreApodsButton)
            ExploreApodsButton.centerY(inView: buttonLayoutContainer)

            ExploreApodsButton.anchor(left: buttonLayoutContainer.leftAnchor, right: buttonLayoutContainer.rightAnchor, paddingLeft: 10, paddingRight: 10)
        }
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
