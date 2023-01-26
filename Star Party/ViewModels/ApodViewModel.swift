//
//  ApodViewModel.swift
//  Space Report
//
//  Created by Dakota Havel on 1/17/23.
//

import UIKit

// publicly available b/c needed

let ApodDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US_POSIX")
    df.dateFormat = "yyyy-MM-dd"
    return df
}()

public let oldestApodDate = ApodDateFormatter.date(from: "1995-06-16")

// MARK: - ApodViewModel

struct ApodViewModel {
    var apod: APOD

    var dateObj: Date? {
        return ApodDateFormatter.date(from: apod.date)
    }

    var yearMonth: Date? {
        var dateComponents = DateComponents()
        dateComponents.year = dateObj?.year
        dateComponents.month = dateObj?.month
        // day must be > 0 or it will revert a day, i.e. be last day of prior month
        dateComponents.day = 1
        dateComponents.hour = 1
        dateComponents.minute = 1
        let calendar = NSCalendar(identifier: .ISO8601)
        calendar?.locale = Locale(identifier: "en_US_POSIX")
        let title = calendar?.date(from: dateComponents)
        print("APOD", apod.id, apod.date, String(describing: dateObj), String(describing: "title: \(title)"))
        return title
    }

    var descriptionAttrString: NSAttributedString {
        let desc = apod.explanation
        let date = apod.date

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attrString = NSMutableAttributedString(string: date, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .title3),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.label,
        ])

        attrString.append(NSAttributedString(string: "\n\(desc)", attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label,
        ]))

        return attrString
    }

    var copyrightAttrString: NSAttributedString {
        if let copyright = apod.copyright {
            let attrString = NSMutableAttributedString(string: "© ", attributes: [
                .font: UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: .current),
                .strokeColor: UIColor.black,
                // need negative stroke for foregroundColor to work
                .strokeWidth: -1.0,
                .foregroundColor: UIColor.white,
            ])

            attrString.append(NSAttributedString(string: copyright, attributes: [
                .font: UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: .current),
                .strokeColor: UIColor.black,
                // need negative stroke for foregroundColor to work
                .strokeWidth: -1.0,
                .foregroundColor: UIColor.white,
            ]))

            return attrString
        }

        return NSAttributedString(string: "")
    }
}
