//
//  NetworkingExtensions.swift
//  Space Report
//
//  Created by Dakota Havel on 1/15/23.
//

import Foundation

extension URL {
    // avoid having to unwrap when constructed from compile time string
    init(_ staticString: StaticString) {
        guard let url = URL(string: "\(staticString)") else {
            preconditionFailure("Invalid static URL string: \(staticString)")
        }

        self = url
    }

    init(throws string: String) throws {
        guard let url = URL(string: string) else {
            throw URLError(.badURL)
        }

        self = url
    }
}

//
extension URLQueryItem {
    static func items(from dict: [String: String]) -> [URLQueryItem] {
        var out: [URLQueryItem] = .init()
        for (k, v) in dict {
            out.append(URLQueryItem(name: k, value: v))
        }
        return out
    }
}

typealias URLSessionDataTaskCompletion = (Data?, URLResponse?, (any Error)?) -> Void
