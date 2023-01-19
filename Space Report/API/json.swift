//
//  urls.swift
//  Space Report
//
//  Created by Dakota Havel on 1/7/23.
//

import Foundation

// MARK: - json

enum json {
    static func fetch<T: Decodable>(_ type: T.Type, from url: URL, with session: URLSession) async throws -> T {
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        try checkResponseCode(response)
        let jsonObjects: T = try JSONDecoder().decode(type.self, from: data)
        return jsonObjects
    }

    static func fetch<T: Decodable>(_ type: [T].Type, from url: URL, with session: URLSession) async throws -> [T] {
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        try checkResponseCode(response)
        let jsonObjects: [T] = try JSONDecoder().decode(type.self, from: data)
        return jsonObjects
    }
}
