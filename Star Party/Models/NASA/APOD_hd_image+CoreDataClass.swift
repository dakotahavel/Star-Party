//
//  APOD_hd_image+CoreDataClass.swift
//  Star Party
//
//  Created by Dakota Havel on 1/29/23.
//
//

import CoreData
import Foundation

@objc(APOD_hd_image)
public class APOD_hd_image: NSManagedObject {
    private static let context = PersistenceManager.shared.context
    static func from(_ data: Data, context: NSManagedObjectContext = APOD_hd_image.context) throws -> APOD_hd_image {
        let apodHdImage = APOD_hd_image(context: context)
        apodHdImage.imageData = data
        try context.save()
        return apodHdImage
    }
}
