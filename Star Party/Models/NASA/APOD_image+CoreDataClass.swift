//
//  APOD_image+CoreDataClass.swift
//  Star Party
//
//  Created by Dakota Havel on 1/29/23.
//
//

import CoreData
import Foundation

@objc(APOD_image)
public class APOD_image: NSManagedObject {
    private static let context = PersistenceManager.shared.context
    static func from(_ data: Data, context: NSManagedObjectContext = APOD_image.context) throws -> APOD_image {
        let apodImage = APOD_image(context: context)
        apodImage.imageData = data
        try context.save()
        return apodImage
    }
}
