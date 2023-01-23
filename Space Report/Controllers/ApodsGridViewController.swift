//
//  ExploreApodsViewController.swift
//  Space Report
//
//  Created by Dakota Havel on 1/18/23.
//

import Foundation
import UIKit

// MARK: - ApodSection

struct ApodSection {
    let title: String
    let items: [ApodViewModel]
}

// MARK: - ApodsGridViewController

class ApodsGridViewController: UICollectionViewController, ApodFiltersDelegate {
    var sections = [ApodSection]() {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: - Lifecycle

    init() {
        let compositionalLayout: UICollectionViewCompositionalLayout = {
            let fraction: CGFloat = 1 / 3

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(fraction))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(fraction / 10))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: ApodHeaderCell.supplementaryKind, alignment: .top)
            headerItem.pinToVisibleBounds = true
            section.boundarySupplementaryItems = [headerItem]

            return UICollectionViewCompositionalLayout(section: section)
        }()
        super.init(collectionViewLayout: compositionalLayout)
    }

    override func viewDidLoad() {
        view.backgroundColor = .purple

        collectionView.register(ApodImageCell.self, forCellWithReuseIdentifier: ApodImageCell.reuseId)
        collectionView.register(ApodHeaderCell.self, forSupplementaryViewOfKind: ApodHeaderCell.supplementaryKind, withReuseIdentifier: ApodHeaderCell.reuseId)

        fetchApods(query: .random(count: 30))

        configureFilterButton()

        view.addSubview(loadingView)
        loadingView.fillView(view)
        loadingView.layer.zPosition = 1000

        filtersView.filtersDelegate = self
    }

    func handleSetFilter(_ filter: ApodFilter) {
        switch filter {
        case let .range(start_date: start_date, end_date: end_date):
            let start = ApodDateFormatter.string(from: start_date)
            let end = ApodDateFormatter.string(from: end_date)
            fetchApods(query: .range(start_date: start, end_date: end))
        case let .random(count: count):
            print("handleSetFilter random", count)
        case let .date(date: date):
            let day = ApodDateFormatter.string(from: date)
            fetchApods(query: .range(start_date: day, end_date: day))
        }
    }

    private let filtersView = ApodFiltersViewController()

    private lazy var loadingView: UIView = {
        let loading = UIView()
        loading.roundCorners(radius: 16)
        loading.clipsToBounds = true
        let backgroundImage = UIImageView(image: UIImage(systemName: "aqi.medium")!)
        let possibleColors: [UIColor] = [.orange, .red, .yellow, .blue, .cyan, .green]
        backgroundImage.tintColor = possibleColors.randomElement()
//        let pattern = UIColor(patternImage: backgroundImage)
//        loading.backgroundColor = pattern
        loading.addSubview(backgroundImage)
        backgroundImage.fillView(loading, safe: false)

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)

        loading.addSubview(blurView)
        blurView.fillView(loading)

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        loading.addSubview(spinner)
        spinner.center(inView: loading)
        spinner.startAnimating()

        return loading
    }()

    func configureFilterButton() {
        let filterButton = UIButton(type: .custom)
        let size = view.frame.width / 8
        filterButton.setDimensions(width: size, height: size)
        filterButton.layer.cornerRadius = 0.5 * size
        filterButton.clipsToBounds = true
        filterButton.tintColor = .white
        filterButton.backgroundColor = .nasa.secondaryRed

        filterButton.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        view.addSubview(filterButton)
        let padding = view.frame.width / 16

        filterButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: padding / 2, paddingRight: padding)
    }

    @objc func showFilters() {
        present(filtersView, animated: true)
    }

    // MARK: - API

    private var isLoading = true {
        didSet {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) { [weak self] in
                if let self {
                    self.loadingView.alpha = self.isLoading ? 1 : 0
                }
            }
        }
    }

    private var hasError = false {
        didSet {
            if hasError {
                showErrorAlert()
            }
        }
    }

    func showErrorAlert() {
        var alertMessage: String
        var isUnknown = false
        if let description = lastQuery?.queryDescription {
            alertMessage = "Sometimes the NASA API fails, mostly for large date ranges.\nWould you like to retry the query for \n\(description)"
        } else {
            isUnknown = true
            alertMessage = "Something unexpected went wrong"
        }
        let alert = UIAlertController(title: "Oops", message: alertMessage, preferredStyle: .alert)

        if !isUnknown {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Retry?", comment: "Retry query action"), style: .default, handler: { _ in
                self.retryLastQuery()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Do Nothing", comment: "Do nothing action"), style: .cancel, handler: { _ in
                print("did nothing")
            }))
        } else {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Okay...", comment: "Do nothing action"), style: .cancel, handler: { _ in
                print("did nothing")
            }))
        }

        present(alert, animated: true, completion: nil)
    }

    private var fetchApodsTask: Task<Void, Never>?
    private var lastQuery: ApodQuery?

    deinit {
        fetchApodsTask?.cancel()
    }

    private func retryLastQuery() {
        if let query = lastQuery {
            fetchApods(query: query)
        }
    }

    func fetchApods(query: ApodQuery) {
        fetchApodsTask?.cancel()
        isLoading = true
        hasError = false
        sections = []
        lastQuery = query
        fetchApodsTask = Task {
            print(query)
            if let apods = try? await NasaAPI.shared.fetchApodsData(query) {
                var sectionMap: [Date: [ApodViewModel]] = .init()
                for apod in apods {
                    let vm = ApodViewModel(apod: apod)
                    // skips apods where date wasn't able to parse
                    if let yearMonth = vm.yearMonth {
                        print(yearMonth)
                        sectionMap[yearMonth, default: []].append(vm)
                    } else {
                        print("unexpected date format", vm.apod)
                    }
                }

                let sortedApods = sectionMap.sortByKeys(.desc)

                let apodSections = sortedApods.map { apodDate, apodsArray in
                    print("mapped sections", apodDate)
                    let year = apodDate.year
                    let month = apodDate.month
                    let monthName = DateFormatter().monthSymbols[month - 1]
                    return ApodSection(title: "\(year) \(monthName)", items: apodsArray)
                }

                DispatchQueue.main.async { [weak self] in
                    self?.sections = apodSections
                }
            } else {
                print("fetch apods task failed")
                self.hasError = true
            }

            self.isLoading = false
        }
    }

    // MARK: - Helper

    func resolveSection(_ indexPath: IndexPath) -> ApodSection {
        return sections[indexPath.section]
    }

    func resolveApodVM(_ indexPath: IndexPath) -> ApodViewModel {
        return sections[indexPath.section].items[indexPath.item]
    }

    // MARK: - Delegate Methods

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ApodImageCell.reuseId, for: indexPath) as? ApodImageCell else { return ApodImageCell() }
        cell.apodViewModel = resolveApodVM(indexPath)
        return cell
    }

    func viewForApodHeaderCell(_ collectionView: UICollectionView, at indexPath: IndexPath) -> ApodHeaderCell {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: ApodHeaderCell.supplementaryKind, withReuseIdentifier: ApodHeaderCell.reuseId, for: indexPath) as? ApodHeaderCell else {
            return ApodHeaderCell()
        }
        let section = resolveSection(indexPath)
        headerView.title = section.title

        return headerView
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case ApodHeaderCell.supplementaryKind:
            return viewForApodHeaderCell(collectionView, at: indexPath)

        default:
            assertionFailure("\(self) - Unexpected element kind: \(kind).")
            return UICollectionReusableView()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let apodVM = resolveApodVM(indexPath)
        let detailView = ApodDetailViewController()

        // TODO: - This is a weird way to do it
        // detail view needs work
        // detail view should be able to load sd image then fetch hd and pop it in
        // modal shouldn't have loading screen at all from here

        detailView.modalPresentationStyle = .pageSheet
        present(detailView, animated: true)
        detailView.apodViewModel = apodVM
    }

    // MARK: - boilerplate

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
