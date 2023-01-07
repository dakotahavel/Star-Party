//
//  AuthKind.swift
//  Space Report
//
//  Created by Dakota Havel on 1/7/23.
//

import Foundation

// MARK: - AuthKind

enum AuthKind {
    case nasa
}

let AuthMap: [AuthKind: URLQueryItem] = [
    .nasa: URLQueryItem(name: "api_key", value: Secrets.nasa_api_key),
]
