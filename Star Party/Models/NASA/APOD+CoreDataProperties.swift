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
    @NSManaged var explanation: String?
    @NSManaged var hdurl: String?
    @NSManaged var mediaType: String?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var date: String?
    @NSManaged var image: Data?
    @NSManaged var hdImage: Data?
}

// MARK: - APOD + Identifiable

extension APOD: Identifiable {
}
