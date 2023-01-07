//
//  urls.swift
//  Space Report
//
//  Created by Dakota Havel on 1/7/23.
//

import Foundation

struct API {
    struct NASA {
        enum Routes: String {
            case apod = "planetary/apod"
        }

        private static let base = URL("https://api.nasa.gov/").withAuthQuery(kind: .nasa)
        private let session = URLSession(configuration: .default)
    }
}
