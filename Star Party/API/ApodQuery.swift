//
//  ApodQuery.swift
//  Star Party
//
//  Created by Dakota Havel on 1/26/23.
//

import Foundation

// MARK: - ApodQuery

enum ApodQuery: APIRequest {
    var path: String { "/planetary/apod" }

    case range(start_date: String, end_date: String)
//    case random(count: Int)
//    case lastThreeMonths
    case date(date: String)
//    case today

    func makeQueryItems() -> [URLQueryItem] {
        switch self {
        case let .range(start_date: start_date, end_date: end_date):
            return URLQueryItem.items(from: [
                "start_date": start_date,
                "end_date": end_date,
            ])
//        case let .random(count: count):
//            return [URLQueryItem(name: "count", value: String(count))]
        case let .date(date: date):
            return URLQueryItem.items(from: [
                "start_date": date,
                "end_date": date,
            ])
//        case .today:
//            return []
//        case .lastThreeMonths:
//            let calendar = Calendar.current
//            let endDate = Date()
//            // current month is at 0 so -2 makes 3 months
//            let startMonth = calendar.date(byAdding: DateComponents(month: -2), to: endDate)!
//            let startDate = calendar.date(from: DateComponents(year: startMonth.year, month: startMonth.month, day: 1))!
//
//            return URLQueryItem.items(from: [
//                "start_date": ApodDateFormatter.string(from: startDate),
//                "end_date": ApodDateFormatter.string(from: endDate),
//            ])
        }
    }

    var queryDescription: String {
        switch self {
        case let .range(start_date: start_date, end_date: end_date):
            return "\(start_date) to \(end_date)"
//        case let .random(count: count):
//            return "\(count) Random APODs"
        case let .date(date: date):
            return "the day \(date)"
//        case .today:
//            return "today's APOD"
//        case .lastThreeMonths:
//            return "last three months"
        }
    }
}
