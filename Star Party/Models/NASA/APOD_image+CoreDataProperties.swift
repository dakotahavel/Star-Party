//
//  APOD_image+CoreDataProperties.swift
//  Star Party
//
//  Created by Dakota Havel on 1/29/23.
//
//

import Foundation
import CoreData


extension APOD_image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<APOD_image> {
        return NSFetchRequest<APOD_image>(entityName: "APOD_image")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var apod: APOD?

}

extension APOD_image : Identifiable {

}
