//
//  APOD+CoreDataClass.swift
//  Star Party
//
//  Created by Dakota Havel on 1/29/23.
//
//

import CoreData
import Foundation

@objc(APOD)
public class APOD: NSManagedObject {
    static let context = PersistenceManager.shared.context
    static func from(_ model: APOD_JSON, context: NSManagedObjectContext = APOD.context) throws -> APOD {
        let apod = APOD(context: context)
        apod.dateString = ApodDateFormatter.string(from: model.date)
        apod.date = model.date
        apod.copyright = model.copyright
        apod.explanation = model.explanation
        apod.mediaType = model.mediaType
        apod.serviceVersion = model.serviceVersion
        apod.title = model.title
        apod.url = model.url
        apod.hdurl = model.hdurl

        // dateString is constraint on APOD model, only non-existing will be added here
        try context.save()
        return apod
    }

    /** Void return version of apod APOD instantiation */
    static func saved(_ model: APOD_JSON, context: NSManagedObjectContext = APOD.context) throws {
        _ = try APOD.from(model, context: context)
    }

    static func from(_ models: [APOD_JSON], context: NSManagedObjectContext = APOD.context) throws -> [APOD] {
        var apods: [APOD] = []

        // TODO: Convert this to batch insert instead of loop
        for model in models {
            let apod = APOD(context: context)
            apod.dateString = ApodDateFormatter.string(from: model.date)
            apod.date = model.date
            apod.copyright = model.copyright
            apod.explanation = model.explanation
            apod.mediaType = model.mediaType
            apod.serviceVersion = model.serviceVersion
            apod.title = model.title
            apod.url = model.url
            apod.hdurl = model.hdurl
            print(model.title)
            context.insert(apod)
            apods.append(apod)
        }
        // dateString is constraint on APOD model, only non-existing will be added here
        try context.save()
        return apods
    }

    /** Void return version of apod APOD instantiation */
    static func saved(_ models: [APOD_JSON], context: NSManagedObjectContext = APOD.context) throws {
        _ = try APOD.from(models, context: context)
    }

    static func fetchById(dateString: String) throws -> APOD? {
        let request = APOD.fetchRequest() as NSFetchRequest<APOD>
        request.predicate = NSPredicate(format: "%K == %@", "dateString", dateString)
        return try APOD.context.fetch(request).first
    }

    func refresh() {
        APOD.context.refresh(self, mergeChanges: true)
    }
}
