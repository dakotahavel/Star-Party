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

class ApodsGridViewController: UICollectionViewController {
    var sections = [ApodSection]() {
        didSet {
            print("did set")
            collectionView.reloadData()
        }
    }

//    init(sections: [ApodSection]) {
    init() {
//        self.sections = sections
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

        fetchApods()
    }

    func fetchApods() {
        let apods = NasaAPI.shared.fakeRandomApods()

        var yearsMap: [Int: [ApodViewModel]] = .init()
        for apod in apods {
            let vm = ApodViewModel(apod: apod)
            // skips apods where date wasn't able to parse
            if let year = vm.dateObj?.year {
                yearsMap[year, default: []].append(vm)
            }
        }

        let sortedApods = yearsMap.sortByKeys(.desc)
        let apodSections = sortedApods.map { year, apodsArray in
            ApodSection(title: "\(year)", items: apodsArray)
        }
        sections = apodSections
//        print(sections)
    }

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
        let detailView = ApodDetailView(apodViewModel: apodVM)
        let v = UIViewController()
        v.view.addSubview(detailView)
        detailView.fillView(v.view, safe: false)
        v.modalPresentationStyle = .pageSheet
        present(v, animated: true)

//        navigationController?.pushViewController(v, animated: true)
    }

    // MARK: - boilerplate

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
