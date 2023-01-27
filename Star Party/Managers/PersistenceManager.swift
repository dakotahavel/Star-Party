//
//  PersistenceManager.swift
//  Star Party
//
//  Created by Dakota Havel on 1/26/23.
//

import CoreData
import UIKit

class PersistenceManager {
    let shared = PersistenceManager()
    let preview: PersistenceManager = {
        let manager = PersistenceManager(inMemory: true)

        return manager
    }()

    let container: NSPersistentContainer
    let context: NSManagedObjectContext

    init(inMemory: Bool = false) {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true

        container.viewContext.name = "viewContext"

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        self.container = container
        self.context = container.viewContext
    }
}
