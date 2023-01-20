//
//  HomeViewController.swift
//  Space Report
//
//  Created by Dakota Havel on 1/13/23.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - HighlightButton

class HighlightButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            blurView.isHidden = !isHighlighted
        }
    }

    init(with blurEffectStyle: UIBlurEffect.Style) {
        super.init(frame: .zero)
        layer.masksToBounds = true
        layer.cornerRadius = 4
        blurView.effect = UIBlurEffect(style: blurEffectStyle)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.adjustsFontSizeToFitWidth = true

        if let image = imageView {
            insertSubview(blurView, belowSubview: image)
        } else {
            insertSubview(blurView, at: 0)
        }

//        blurView.constrain(to: self)
        blurView.fillView(self, safe: false)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let blurView: UIVisualEffectView = {
        let bv = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.isHidden = true

        return bv
    }()
}

// MARK: - TodaysApodViewController

class TodaysApodViewController: UIViewController {
    var apodHeroView = ApodDetailView()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTodaysApodAndImage()
        configureLayout()
    }

    func fetchTodaysApodAndImage() {
        Task {
            if let apod = try? await NasaAPI.shared.fetchTodaysApod() {
                apodHeroView.apodViewModel = ApodViewModel(apod: apod)
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
        navigationController?.pushViewController(ApodsGridViewController(), animated: true)
    }

    func configureLayout() {
        view.addSubview(apodHeroView)
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
