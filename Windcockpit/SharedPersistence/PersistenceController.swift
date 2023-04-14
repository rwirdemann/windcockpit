//
//  Persistence.swift
//  CoreSample
//
//  Created by Ralf Wirdemann on 10.08.22.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController(inMemory: false)

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WindcockpitCoreData")
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
    
    func deleteAllSession(entityName: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )
        deleteRequest.resultType = .resultTypeObjectIDs
        let context = container.viewContext
        let batchDelete = try? context.execute(deleteRequest) as? NSBatchDeleteResult

        guard let deleteResult = batchDelete?.result
            as? [NSManagedObjectID]
            else { return }

        let deletedObjects: [AnyHashable: Any] = [
            NSDeletedObjectsKey: deleteResult
        ]
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [context]
        )
    }
}
