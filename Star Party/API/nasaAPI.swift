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
    print(code, response.url)

    if (300..<400).contains(code) {
        throw apiError.clientError
    }
    if (400..<500).contains(code) {
        throw apiError.serverError
    }
}

func hasGoodResponseCode(_ response: URLResponse?) -> Bool {
    guard let httpResponse = response as? HTTPURLResponse else {
        return false
    }
    let code = httpResponse.statusCode

    if 200..<300 ~= code {
        return true
    }

    return false
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
    case lastThreeMonths
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
            return [URLQueryItem(name: "count", value: String(count))]
        case let .date(date: date):
            return [URLQueryItem(name: "date", value: date)]
        case .today:
            return []
        case .lastThreeMonths:
            let calendar = Calendar.current
            let endDate = Date()
            // current month is at 0 so -2 makes 3 months
            let startMonth = calendar.date(byAdding: DateComponents(month: -2), to: endDate)!
            let startDate = calendar.date(from: DateComponents(year: startMonth.year, month: startMonth.month, day: 1))!

            return URLQueryItem.items(from: [
                "start_date": ApodDateFormatter.string(from: startDate),
                "end_date": ApodDateFormatter.string(from: endDate),
            ])
        }
    }

    var queryDescription: String {
        switch self {
        case let .range(start_date: start_date, end_date: end_date):
            return "\(start_date) to \(end_date)"
        case let .random(count: count):
            return "\(count) Random APODs"
        case let .date(date: date):
            return "the day \(date)"
        case .today:
            return "today's APOD"
        case .lastThreeMonths:
            return "last three months"
        }
    }
}

// MARK: - NasaAPI

class NasaAPI {
    static let shared = NasaAPI()
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        // need to up amount so images can all be fetched simultaneously
        config.httpMaximumConnectionsPerHost = 30
//        config.requestCachePolicy = .reloadIgnoringLocalCacheData

        return URLSession(
            configuration: config
        )
    }()

    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        return try await json.fetch(type, from: url, with: session)
    }

    func fakeRandomApods() -> [APOD] {
        let path = Bundle.main.url(forResource: "random", withExtension: "json")!

        do {
            let data = try Data(contentsOf: path)
            let apods = try JSONDecoder().decode([APOD].self, from: data).filter { apod in
                // some urls had vimeo or youtube links
                apod.url.contains("apod.nasa.gov/apod")
            }

            return apods
        } catch {
            print(error)
        }

        return []
    }

    func fetchApodsData(_ query: ApodQuery) async throws -> [APOD] {
        let url = try makeRoute(query)
        print("fetch apods data url", url)
        let kind = [APOD].self
        let res = try await fetch(kind, from: url)
        return res.filter { apod in
            // some urls had vimeo or youtube links not handled yet
            apod.url.contains("apod.nasa.gov/apod")
        }
    }

    func fetchTodaysApod() async throws -> APOD {
        let url = try makeRoute(ApodQuery.today)
        let kind = APOD.self
        var apod = try await fetch(kind, from: url)
        let data = try await fetchApodImageData(apod, quality: .best)
        apod.sdImageData = data
        return apod
    }

    enum ApodImageQuality {
        case highDef
        case standard
        case best
    }

    func resolveApodImageURL(_ apod: APOD, quality: ApodImageQuality = .best) -> URL? {
        switch quality {
        case .standard:
            return resolveStandardApodImageURL(apod)
        case .highDef:
            return resolveHighDefApodImageURL(apod)
        case .best:
            let high = resolveHighDefApodImageURL(apod)
            guard let high else {
                return resolveStandardApodImageURL(apod)
            }
            return high
        }
    }

    func resolveStandardApodImageURL(_ apod: APOD) -> URL? {
        if let sd = URL(string: apod.url) {
            return sd
        }

        return nil
    }

    func resolveHighDefApodImageURL(_ apod: APOD) -> URL? {
        if let hdurl = apod.hdurl {
            if let hd = URL(string: hdurl) {
                return hd
            }
        }

        return nil
    }

    func fetchApodImageData(_ apod: APOD, quality: ApodImageQuality) async throws -> Data {
        if let imageUrl = resolveApodImageURL(apod, quality: quality) {
            let (imageData, response) = try await session.data(from: imageUrl)
            try checkResponseCode(response)
            return imageData
        }

        throw apiError.dataDecodeError
    }

    func fetchApodImageDataTask(_ apod: APOD, quality: ApodImageQuality, completion: @escaping URLSessionDataTaskCompletion) -> URLSessionDataTask? {
        if let imageUrl = resolveApodImageURL(apod, quality: quality) {
            let urlRequest = URLRequest(url: imageUrl)
            let task = session.dataTask(with: urlRequest, completionHandler: completion)

            task.resume()
            return task
        }

        return nil
    }
}
