//
//  File.swift
//  Space Report
//
//  Created by Dakota Havel on 1/17/23.
//

import Foundation

enum apiError: Error {
    case urlConstructionFailed
    case clientError
    case serverError
    case unhandledResponseType
}
