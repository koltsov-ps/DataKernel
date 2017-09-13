import Foundation
import CoreData

protocol DKContexts {
    init(coordinator: NSPersistentStoreCoordinator)
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
}

extension DKContexts {
    func saveViewContextIfNeeded() {
        do {
            let context = viewContext
            if context.hasChanges {
                try context.save()
            }
        } catch let error {
            print("ERROR while saving viewContext: \(error.localizedDescription)")
        }
    }

    func performBackgroundTask(block: @escaping (NSManagedObjectContext) throws -> ()) {
        let context = backgroundContext
        context.perform {
            do {
                try block(context)
            } catch let error {
                print("ERROR while performing background task: \(error.localizedDescription)")
            }
        }
    }
}