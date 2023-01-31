//
//  APOD+CoreDataClass.swift
//  Star Party
//
//  Created by Dakota Havel on 1/30/23.
//
//

import CoreData
import Foundation

@objc(APOD)
public class APOD: NSManagedObject {
    class func findOrCreate(from model: APOD_JSON, in context: NSManagedObjectContext) throws -> APOD {
        let request = APOD.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@ ", "date", model.date)

        if let existing = try context.fetch(request).first {
            return existing
        } else {
            let apod = APOD(context: context)
            apod.date = model.date
            apod.copyright = model.copyright
            apod.explanation = model.explanation
            apod.mediaType = model.mediaType
            apod.title = model.title
            apod.url = model.url
            apod.hdurl = model.hdurl

            return apod
        }
    }
}
