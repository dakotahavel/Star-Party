//
//  NasaAPI.swift
//  Space Report
//
//  Created by Dakota Havel on 1/8/23.
//

import Foundation
import UIKit

func checkResponseCode(_ response: URLResponse) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw apiError.unhandledResponseType
    }
    let code = httpResponse.statusCode

    if (300..<400).contains(code) {
        throw apiError.clientError
    }
    if (400..<500).contains(code) {
        throw apiError.serverError
    }
}

private func makeRoute(_ request: APIRequest, queryItems: [URLQueryItem] = []) throws -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.nasa.gov"
    components.path = request.path
    let queryItems = request.makeQueryItems()
    let apiKeyQueryItem = [URLQueryItem(name: "api_key", value: Secrets.nasa_api_key)]
    components.queryItems = queryItems + apiKeyQueryItem

    guard let out = components.url else {
        throw apiError.urlConstructionFailed
    }

    return out
}

// MARK: - APIRequest

protocol APIRequest {
    var path: String { get }
    func makeQueryItems() -> [URLQueryItem]
}

// MARK: - ApodQuery

enum ApodQuery: APIRequest {
    var path: String { "/planetary/apod" }

    case range(start_date: String, end_date: String)
    case random(count: Int)
    case date(date: String)
    case today

    func makeQueryItems() -> [URLQueryItem] {
        switch self {
        case let .range(start_date: start_date, end_date: end_date):
            return URLQueryItem.items(from: [
                "start_date": start_date,
                "end_date": end_date,
            ])
        case let .random(count: count):
            return [
                URLQueryItem(name: "count", value: String(count)),
            ]
        case let .date(date: date):
            return [
                URLQueryItem(name: "date", value: date),
            ]
        case .today:
            return []
        }
    }
}

// MARK: - NasaAPI

class NasaAPI {
    static let shared = NasaAPI()
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(
            configuration: config
        )
    }()

    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        return try await json.fetch(type, from: url, with: session)
    }

    func fetchApod(_ query: ApodQuery) async throws -> APOD {
        let url = try makeRoute(query)
        let kind = APOD.self
        let res = try await fetch(kind, from: url)
        print("apod res", res)
        return res
    }

    func fetchApodImageData(_ query: ApodQuery) async throws -> (Data?, APOD) {
        let apod = try await fetchApod(query)
        let hdurl = URL(string: apod.hdurl)
        let sdurl = URL(string: apod.url)

        if let hdurl {
            let (imageData, response) = try await session.data(from: hdurl)
            try checkResponseCode(response)
            return (imageData, apod)
        }

        if let sdurl {
            let (imageData, response) = try await session.data(from: sdurl)
            try checkResponseCode(response)
            return (imageData, apod)
        }

        return (nil, apod)
    }

//    static func getApod() async throws -> APOD? {
//        return try await json.fetch(from: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY", for: APOD.self)
//    }

//    static func fetchApodImage(completion: @escaping (UIImage) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            if
//                let data = try? Data(contentsOf: URL(string: "https://apod.nasa.gov/apod/image/2301/jwst-ngc346.png")),
//                let image = UIImage(data: data)
//            {
//                completion(image)

//                DispatchQueue.main.async {
//                    print("Image fetched", image)
//                    self?.apodImage = image
//                }
//            }
//        }
//    }
}
