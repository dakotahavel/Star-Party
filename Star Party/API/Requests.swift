//
//  Requests.swift
//  Star Party
//
//  Created by Dakota Havel on 1/26/23.
//

import Foundation

// MARK: - Requests

enum Requests {
    static func checkResponseCode(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw API_Error.unhandledResponseType
        }
        let code = httpResponse.statusCode
        print(code, response.url)

        if (300..<400).contains(code) {
            throw API_Error.clientError
        }
        if (400..<500).contains(code) {
            throw API_Error.serverError
        }
    }

    static func hasGoodResponseCode(_ response: URLResponse?) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        let code = httpResponse.statusCode

        if 200..<300 ~= code {
            return true
        }

        return false
    }
}

// MARK: - APIRequest

protocol APIRequest {
    var path: String { get }
    func makeQueryItems() -> [URLQueryItem]
}
