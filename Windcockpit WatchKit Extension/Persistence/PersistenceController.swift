//
//  PersistenceSontroller.swift
//  CoreSample
//
//  Created by Ralf Wirdemann on 14.04.23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController(inMemory: false)

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WindcockpitWatchData")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
