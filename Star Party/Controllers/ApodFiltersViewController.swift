//
//  ApodFiltersViewController.swift
//  Space Report
//
//  Created by Dakota Havel on 1/21/23.
//

import SwiftUI
import UIKit

// MARK: - ApodFilter

enum ApodFilter {
    case date(date: Date)
    case range(start_date: Date, end_date: Date)
    case random(count: String)
}

// MARK: - ApodFiltersDelegate

protocol ApodFiltersDelegate: AnyObject {
    func didPressApplyFilter(_ filter: ApodFilter)
}

// MARK: - ApodFiltersViewController

class ApodFiltersViewController: UIViewController {
    weak var filtersDelegate: ApodFiltersDelegate?
    private var startDateValue: Date? = Date() {
        didSet {
            configureUI()
        }
    }

    private var endDateOn: Bool = false {
        didSet {
            configureUI()
        }
    }

    private var ApodFilter: ApodFilter?

    private let startDateLabel: UILabel = .configured { label in
        label.text = "Start Date"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
    }

    private lazy var startDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date

        dp.minimumDate = oldestApodDate
        dp.maximumDate = Date()
        dp.preferredDatePickerStyle = .wheels
        dp.addTarget(self, action: #selector(handleStartDateChange), for: .valueChanged)
        return dp
    }()

    @objc func handleStartDateChange() {
        startDateValue = startDatePicker.date
    }

    private lazy var startDateGroup: UIView = .configured { vu in
        vu.addSubview(startDateLabel)
        startDateLabel.fillHorizontal(vu)
        startDateLabel.textAlignment = .center
        startDateLabel.anchor(top: vu.topAnchor)

        vu.addSubview(startDatePicker)
        startDatePicker.fillHorizontal(vu)
        startDatePicker.anchor(top: startDateLabel.bottomAnchor, paddingTop: 8)
    }

    private lazy var endDateLabel: UILabel = .configured { label in
        label.text = "Date Range?"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
    }

    private lazy var endDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.maximumDate = Date()
        dp.preferredDatePickerStyle = .wheels
        dp.isEnabled = endDateOn
        return dp
    }()

    private lazy var endDateCheckbox: UISwitch = .configured { check in
        check.onTintColor = .nasa.primaryBlueDarker
        check.isOn = endDateOn

        check.addTarget(self, action: #selector(handleDateCheckbox), for: .valueChanged)
    }

    @objc func handleDateCheckbox() {
        endDateOn = endDateCheckbox.isOn
        endDatePicker.isEnabled = endDateCheckbox.isOn
    }

    private lazy var endDateGroup: UIView = .configured { vu in
        vu.addSubview(endDateLabel)
        endDateLabel.fillHorizontal(vu)
        endDateLabel.textAlignment = .center
        endDateLabel.anchor(top: vu.topAnchor)

        vu.addSubview(endDateCheckbox)
        endDateCheckbox.fillVertical(endDateLabel)
        endDateCheckbox.anchor(right: endDateLabel.rightAnchor)

        vu.addSubview(endDatePicker)
        endDatePicker.fillHorizontal(vu)
        endDatePicker.anchor(top: endDateLabel.bottomAnchor, paddingTop: 8)
    }

    private let randomCountLabel: UILabel = .configured { label in
        label.text = "Random Number"
        label.backgroundColor = .systemTeal
    }

    private lazy var applyButton: NasaPrimaryButton = {
        let button = NasaPrimaryButton(type: .system)
        button.setTitle("Apply", for: .normal)
        button.addTarget(self, action: #selector(handleApplyFilter), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
    }

    func configureUI() {
        view.addSubview(applyButton)
        applyButton.centerX(inView: view)
        applyButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 30)
        applyButton.setHeight(60)

        let arranged = [startDateGroup, endDateGroup]
        endDateLabel.text = endDateOn ? "End Date" : "Date Range?"
        startDateLabel.text = endDateOn ? "Start Date" : "Day"
        endDatePicker.minimumDate = startDateValue

        let stack = UIStackView(arrangedSubviews: arranged)
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.spacing = 6
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.addSubview(stack)
        stack.fillHorizontal(view)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: applyButton.topAnchor, paddingTop: 16, paddingBottom: 16)
    }

    // MARK: - Selectors

    @objc func handleApplyFilter() {
        print("apply filter pressed")
        var filter: ApodFilter
        if endDateOn {
            filter = .range(start_date: startDatePicker.date, end_date: endDatePicker.date)
        } else {
            filter = .date(date: startDatePicker.date)
        }
        filtersDelegate?.didPressApplyFilter(filter)
        dismiss(animated: true)
    }
}

// MARK: - ApodFiltersViewControllerRepresentation

struct ApodFiltersViewControllerRepresentation: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ApodFiltersViewController {
        return ApodFiltersViewController()
    }

    func updateUIViewController(_ uiViewController: ApodFiltersViewController, context: Context) {
    }

    typealias UIViewControllerType = ApodFiltersViewController
}

// MARK: - ApodFiltersViewController_Preview

struct ApodFiltersViewController_Preview: PreviewProvider {
    static var previews: some View {
        Color(UIColor.systemBackground)
            .sheet(isPresented: .constant(true)) {
                ApodFiltersViewControllerRepresentation().ignoresSafeArea()
            }
    }
}
