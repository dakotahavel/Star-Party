//
//  APOD.swift
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

struct APOD: Codable, Identifiable {
    // Should be one per day so date is the unique ID
    var id: String {
        date
    }

    let copyright: String?
    let date: String
    let explanation: String
    let hdurl: String?
    let media_type: String
    let service_version: String
    let title: String
    let url: String

    var sdImageData: Data?
    var hdImageData: Data?
}
