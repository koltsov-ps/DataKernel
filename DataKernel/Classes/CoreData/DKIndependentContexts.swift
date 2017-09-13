import Foundation
import CoreData

open class DKIndependentContexts: DKContexts {
    public required init(coordinator: NSPersistentStoreCoordinator) {
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = coordinator
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = coordinator

        notificationTokens.append(NotificationCenter.default.addObserver(
                forName: NSNotification.Name.NSManagedObjectContextDidSave,
                object: backgroundContext, queue: OperationQueue.main) { [weak self] notification in
            print("Merge notification to ViewContext")
            self?.viewContext.mergeChanges(fromContextDidSave: notification)
        })

        notificationTokens.append(NotificationCenter.default.addObserver(
                forName: NSNotification.Name.NSManagedObjectContextDidSave,
                object: viewContext, queue: OperationQueue.main) { [weak self] notification in
            guard let context = self?.backgroundContext else { return }
            context.perform {
                print("Merge notification to BackgroundContext")
                context.mergeChanges(fromContextDidSave: notification)
            }
        })
    }

    public private(set) var viewContext: NSManagedObjectContext
    public private(set) var backgroundContext: NSManagedObjectContext
    private var notificationTokens = [NSObjectProtocol]()
}