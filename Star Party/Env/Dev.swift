//
//  Dev.swift
//  Star Party
//
//  Created by Dakota Havel on 1/26/23.
//

import Foundation

struct Dev {
    static func setupDev() {
        UserDefaults.standard.set(Secrets.nasa_api_key, forKey: UserSettingsKeys.kApodApi)
    }

//    static func setupPreviewPersistence(for: NSManagedObject) {
//    }
}
