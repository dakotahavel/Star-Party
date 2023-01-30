//
//  StandardTypeExtensions.swift
//  Space Report
//
//  Created by Dakota Havel on 1/19/23.
//

import Foundation

// MARK: - Convenience Features

// A bunch of things that I would've expected to be in the standard lib
// I guess this isn't python though

extension String {
    subscript(_ i: Int) -> String {
        let idx1 = index(startIndex, offsetBy: i)
        let idx2 = index(idx1, offsetBy: 1)
        return String(self[idx1..<idx2])
    }

    subscript(r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start..<end])
    }

    subscript(r: CountableClosedRange<Int>) -> String {
        let startIndex = index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return String(self[startIndex...endIndex])
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }

    var day: Int {
        Calendar.current.component(Calendar.Component.year, from: self)
    }

    var month: Int {
        Calendar.current.component(Calendar.Component.month, from: self)
    }

    var year: Int {
        Calendar.current.component(Calendar.Component.year, from: self)
    }

    func toString(formatter: DateFormatter) -> String? {
        return formatter.string(from: self)
    }
}

extension Dictionary where Key: Comparable {
    enum SortDirection {
        case asc
        case desc
    }

    func sortByKeys(_ direction: SortDirection) -> [Self.Element] {
        switch direction {
        case .asc:
            return sorted { $0.key < $1.key }
        case .desc:
            return sorted { $0.key > $1.key }
        }
    }
}
