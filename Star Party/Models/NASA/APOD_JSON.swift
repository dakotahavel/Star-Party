//
//  APOD_JSON.swift
//  Space Report
//
//  Created by Dakota Havel on 1/7/23.
//

import Foundation

// Example
// {
//    copyright: "Zarcos Palma",
//    date: "2023-01-07",
//    explanation: "On January 3, two space stations already illuminated by sunlight in low Earth orbit crossed this dark predawn sky. Moving west to east (left to right) across the composited timelapse image China's Tiangong Space Station traced the upper trail captured more than an hour before the local sunrise. Seen against a starry background Tiangong passes just below the inverted Big Dipper asterism of Ursa Major near the peak of its bright arc, and above north pole star Polaris. But less than five minutes before, the International Space Station had traced its own sunlit streak across the dark sky. Its trail begins just above the W-shape outlined by the bright stars of Cassiopeia near the northern horizon. The dramatic foreground spans an abandoned mine at Achada do Gamo in southeastern Portugal.",
//    hdurl: "https://apod.nasa.gov/apod/image/2301/ISS_TIANHE_FINAL_4_APOD.jpg",
//    media_type: "image",
//    service_version: "v1",
//    title: "Space Stations in Low Earth Orbit",
//    url: "https://apod.nasa.gov/apod/image/2301/ISS_TIANHE_FINAL_4_APOD1024.jpg"
// }

// MARK: - APOD_JSON

struct APOD_JSON: Decodable, Identifiable {
    // Should be one per day so date is the unique ID
    var id: Date {
        date
    }

    let date: Date
    let copyright: String?
    let explanation: String
    let mediaType: String
    let serviceVersion: String
    let title: String
    let url: String
    let hdurl: String?

    enum CodingKeys: String, CodingKey {
        case date
        case copyright
        case explanation
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title
        case url
        case hdurl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decode(String.self, forKey: .date)
        guard let date = ApodDateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: CodingKeys.date,
                in: container,
                debugDescription: "Date string does not match format expected by formatter."
            )
        }
        self.date = date
        self.copyright = try container.decodeIfPresent(String.self, forKey: .copyright)
        self.explanation = try container.decode(String.self, forKey: .explanation)
        self.mediaType = try container.decode(String.self, forKey: .mediaType)
        self.serviceVersion = try container.decode(String.self, forKey: .serviceVersion)
        self.title = try container.decode(String.self, forKey: .title)
        self.url = try container.decode(String.self, forKey: .url)
        self.hdurl = try container.decodeIfPresent(String.self, forKey: .hdurl)
    }
}
