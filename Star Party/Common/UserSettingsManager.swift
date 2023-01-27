//
//  UserSettingsManager.swift
//  Star Party
//
//  Created by Dakota Havel on 1/27/23.
//

import Foundation

enum UserSettingsManager {
    static func getNasaApiKey() -> String {
        UserDefaults.standard.string(forKey: UserSettingsKeys.kApodApi) ?? "DEMO_KEY"
    }

    static func getSkipOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: UserSettingsKeys.kSkipOnboarding)
    }
}
