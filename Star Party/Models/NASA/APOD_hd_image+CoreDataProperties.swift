//
//  APOD_hd_image+CoreDataProperties.swift
//  Star Party
//
//  Created by Dakota Havel on 1/29/23.
//
//

import Foundation
import CoreData


extension APOD_hd_image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<APOD_hd_image> {
        return NSFetchRequest<APOD_hd_image>(entityName: "APOD_hd_image")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var apod: APOD?

}

extension APOD_hd_image : Identifiable {

}
