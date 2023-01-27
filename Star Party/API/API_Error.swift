//
//  File.swift
//  Space Report
//
//  Created by Dakota Havel on 1/17/23.
//

import Foundation

enum API_Error: Error {
    case urlConstructionFailed
    case clientError
    case serverError
    case unhandledResponseType
    case dataDecodeError
}
