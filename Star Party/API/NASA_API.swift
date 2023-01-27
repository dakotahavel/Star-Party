//
//  NasaAPI.swift
//  Space Report
//
//  Created by Dakota Havel on 1/8/23.
//

import Foundation
import UIKit

class NASA_API {
    static let shared = NASA_API()

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        // need to up amount so images can all be fetched simultaneously
        config.httpMaximumConnectionsPerHost = 30

        // test heavy loading
        // config.requestCachePolicy = .reloadIgnoringLocalCacheData

        return URLSession(
            configuration: config
        )
    }()

    private func makeRoute(_ request: APIRequest, queryItems: [URLQueryItem] = []) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.nasa.gov"
        components.path = request.path
        let queryItems = request.makeQueryItems()
        print("making route, key is", UserSettingsManager.getNasaApiKey())
        let apiKeyQueryItem = [URLQueryItem(name: "api_key", value: UserSettingsManager.getNasaApiKey())]
        components.queryItems = queryItems + apiKeyQueryItem

        guard let out = components.url else {
            throw API_Error.urlConstructionFailed
        }

        return out
    }

    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        return try await JSON.fetch(type, from: url, with: session)
    }

    func fakeRandomApods() -> [APOD_JSON] {
        let path = Bundle.main.url(forResource: "random", withExtension: "json")!

        do {
            let data = try Data(contentsOf: path)
            let apods = try JSONDecoder().decode([APOD_JSON].self, from: data).filter { apod in
                // some urls had vimeo or youtube links
                apod.url.contains("apod.nasa.gov/apod")
            }

            return apods
        } catch {
            print(error)
        }

        return []
    }

    func fetchApodsData(_ query: ApodQuery) async throws -> [APOD_JSON] {
        let url = try makeRoute(query)
        print("fetch apods data url", url)
        let kind = [APOD_JSON].self
        let res = try await fetch(kind, from: url)
        return res.filter { apod in
            // some urls have vimeo or youtube links not handled yet
            apod.url.contains("apod.nasa.gov/apod")
        }
    }

    func fetchTodaysApod() async throws -> APOD_JSON {
        let url = try makeRoute(ApodQuery.today)
        let kind = APOD_JSON.self
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

    func resolveApodImageURL(_ apod: APOD_JSON, quality: ApodImageQuality = .best) -> URL? {
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

    func resolveStandardApodImageURL(_ apod: APOD_JSON) -> URL? {
        if let sd = URL(string: apod.url) {
            return sd
        }

        return nil
    }

    func resolveHighDefApodImageURL(_ apod: APOD_JSON) -> URL? {
        if let hdurl = apod.hdurl {
            if let hd = URL(string: hdurl) {
                return hd
            }
        }

        return nil
    }

    func fetchApodImageData(_ apod: APOD_JSON, quality: ApodImageQuality) async throws -> Data {
        if let imageUrl = resolveApodImageURL(apod, quality: quality) {
            let (imageData, response) = try await session.data(from: imageUrl)
            try Requests.checkResponseCode(response)
            return imageData
        }

        throw API_Error.dataDecodeError
    }

    func fetchApodImageDataTask(_ apod: APOD_JSON, quality: ApodImageQuality, completion: @escaping URLSessionDataTaskCompletion) -> URLSessionDataTask? {
        if let imageUrl = resolveApodImageURL(apod, quality: quality) {
            let urlRequest = URLRequest(url: imageUrl)
            let task = session.dataTask(with: urlRequest, completionHandler: completion)

            task.resume()
            return task
        }

        return nil
    }
}
