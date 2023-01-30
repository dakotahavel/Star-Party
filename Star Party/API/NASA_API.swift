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
    typealias ApodImageDataTaskCompletion = (Data?, URLResponse?, (any Error)?, ApodActualImageQuality) -> Void

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        // need to up amount so more images can be fetched simultaneously
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
        let apiKeyQueryItem = [URLQueryItem(name: "api_key", value: UserSettingsManager.getNasaApiKey())]
        components.queryItems = queryItems + apiKeyQueryItem

        guard let out = components.url else {
            throw API_Error.urlConstructionFailed
        }

        return out
    }

    private func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        return try await JSON.fetch(type, from: url, with: session)
    }

    private func fetch<T: Decodable>(_ type: [T].Type, from url: URL) async throws -> [T] {
        return try await JSON.fetch(type, from: url, with: session)
    }

    func fetchApodsData(_ query: ApodQuery) async throws {
        let url = try makeRoute(query)

        let kind = [APOD_JSON].self

        let res = try await fetch(kind, from: url)

        let filtered = res.filter { apod in
            // some urls have vimeo or youtube links not handled yet
            apod.url.contains("apod.nasa.gov/apod")
        }
        print("filtered len", filtered.count)
        try APOD.saved(filtered)
    }

    enum ApodDesiredImageQuality {
        case highDef
        case standard
        case best
    }

    enum ApodActualImageQuality {
        case highDef
        case standard
    }

    func resolveApodImageURL(_ apod: APOD, quality: ApodDesiredImageQuality = .best) -> (URL?, ApodActualImageQuality) {
        var out: (URL?, ApodActualImageQuality)
        switch quality {
        case .standard:
            out = (resolveStandardApodImageURL(apod), .standard)
        case .highDef:
            out = (resolveHighDefApodImageURL(apod), .highDef)
        case .best:
            let high = resolveHighDefApodImageURL(apod)
            guard let high else {
                return (resolveStandardApodImageURL(apod), .standard)
            }
            out = (high, .highDef)
        }

        return out
    }

    func resolveStandardApodImageURL(_ apod: APOD) -> URL? {
        if let sd = apod.url {
            return URL(string: sd)
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

    func assignImageByQuality(_ apod: APOD, data: Data, actualQuality: ApodActualImageQuality) throws {
        print("assign image")
        do {
            switch actualQuality {
            case .highDef:
                let image = try APOD_hd_image.from(data)
                print("high def")
                apod.hdImage = image
            case .standard:
                let image = try APOD_image.from(data)
                print("std def")
                apod.image = image
            }

            try PersistenceManager.shared.context.save()
        } catch {
            print("image assign error")
            print(error)
        }
    }

    func fetchApodImageData(_ apod: APOD, desiredQuality: ApodDesiredImageQuality) async throws {
//        print("apod in fetchapodimagedata", apod, apod.url, apod.hdurl)
        let (imageUrl, actualQuality) = resolveApodImageURL(apod, quality: desiredQuality)
//        print("here")
//        print("imageurl", imageUrl)
        if let url = imageUrl {
            let (imageData, response) = try await session.data(from: url)
            try Requests.checkResponseCode(response)

            try assignImageByQuality(apod, data: imageData, actualQuality: actualQuality)
            print("image assigned", apod.dateString, actualQuality)
        } else {
            throw API_Error.dataDecodeError
        }
    }

    func fetchApodImageDataTask(_ apod: APOD, desiredQuality: ApodDesiredImageQuality, completion: @escaping ApodImageDataTaskCompletion) -> URLSessionDataTask? {
        let (imageUrl, actualQuality) = resolveApodImageURL(apod, quality: desiredQuality)
        if let url = imageUrl {
            let urlRequest = URLRequest(url: url)
            let task = session.dataTask(with: urlRequest, completionHandler: { data, resp, error in
                completion(data, resp, error, actualQuality)
            })

            task.resume()
            return task
        }

        return nil
    }
}
