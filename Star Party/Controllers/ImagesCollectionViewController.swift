//
//  ImagesCollectionViewController.swift
//  Star Party
//
//  Created by Dakota Havel on 1/30/23.
//

import CoreData
import SwiftUI
import UIKit

// MARK: - ImagesCollectionViewController

class ImagesCollectionViewController: UICollectionViewController {
    private var apodsSortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "date", ascending: false)]
    private var apodsPredicate = NSPredicate(value: true)
    private var apods: [APOD] = .init()

    private var isLoading = true { didSet { loadingView.isHidden = !isLoading }}

    // MARK: - Lifecycle

    init() {
        let compositionalLayout = {
            let fraction: CGFloat = 1.0

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(fraction))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

//            let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(.leastNonzeroMagnitude))
//
//            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: ApodHeaderCell.supplementaryKind, alignment: .topLeading)
//            headerItem.pinToVisibleBounds = true
//            section.boundarySupplementaryItems = [headerItem]

            return UICollectionViewCompositionalLayout(section: section)
        }()

        super.init(collectionViewLayout: compositionalLayout)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple

        // Uncomment the following line to preserve selection between presentations
//        clearsSelectionOnViewWillAppear = false

        // MARK: Register Cells

        collectionView!.register(ApodImageCell.self, forCellWithReuseIdentifier: ApodImageCell.reuseId)

        // MARK: Initial Load

        let calendar = Calendar.current
        let endDate = Date()
        // current month is at 0 so -2 makes 3 months
        let startMonth = calendar.date(byAdding: DateComponents(month: 0), to: endDate)!
        let startDate = calendar.date(from: DateComponents(year: startMonth.year, month: startMonth.month, day: 1))!

        let startDateString = ApodDateFormatter.string(from: startDate)
        let endDateString = ApodDateFormatter.string(from: endDate)

        fetchApods(query: .range(start_date: startDateString, end_date: endDateString))

        // MARK: Initial Layout

        configureLoadingView()
//        configureFilterButton()
        configureSettingsHeaderItem()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Properties

    private lazy var loadingView: UIView = {
        let loading = UIView()
        loading.backgroundColor = .systemBackground.withAlphaComponent(0.5)

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        loading.addSubview(spinner)
        spinner.center(inView: loading)
        spinner.startAnimating()

        return loading
    }()

    private let filtersView = ApodFiltersViewController()

    // MARK: - API

    private var fetchApodsTask: Task<Void, Never>?
    func fetchApods(query: ApodQuery) {
        isLoading = true
        fetchApodsTask = Task {
            _ = try? await NASA_API.shared.fetchApodsData(query)
            refresh()
        }
    }

    // MARK: - Methods

    private func configureLoadingView() {
        view.addSubview(loadingView)
        loadingView.fillView(view, safe: false)
        loadingView.layer.zPosition = 1000
    }

    func configureFilterButton() {
        let filterButton = UIButton(type: .custom)
        let size = view.frame.width / 8
        filterButton.setDimensions(width: size, height: size)
        filterButton.layer.cornerRadius = 0.5 * size
        filterButton.clipsToBounds = true
        filterButton.tintColor = .white
        filterButton.backgroundColor = .nasa.secondaryRed

        filterButton.addTarget(self, action: #selector(didPressShowFilters), for: .touchUpInside)
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        view.addSubview(filterButton)
        let padding = view.frame.width / 16

        filterButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: padding / 2, paddingRight: padding)
    }

    func configureSettingsHeaderItem() {
        let settingsNavBarItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(showSettings))
        navigationItem.rightBarButtonItem = settingsNavBarItem
    }

    @MainActor private func refresh() {
        do {
            let request = APOD.fetchRequest() as NSFetchRequest<APOD>
            request.predicate = apodsPredicate
            request.sortDescriptors = apodsSortDescriptors
            apods = try APOD.context.fetch(request)
            collectionView.reloadData()
        } catch {
            print(error)
        }

        isLoading = false
    }

    // MARK: - Selectors

    @objc func showSettings() {
        present(SettingsView().asHosted(), animated: true)
    }

    @objc func didPressShowFilters() {
        present(filtersView, animated: true)
    }

    // MARK: - Delegates

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return apods.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ApodImageCell.reuseId, for: indexPath) as! ApodImageCell

        let apod = apods[indexPath.item]
        cell.apodViewModel = ApodViewModel(apod: apod)

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let apod = apods[indexPath.item]
        let apodVM = ApodViewModel(apod: apod)
        let detailView = ApodDetailViewController()
        detailView.apodViewModel = apodVM

        detailView.modalPresentationStyle = .pageSheet
        present(detailView, animated: true)
    }
}
