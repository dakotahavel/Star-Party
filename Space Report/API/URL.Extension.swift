//
//  URL.Extension.swift
//  Space Report
//
//  Created by Dakota Havel on 1/7/23.
//

import Foundation

extension URL {
    init(_ staticString: StaticString) {
        self.init(string: "\(staticString)")!
    }

    func withAuthQuery(kind: AuthKind) -> URL {
        let authItem: URLQueryItem = AuthMap[kind]!
        return appending(queryItems: [authItem])
    }

    func withQuery(from dictionary: [String: any ExpressibleByStringInterpolation]) -> URL {
        let queryItems = dictionary.map { key, val in
            URLQueryItem(name: key, value: "\(val)")
        }
        return appending(queryItems: queryItems)
    }
}
