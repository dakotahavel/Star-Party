//
//  ApodViewModel.swift
//  Space Report
//
//  Created by Dakota Havel on 1/17/23.
//

import UIKit

struct ApodViewModel {
    var apod: APOD

    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    var dateObj: Date? {
        return dateFormatter.date(from: apod.date)
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
