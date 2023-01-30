//
//  APOD+CoreDataProperties.swift
//  Star Party
//
//  Created by Dakota Havel on 1/30/23.
//
//

import CoreData
import Foundation

public extension APOD {
    @nonobjc class func fetchRequest() -> NSFetchRequest<APOD> {
        return NSFetchRequest<APOD>(entityName: "APOD")
    }

    @NSManaged var copyright: String?
    @NSManaged var date: Date?
    @NSManaged var explanation: String?
    @NSManaged var hdurl: String?
    @NSManaged var mediaType: String?
    @NSManaged var serviceVersion: String?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var dateString: String?
    @NSManaged var hdImage: APOD_hd_image?
    @NSManaged var image: APOD_image?
}

// MARK: - APOD + Identifiable

extension APOD: Identifiable {
}
